import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/dates.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';

class AdhkarRepository {
  AdhkarRepository(this._db);

  final AppDatabase _db;

  /// itemId → count for one set on one day.
  Stream<Map<String, int>> watchDay(DayKey day, AdhkarSet set) {
    final q = _db.select(_db.adhkarProgress)
      ..where((t) => t.date.equals(day.value) & t.setId.equalsValue(set));
    return q.watch().map((rows) => {for (final r in rows) r.itemId: r.count});
  }

  Future<void> setCount(DayKey day, AdhkarSet set, String itemId, int count) =>
      _db.into(_db.adhkarProgress).insertOnConflictUpdate(AdhkarProgressCompanion.insert(
            date: day.value,
            setId: set,
            itemId: itemId,
            count: Value(count < 0 ? 0 : count),
          ));

  /// (day, set) → itemId → count in an inclusive range (for streaks/stats).
  Stream<Map<(DayKey, AdhkarSet), Map<String, int>>> watchRange(DayKey from, DayKey to) {
    final q = _db.select(_db.adhkarProgress)
      ..where((t) => t.date.isBetweenValues(from.value, to.value));
    return q.watch().map((rows) {
      final out = <(DayKey, AdhkarSet), Map<String, int>>{};
      for (final r in rows) {
        (out[(DayKey(r.date), r.setId)] ??= {})[r.itemId] = r.count;
      }
      return out;
    });
  }
}

final adhkarRepositoryProvider =
    Provider<AdhkarRepository>((ref) => AdhkarRepository(ref.watch(databaseProvider)));
