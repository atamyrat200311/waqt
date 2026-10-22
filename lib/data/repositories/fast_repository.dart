import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/dates.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_repository.dart';

class FastLog {
  const FastLog(this.day, this.type, this.status);
  final DayKey day;
  final FastType type;
  final FastStatus status;
}

class FastRepository {
  FastRepository(this._db, [this._settings]);

  final AppDatabase _db;
  final SettingsRepository? _settings;

  /// Sets or (with [status] == null) clears the fast for a day.
  Future<void> set(DayKey day, FastType type, FastStatus? status) async {
    if (status == null) {
      await (_db.delete(_db.fasts)..where((t) => t.date.equals(day.value))).go();
    } else {
      await _db.into(_db.fasts).insertOnConflictUpdate(
            FastsCompanion.insert(date: day.value, type: type, status: status),
          );
    }
    if (type == FastType.qada) {
      await _settings?.setFlag('qada_fast_last_modified', DateTime.now().toIso8601String());
    }
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

  /// Watches the exact remaining qada-fast balance.
  ///
  /// Logged missed/excused Ramadan days add to the balance and logged qada
  /// fasts subtract from it. [QadaFastBalances.adjustment] lets the user set an
  /// exact starting point for debt that predates the app.
  Stream<int> watchQadaRemaining() {
    return _db.customSelect(
      '''
      SELECT MAX(
        0,
        COALESCE(
          (SELECT adjustment FROM qada_fast_balances WHERE id = 1),
          0
        ) + COALESCE(SUM(
          CASE
            WHEN type = 'ramadan' AND status != 'fasted' THEN 1
            WHEN type = 'qada' AND status = 'fasted' THEN -1
            ELSE 0
          END
        ), 0)
      ) AS remaining
      FROM fasts
      ''',
      readsFrom: {_db.fasts, _db.qadaFastBalances},
    ).watchSingle().map((row) => row.read<int>('remaining'));
  }

  /// Replaces the visible remaining balance without discarding dated logs.
  Future<void> setQadaRemaining(int remaining) async {
    if (remaining < 0) throw ArgumentError.value(remaining, 'remaining');
    await _db.transaction(() async {
      final rows = await _db.select(_db.fasts).get();
      final logged = rows.fold<int>(0, (total, row) {
        if (row.type == FastType.ramadan && row.status != FastStatus.fasted) {
          return total + 1;
        }
        if (row.type == FastType.qada && row.status == FastStatus.fasted) {
          return total - 1;
        }
        return total;
      });
      await _db.into(_db.qadaFastBalances).insertOnConflictUpdate(
            QadaFastBalancesCompanion.insert(
              id: const Value(1),
              adjustment: Value(remaining - logged),
            ),
          );
      await _settings?.setFlag('qada_fast_last_modified', DateTime.now().toIso8601String());
    });
  }

  /// Adds [count] days of older missed fasts to the balance.
  Future<void> addOlder(int count) async {
    if (count <= 0) return;
    final row = await _db.customSelect(
      '''
      SELECT MAX(
        0,
        COALESCE(
          (SELECT adjustment FROM qada_fast_balances WHERE id = 1),
          0
        ) + COALESCE(SUM(
          CASE
            WHEN type = 'ramadan' AND status != 'fasted' THEN 1
            WHEN type = 'qada' AND status = 'fasted' THEN -1
            ELSE 0
          END
        ), 0)
      ) AS remaining
      FROM fasts
      ''',
      readsFrom: {_db.fasts, _db.qadaFastBalances},
    ).getSingle();
    final remaining = row.read<int>('remaining');
    await setQadaRemaining(remaining + count);
  }

  /// Total qada fasts made up since beginning.
  Stream<int> watchMadeUpTotal() {
    final count = _db.fasts.date.count();
    final q = _db.selectOnly(_db.fasts)
      ..addColumns([count])
      ..where(_db.fasts.type.equalsValue(FastType.qada) &
             _db.fasts.status.equalsValue(FastStatus.fasted));
    return q.watchSingle().map((r) => r.read(count) ?? 0);
  }

  /// Most recent date on which a qada fast was kept.
  Stream<DayKey?> watchLastMadeUpDate() {
    final q = _db.select(_db.fasts)
      ..where((t) => t.type.equalsValue(FastType.qada) & t.status.equalsValue(FastStatus.fasted))
      ..orderBy([(t) => OrderingTerm.desc(t.date)])
      ..limit(1);
    return q.watchSingleOrNull().map((r) => r == null ? null : DayKey(r.date));
  }

  /// Last modification timestamp from settings flag.
  Future<DateTime?> getLastModified() async {
    final s = await _settings?.getFlag('qada_fast_last_modified');
    if (s != null) {
      try {
        return DateTime.parse(s);
      } catch (_) {}
    }
    return null;
  }
}

/// Ramadan fasts still owed: missed or excused Ramadan days minus make-up
/// (qada) fasts kept. Never negative.
int fastsOwed(Iterable<FastLog> all) {
  var owed = 0;
  var madeUp = 0;
  for (final f in all) {
    if (f.type == FastType.ramadan && f.status != FastStatus.fasted) owed++;
    if (f.type == FastType.qada && f.status == FastStatus.fasted) madeUp++;
  }
  return (owed - madeUp).clamp(0, 1 << 30);
}

final fastsOwedProvider = StreamProvider<int>(
  (ref) => ref.watch(fastRepositoryProvider).watchQadaRemaining(),
);

final fastRepositoryProvider = Provider<FastRepository>(
  (ref) => FastRepository(ref.watch(databaseProvider), ref.watch(settingsRepositoryProvider)),
);
