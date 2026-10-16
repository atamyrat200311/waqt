import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/dates.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';

/// Reading log (which ayahs were read on which day) and the memorization
/// ladder.
class QuranRepository {
  QuranRepository(this._db);

  final AppDatabase _db;

  /// Records ayahs (global indexes) as read on [day]. Idempotent.
  Future<void> markRead(DayKey day, Iterable<int> ayahs) async {
    final list = ayahs.toSet();
    if (list.isEmpty) return;
    await _db.batch((b) {
      b.insertAll(
        _db.quranReads,
        [for (final a in list) QuranReadsCompanion.insert(date: day.value, ayah: a)],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  /// Distinct ayahs read per day in the inclusive range.
  Stream<Map<DayKey, int>> watchDailyCounts(DayKey from, DayKey to) {
    final count = _db.quranReads.ayah.count();
    final q = _db.selectOnly(_db.quranReads)
      ..addColumns([_db.quranReads.date, count])
      ..where(_db.quranReads.date.isBetweenValues(from.value, to.value))
      ..groupBy([_db.quranReads.date]);
    return q.watch().map((rows) => {
          for (final r in rows) DayKey(r.read(_db.quranReads.date)!): r.read(count) ?? 0,
        });
  }

  /// Distinct ayahs read on or after [since] (khatm progress).
  Stream<int> watchDistinctSince(DayKey since) {
    final count = _db.quranReads.ayah.count(distinct: true);
    final q = _db.selectOnly(_db.quranReads)
      ..addColumns([count])
      ..where(_db.quranReads.date.isBiggerOrEqualValue(since.value));
    return q.watchSingle().map((r) => r.read(count) ?? 0);
  }

  /// Every day with at least one ayah read (for the streak).
  Stream<Set<String>> watchReadingDays() {
    final q = _db.selectOnly(_db.quranReads, distinct: true)..addColumns([_db.quranReads.date]);
    return q.watch().map((rows) => {for (final r in rows) r.read(_db.quranReads.date)!});
  }

  /// Ayahs read since [since] (to mark them in the reader / surah list).
  Stream<Set<int>> watchReadSince(DayKey since) {
    final q = _db.selectOnly(_db.quranReads, distinct: true)
      ..addColumns([_db.quranReads.ayah])
      ..where(_db.quranReads.date.isBiggerOrEqualValue(since.value));
    return q.watch().map((rows) => {for (final r in rows) r.read(_db.quranReads.ayah)!});
  }

  /// Ayahs whose first read on or after [since] happened on [day] (new
  /// reading for the khatm; re-reading old ayahs does not count).
  Stream<Set<int>> watchFirstReadOn(DayKey since, DayKey day) {
    return _db
        .customSelect(
          'SELECT ayah FROM quran_reads WHERE date >= ? GROUP BY ayah HAVING MIN(date) = ?',
          variables: [Variable.withString(since.value), Variable.withString(day.value)],
          readsFrom: {_db.quranReads},
        )
        .watch()
        .map((rows) => {for (final r in rows) r.read<int>('ayah')});
  }

  // ------------------------------------------------------------ hifz

  Stream<List<HifzRow>> watchHifz() =>
      (_db.select(_db.hifzItems)..orderBy([(t) => OrderingTerm.asc(t.nextReview), (t) => OrderingTerm.asc(t.surah)]))
          .watch();

  Future<void> upsertHifz(int surah, HifzStatus status, int step, DayKey nextReview, {DateTime? now}) {
    return _db.into(_db.hifzItems).insertOnConflictUpdate(HifzItemsCompanion.insert(
          surah: Value(surah),
          status: status,
          step: Value(step),
          nextReview: nextReview.value,
          updatedAt: now ?? DateTime.now(),
        ));
  }

  Future<void> removeHifz(int surah) => (_db.delete(_db.hifzItems)..where((t) => t.surah.equals(surah))).go();
}

final quranRepositoryProvider = Provider<QuranRepository>((ref) => QuranRepository(ref.watch(databaseProvider)));
