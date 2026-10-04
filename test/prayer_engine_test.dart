import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/data/db/enums.dart';
import 'package:waqt/features/prayer/application/prayer_providers.dart';
import 'package:waqt/features/prayer/domain/method_presets.dart';
import 'package:waqt/features/prayer/domain/period_mode.dart';
import 'package:waqt/features/prayer/domain/prayer_engine.dart';

PrayerEngine ashgabat({Map<Prayer, int> offsets = const {}, AsrMadhab madhab = AsrMadhab.hanafi}) =>
    PrayerEngine(PrayerConfig(
      latitude: 37.9601,
      longitude: 58.3261,
      location: locationFor('Asia/Ashgabat'),
      madhab: madhab,
      offsets: offsets,
    ));

/// Instant for a wall-clock time in Ashgabat (UTC+5, no DST).
DateTime ash(int y, int m, int d, int h, [int min = 0]) =>
    tz.TZDateTime(locationFor('Asia/Ashgabat'), y, m, d, h, min);

void main() {
  setUpAll(ensureTimeZones);

  group('PrayerEngine (Ashgabat, MWL + Hanafi)', () {
    final e = ashgabat();
    final day = e.day(DateTime(2026, 10, 4));

    test('times are in order and in the location zone', () {
      final seq = [day.fajr, day.sunrise, day[Prayer.dhuhr], day[Prayer.asr], day[Prayer.maghrib], day.isha];
      for (var i = 1; i < seq.length; i++) {
        expect(seq[i].isAfter(seq[i - 1]), isTrue, reason: 'index $i');
      }
      expect(day.fajr.location.name, 'Asia/Ashgabat');
      expect(day.fajr.timeZoneOffset, const Duration(hours: 5));
    });

    test('Dhuhr is near solar noon (≈12:56 in early October)', () {
      final d = day[Prayer.dhuhr];
      final minutes = d.hour * 60 + d.minute;
      expect(minutes, inInclusiveRange(12 * 60 + 52, 13 * 60 + 1));
    });

    test('Hanafi Asr is later than standard Asr', () {
      final std = ashgabat(madhab: AsrMadhab.standard).day(DateTime(2026, 10, 4));
      expect(day[Prayer.asr].isAfter(std[Prayer.asr]), isTrue);
    });

    test('per-prayer offsets shift only that prayer', () {
      final shifted = ashgabat(offsets: {Prayer.isha: 5}).day(DateTime(2026, 10, 4));
      expect(shifted.isha.difference(day.isha), const Duration(minutes: 5));
      expect(shifted.fajr, day.fajr);
    });

    test('next prayer and after-Isha rolls to tomorrow Fajr', () {
      final afterDhuhr = day[Prayer.dhuhr].add(const Duration(minutes: 1));
      expect(e.next(afterDhuhr).prayer, Prayer.asr);
      expect(e.next(afterDhuhr).tomorrow, isFalse);

      final late = day.isha.add(const Duration(minutes: 30));
      final n = e.next(late);
      expect(n.prayer, Prayer.fajr);
      expect(n.tomorrow, isTrue);
      expect(n.time.day, 5);
    });

    test('windows: Fajr→sunrise, none between sunrise and Dhuhr, Isha past midnight', () {
      expect(e.currentWindow(day.fajr.add(const Duration(minutes: 5)))!.prayer, Prayer.fajr);
      expect(e.currentWindow(day.sunrise.add(const Duration(minutes: 5))), isNull);
      final asr = e.currentWindow(day[Prayer.asr].add(const Duration(minutes: 1)))!;
      expect(asr.prayer, Prayer.asr);
      expect(asr.end, day[Prayer.maghrib]);

      final afterMidnight = ash(2026, 10, 5, 1);
      final w = e.currentWindow(afterMidnight)!;
      expect(w.prayer, Prayer.isha);
      expect(DayKey.fromDate(w.day).value, '2026-10-04');
    });

    test('arc progress is 0 at Fajr, 1 at Isha, clamped outside', () {
      expect(PrayerEngine.arcProgress(day, day.fajr), 0);
      expect(PrayerEngine.arcProgress(day, day.isha), 1);
      expect(PrayerEngine.arcProgress(day, ash(2026, 10, 4, 2)), 0);
      final pts = PrayerEngine.arcPoints(day);
      expect(pts[Prayer.dhuhr]! < pts[Prayer.asr]!, isTrue);
    });
  });

  test('a manual city in another zone shows that city\'s wall-clock times', () {
    final istanbul = PrayerEngine(PrayerConfig(
      latitude: 41.0082,
      longitude: 28.9784,
      location: locationFor('Europe/Istanbul'),
      method: CalcMethod.turkey,
    ));
    final d = istanbul.day(DateTime(2026, 10, 4));
    // Istanbul Dhuhr in early October is around 12:55 local.
    expect(d[Prayer.dhuhr].hour, anyOf(12, 13));
    expect(d[Prayer.dhuhr].timeZoneOffset, const Duration(hours: 3));
  });

  test('high latitudes use seventh-of-the-night', () {
    expect(PrayerEngine.highLatitudeRuleFor(60).name, 'seventh_of_the_night');
    expect(PrayerEngine.highLatitudeRuleFor(38).name, 'middle_of_the_night');
  });

  test('unknown time-zone ids fall back to UTC', () {
    expect(locationFor('Mars/Olympus').currentTimeZone.offset, Duration.zero);
  });

  group('method presets', () {
    test('Central Asia → MWL + Hanafi', () {
      final p = presetForRegion(countryCode: 'TM');
      expect(p.method, CalcMethod.muslimWorldLeague);
      expect(p.madhab, AsrMadhab.hanafi);
      expect(presetForRegion(timezone: 'Asia/Tashkent').madhab, AsrMadhab.hanafi);
    });

    test('Turkey → Diyanet, Saudi → Umm al-Qura', () {
      expect(presetForRegion(countryCode: 'TR').method, CalcMethod.turkey);
      expect(presetForRegion(timezone: 'Asia/Riyadh').method, CalcMethod.ummAlQura);
    });
  });

  group('period mode auto-excuse', () {
    final e = ashgabat();
    const today = DayKey('2026-10-04');

    test('only passed, unmarked prayers since the start day', () {
      final now = e.day(today.date)[Prayer.asr].add(const Duration(minutes: 1));
      final items = prayersToExcuse(
        engine: e,
        since: today.addDays(-1),
        now: now,
        marked: {
          today: {Prayer.fajr},
        },
      );
      final yesterday = items.where((i) => i.$1 == today.addDays(-1));
      expect(yesterday, hasLength(5));
      final todays = items.where((i) => i.$1 == today).map((i) => i.$2);
      expect(todays, [Prayer.dhuhr, Prayer.asr]);
    });

    test('looks back at most 14 days', () {
      final now = ash(2026, 10, 4, 3);
      final items = prayersToExcuse(engine: e, since: const DayKey('2026-01-01'), now: now, marked: const {});
      expect(items.first.$1, const DayKey('2026-09-21'));
    });
  });
}
