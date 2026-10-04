import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/dates.dart';
import '../../features/prayer/domain/qada_rules.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';

class PrayerLog {
  const PrayerLog(this.day, this.prayer, this.status, this.markedAt);
  final DayKey day;
  final Prayer prayer;
  final PrayerStatus status;
  final DateTime markedAt;
}

/// Prayer marks + qada counts. Marking and the matching qada change happen in
/// one transaction so the two can never disagree.
class PrayerRepository {
  PrayerRepository(this._db);

  final AppDatabase _db;

  // ------------------------------------------------------------- prayer logs

  Stream<Map<Prayer, PrayerStatus>> watchDay(DayKey day) {
    final q = _db.select(_db.prayerLogs)..where((t) => t.date.equals(day.value));
    return q.watch().map((rows) => {for (final r in rows) r.prayer: r.status});
  }

  Future<Map<Prayer, PrayerStatus>> getDay(DayKey day) async {
    final q = _db.select(_db.prayerLogs)..where((t) => t.date.equals(day.value));
    final rows = await q.get();
    return {for (final r in rows) r.prayer: r.status};
  }

  /// Inclusive range of days.
  Stream<List<PrayerLog>> watchRange(DayKey from, DayKey to) =>
      _rangeQuery(from, to).watch().map(_toLogs);

  Future<List<PrayerLog>> getRange(DayKey from, DayKey to) async =>
      _toLogs(await _rangeQuery(from, to).get());

  /// Earliest day the user ever marked anything (for stats denominators).
  Future<DayKey?> firstLoggedDay() async {
    final min = _db.prayerLogs.date.min();
    final row = await (_db.selectOnly(_db.prayerLogs)..addColumns([min])).getSingle();
    final v = row.read(min);
    return v == null ? null : DayKey(v);
  }

  SimpleSelectStatement<$PrayerLogsTable, PrayerLogRow> _rangeQuery(DayKey from, DayKey to) =>
      _db.select(_db.prayerLogs)
        ..where((t) => t.date.isBetweenValues(from.value, to.value))
        ..orderBy([(t) => OrderingTerm.asc(t.date)]);

  List<PrayerLog> _toLogs(List<PrayerLogRow> rows) =>
      [for (final r in rows) PrayerLog(DayKey(r.date), r.prayer, r.status, r.markedAt)];

  /// Sets (or with [status] == null clears) the mark for a prayer and applies
  /// the qada consequence from [QadaRules.deltaForTransition].
  Future<void> mark(DayKey day, Prayer prayer, PrayerStatus? status, {DateTime? now}) {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.prayerLogs)
            ..where((t) => t.date.equals(day.value) & t.prayer.equalsValue(prayer)))
          .getSingleOrNull();
      final from = existing?.status;
      if (from == status) return;

      if (status == null) {
        await (_db.delete(_db.prayerLogs)..where((t) => t.id.equals(existing!.id))).go();
      } else {
        await _db.into(_db.prayerLogs).insert(
              PrayerLogsCompanion.insert(
                date: day.value,
                prayer: prayer,
                status: status,
                markedAt: now ?? DateTime.now(),
              ),
              onConflict: DoUpdate(
                (_) => PrayerLogsCompanion(
                  status: Value(status),
                  markedAt: Value(now ?? DateTime.now()),
                ),
                target: [_db.prayerLogs.date, _db.prayerLogs.prayer],
              ),
            );
      }

      final delta = QadaRules.deltaForTransition(from, status);
      if (delta != 0) {
        await _changeQada(prayer, delta, QadaSource.missedMarked, now: now);
      }
    });
  }

  /// Marks several (day, prayer) pairs with one status (e.g. "All prayed",
  /// period-mode auto-excuse). Each goes through [mark] for qada consistency.
  Future<void> markMany(Iterable<(DayKey, Prayer)> items, PrayerStatus status, {DateTime? now}) =>
      _db.transaction(() async {
        for (final (day, prayer) in items) {
          await mark(day, prayer, status, now: now);
        }
      });

  // ------------------------------------------------------------------- qada

  Stream<Map<Prayer, int>> watchQadaCounts() =>
      _db.select(_db.qadaCounts).watch().map(_countsMap);

  Future<Map<Prayer, int>> getQadaCounts() async => _countsMap(await _db.select(_db.qadaCounts).get());

  Map<Prayer, int> _countsMap(List<QadaCountRow> rows) {
    final m = {for (final p in Prayer.values) p: 0};
    for (final r in rows) {
      m[r.prayer] = r.remaining;
    }
    return m;
  }

  /// "Made up" button. Returns false when nothing was left for that prayer.
  Future<bool> makeUp(Prayer prayer, {DateTime? now}) => _db.transaction(() async {
        final current = await _remaining(prayer);
        if (QadaRules.makeUp(current) == null) return false;
        await _changeQada(prayer, -1, QadaSource.madeUp, now: now);
        return true;
      });

  /// "+ Add older missed prayers": one event per prayer with delta = count.
  Future<void> addOlder(Map<Prayer, int> counts, {DateTime? now}) => _db.transaction(() async {
        for (final e in counts.entries) {
          if (e.value > 0) await _changeQada(e.key, e.value, QadaSource.manualAdd, now: now);
        }
      });

  /// Total prayers made up since the user started (sum of madeUp events).
  Stream<int> watchMadeUpTotal() {
    final count = _db.qadaEvents.id.count();
    final q = _db.selectOnly(_db.qadaEvents)
      ..addColumns([count])
      ..where(_db.qadaEvents.source.equalsValue(QadaSource.madeUp));
    return q.watchSingle().map((r) => r.read(count) ?? 0);
  }

  /// Made-up counts per local day in [from, toExclusive).
  Stream<Map<DayKey, int>> watchMadeUpByDay(DateTime from, DateTime toExclusive) {
    final q = _db.select(_db.qadaEvents)
      ..where((t) =>
          t.source.equalsValue(QadaSource.madeUp) &
          t.createdAt.isBiggerOrEqualValue(from) &
          t.createdAt.isSmallerThanValue(toExclusive));
    return q.watch().map((rows) {
      final m = <DayKey, int>{};
      for (final r in rows) {
        final k = DayKey.fromDate(r.createdAt.toLocal());
        m[k] = (m[k] ?? 0) + 1;
      }
      return m;
    });
  }

  Future<int> _remaining(Prayer prayer) async {
    final row = await (_db.select(_db.qadaCounts)..where((t) => t.prayer.equalsValue(prayer)))
        .getSingleOrNull();
    return row?.remaining ?? 0;
  }

  Future<void> _changeQada(Prayer prayer, int delta, QadaSource source, {DateTime? now}) async {
    final current = await _remaining(prayer);
    final next = QadaRules.apply(current, delta);
    if (next == current) return;
    await _db.into(_db.qadaCounts).insertOnConflictUpdate(
          QadaCountsCompanion.insert(prayer: prayer, remaining: Value(next)),
        );
    await _db.into(_db.qadaEvents).insert(
          QadaEventsCompanion.insert(
            prayer: prayer,
            delta: next - current,
            source: source,
            createdAt: now ?? DateTime.now(),
          ),
        );
  }
}

final prayerRepositoryProvider =
    Provider<PrayerRepository>((ref) => PrayerRepository(ref.watch(databaseProvider)));
