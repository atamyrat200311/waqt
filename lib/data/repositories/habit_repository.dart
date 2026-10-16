import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/dates.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';

/// Custom daily habits (read, walk, water, sadaqa…) with one check per day.
class HabitRepository {
  HabitRepository(this._db);

  final AppDatabase _db;

  Future<int> add(String title, String icon, {DateTime? now}) async {
    final max = _db.habits.sortOrder.max();
    final row = await (_db.selectOnly(_db.habits)..addColumns([max])).getSingle();
    return _db.into(_db.habits).insert(HabitsCompanion.insert(
          title: title.trim(),
          icon: Value(icon),
          sortOrder: Value((row.read(max) ?? 0) + 1),
          createdAt: now ?? DateTime.now(),
        ));
  }

  Future<void> rename(int id, String title, String icon) =>
      (_db.update(_db.habits)..where((t) => t.id.equals(id)))
          .write(HabitsCompanion(title: Value(title.trim()), icon: Value(icon)));

  Future<void> delete(int id) async {
    await (_db.delete(_db.habitLogs)..where((t) => t.habitId.equals(id))).go();
    await (_db.delete(_db.habits)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<HabitRow>> watchActive() => (_db.select(_db.habits)
        ..where((t) => t.archived.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.id)]))
      .watch();

  Future<void> setDone(int habitId, DayKey day, bool done) {
    if (done) {
      return _db.into(_db.habitLogs).insert(
            HabitLogsCompanion.insert(habitId: habitId, date: day.value),
            mode: InsertMode.insertOrIgnore,
          );
    }
    return (_db.delete(_db.habitLogs)..where((t) => t.habitId.equals(habitId) & t.date.equals(day.value))).go();
  }

  /// habitId → set of `yyyy-MM-dd` days done, within the range.
  Stream<Map<int, Set<String>>> watchLogs(DayKey from, DayKey to) {
    final q = _db.select(_db.habitLogs)..where((t) => t.date.isBetweenValues(from.value, to.value));
    return q.watch().map((rows) {
      final m = <int, Set<String>>{};
      for (final r in rows) {
        (m[r.habitId] ??= {}).add(r.date);
      }
      return m;
    });
  }
}

final habitRepositoryProvider = Provider<HabitRepository>((ref) => HabitRepository(ref.watch(databaseProvider)));
