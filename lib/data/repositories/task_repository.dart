import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/dates.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.day,
    required this.window,
    required this.done,
    required this.sortOrder,
    this.doneAt,
  });

  final int id;
  final String title;
  final DayKey day;
  final TaskWindow window;
  final bool done;
  final DateTime? doneAt;
  final int sortOrder;
}

class TaskRepository {
  TaskRepository(this._db);

  final AppDatabase _db;

  Future<int> add(String title, DayKey day, TaskWindow window) async {
    final t = title.trim();
    if (t.isEmpty) throw ArgumentError('empty title');
    final max = _db.tasks.sortOrder.max();
    final row = await (_db.selectOnly(_db.tasks)
          ..addColumns([max])
          ..where(_db.tasks.date.equals(day.value) & _db.tasks.window.equalsValue(window)))
        .getSingle();
    return _db.into(_db.tasks).insert(TasksCompanion.insert(
          title: t,
          date: day.value,
          window: window,
          sortOrder: Value((row.read(max) ?? -1) + 1),
        ));
  }

  Future<void> setDone(int id, bool done, {DateTime? now}) =>
      (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(TasksCompanion(
        done: Value(done),
        doneAt: Value(done ? (now ?? DateTime.now()) : null),
      ));

  Future<void> delete(int id) => (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();

  Future<void> restore(Task t) => _db.into(_db.tasks).insert(TasksCompanion.insert(
        id: Value(t.id),
        title: t.title,
        date: t.day.value,
        window: t.window,
        done: Value(t.done),
        doneAt: Value(t.doneAt),
        sortOrder: Value(t.sortOrder),
      ));

  Stream<List<Task>> watchDay(DayKey day) {
    final q = _db.select(_db.tasks)
      ..where((t) => t.date.equals(day.value))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.id)]);
    return q.watch().map((rows) => rows.map(_toTask).toList());
  }

  /// Undone tasks from days before [today].
  Stream<List<Task>> watchOverdue(DayKey today) {
    final q = _db.select(_db.tasks)
      ..where((t) => t.date.isSmallerThanValue(today.value) & t.done.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.date), (t) => OrderingTerm.asc(t.sortOrder)]);
    return q.watch().map((rows) => rows.map(_toTask).toList());
  }

  /// "Move to today": keeps each task's prayer window.
  Future<void> moveTo(Iterable<int> ids, DayKey day) =>
      (_db.update(_db.tasks)..where((t) => t.id.isIn(ids))).write(TasksCompanion(date: Value(day.value)));

  Task _toTask(TaskRow r) => Task(
        id: r.id,
        title: r.title,
        day: DayKey(r.date),
        window: r.window,
        done: r.done,
        doneAt: r.doneAt,
        sortOrder: r.sortOrder,
      );
}

final taskRepositoryProvider =
    Provider<TaskRepository>((ref) => TaskRepository(ref.watch(databaseProvider)));
