import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/data/db/enums.dart';
import 'package:waqt/data/repositories/prayer_repository.dart';
import 'package:waqt/features/prayer/domain/qada_rules.dart';

import 'helpers/test_db.dart';

void main() {
  group('QadaRules.deltaForTransition', () {
    test('only "missed" creates qada', () {
      expect(QadaRules.deltaForTransition(null, PrayerStatus.missed), 1);
      for (final s in PrayerStatus.values.where((s) => s != PrayerStatus.missed)) {
        expect(QadaRules.deltaForTransition(null, s), 0, reason: '$s');
      }
    });

    test('changing away from missed gives it back', () {
      expect(QadaRules.deltaForTransition(PrayerStatus.missed, PrayerStatus.late), -1);
      expect(QadaRules.deltaForTransition(PrayerStatus.missed, null), -1);
      expect(QadaRules.deltaForTransition(PrayerStatus.missed, PrayerStatus.missed), 0);
    });

    test('excused (period mode) never creates qada', () {
      expect(QadaRules.deltaForTransition(null, PrayerStatus.excused), 0);
      expect(QadaRules.deltaForTransition(PrayerStatus.onTime, PrayerStatus.excused), 0);
    });

    test('apply and makeUp never go below zero', () {
      expect(QadaRules.apply(0, -1), 0);
      expect(QadaRules.apply(3, -1), 2);
      expect(QadaRules.makeUp(0), isNull);
      expect(QadaRules.makeUp(1), 0);
    });
  });

  group('PrayerRepository (sqlite in memory)', () {
    late PrayerRepository repo;
    const day = DayKey('2026-10-04');

    setUp(() => repo = PrayerRepository(memoryDb()));

    test('marking missed adds one qada and an event; re-marking is idempotent', () async {
      await repo.mark(day, Prayer.asr, PrayerStatus.missed);
      await repo.mark(day, Prayer.asr, PrayerStatus.missed);
      expect((await repo.getQadaCounts())[Prayer.asr], 1);
      expect((await repo.getDay(day))[Prayer.asr], PrayerStatus.missed);
    });

    test('correcting missed → on time removes the qada again', () async {
      await repo.mark(day, Prayer.isha, PrayerStatus.missed);
      await repo.mark(day, Prayer.isha, PrayerStatus.onTime);
      expect((await repo.getQadaCounts())[Prayer.isha], 0);
      expect((await repo.getDay(day))[Prayer.isha], PrayerStatus.onTime);
    });

    test('unique (date, prayer): one row per prayer per day', () async {
      await repo.mark(day, Prayer.fajr, PrayerStatus.late);
      await repo.mark(day, Prayer.fajr, PrayerStatus.congregation);
      final logs = await repo.getRange(day, day);
      expect(logs.where((l) => l.prayer == Prayer.fajr), hasLength(1));
    });

    test('clearing a mark deletes the row', () async {
      await repo.mark(day, Prayer.dhuhr, PrayerStatus.onTime);
      await repo.mark(day, Prayer.dhuhr, null);
      expect(await repo.getDay(day), isEmpty);
    });

    test('excused marks never create qada', () async {
      await repo.markMany([for (final p in Prayer.values) (day, p)], PrayerStatus.excused);
      final counts = await repo.getQadaCounts();
      expect(counts.values.every((c) => c == 0), isTrue);
    });

    test('made up decrements, never below zero, and is counted', () async {
      await repo.addOlder({Prayer.fajr: 2});
      expect(await repo.makeUp(Prayer.fajr), isTrue);
      expect(await repo.makeUp(Prayer.fajr), isTrue);
      expect(await repo.makeUp(Prayer.fajr), isFalse);
      expect((await repo.getQadaCounts())[Prayer.fajr], 0);
      expect(await repo.watchMadeUpTotal().first, 2);
    });

    test('undoing a missed mark after making it up does not go negative', () async {
      await repo.mark(day, Prayer.maghrib, PrayerStatus.missed);
      await repo.makeUp(Prayer.maghrib);
      await repo.mark(day, Prayer.maghrib, PrayerStatus.onTime);
      expect((await repo.getQadaCounts())[Prayer.maghrib], 0);
    });

    test('made-up events are grouped by local day', () async {
      final now = DateTime(2026, 10, 4, 15);
      await repo.addOlder({Prayer.asr: 3}, now: now);
      await repo.makeUp(Prayer.asr, now: now);
      await repo.makeUp(Prayer.asr, now: now.add(const Duration(days: 1)));
      final byDay = await repo
          .watchMadeUpByDay(DateTime(2026, 10, 1), DateTime(2026, 10, 8))
          .first;
      expect(byDay[const DayKey('2026-10-04')], 1);
      expect(byDay[const DayKey('2026-10-05')], 1);
    });
  });
}
