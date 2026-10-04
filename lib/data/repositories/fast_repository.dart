import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/dates.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';

class FastLog {
  const FastLog(this.day, this.type, this.status);
  final DayKey day;
  final FastType type;
  final FastStatus status;
}

class FastRepository {
  FastRepository(this._db);

  final AppDatabase _db;

  /// Sets or (with [status] == null) clears the fast for a day.
  Future<void> set(DayKey day, FastType type, FastStatus? status) {
    if (status == null) {
      return (_db.delete(_db.fasts)..where((t) => t.date.equals(day.value))).go();
    }
    return _db.into(_db.fasts).insertOnConflictUpdate(
          FastsCompanion.insert(date: day.value, type: type, status: status),
        );
  }

  /// Inclusive range, keyed by day.
  Stream<Map<DayKey, FastLog>> watchRange(DayKey from, DayKey to) {
    final q = _db.select(_db.fasts)
      ..where((t) => t.date.isBetweenValues(from.value, to.value))
      ..orderBy([(t) => OrderingTerm.asc(t.date)]);
    return q.watch().map((rows) => {
          for (final r in rows) DayKey(r.date): FastLog(DayKey(r.date), r.type, r.status),
        });
  }
}

final fastRepositoryProvider =
    Provider<FastRepository>((ref) => FastRepository(ref.watch(databaseProvider)));
