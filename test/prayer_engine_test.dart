import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/data/db/enums.dart';
import 'package:waqt/features/prayer/application/prayer_providers.dart';
import 'package:waqt/features/prayer/domain/method_presets.dart';
import 'package:waqt/features/prayer/domain/period_mode.dart';
import 'package:waqt/features/prayer/domain/prayer_engine.dart';
import 'package:waqt/features/prayer/domain/tm_times.dart';

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

    String hm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    test('Turkmenistan uses the official table, not calculation', () {
      expect(e.usesTurkmenTable, isTrue);
      // tm_wagt_default.json, Ashgabat, 1 July.
      final july = e.day(DateTime(2026, 7, 1));
      expect(
        [july.imsak, july.fajr, july.sunrise, july[Prayer.dhuhr], july[Prayer.asr], july[Prayer.maghrib], july.isha]
            .map(hm),
        ['03:57', '04:37', '05:47', '13:30', '19:05', '20:45', '22:05'],
      );
      // Dhuhr is 13:30 all year in Ashgabat.
      expect(hm(day[Prayer.dhuhr]), '13:30');
    });

    test('method and madhab do not change table times', () {
      final std = ashgabat(madhab: AsrMadhab.standard).day(DateTime(2026, 10, 4));
      expect(std[Prayer.asr], day[Prayer.asr]);
    });

    test('nearest of the five table cities; 29 February has its own row', () {
      PrayerEngine at(double lat, double lng) =>
          PrayerEngine(PrayerConfig(latitude: lat, longitude: lng, location: locationFor('Asia/Ashgabat')));
      final mary = at(37.5936, 61.8303).day(DateTime(2026, 7, 1));
      final bayramaly = at(37.6185, 62.1673).day(DateTime(2026, 7, 1)); // nearest: Mary
      expect(bayramaly.fajr, mary.fajr);
      expect(mary.fajr, isNot(e.day(DateTime(2026, 7, 1)).fajr));
      final feb28 = e.day(DateTime(2028, 2, 28));
      final feb29 = e.day(DateTime(2028, 2, 29));
      final mar1 = e.day(DateTime(2028, 3, 1));
      expect(feb29.fajr.day, 29);
      expect(hm(e.day(DateTime(2027, 3, 1)).fajr), hm(mar1.fajr)); // same row in non-leap years
      expect(TmTable.dayIndex(DateTime(2028, 2, 29)), 59);
      expect(TmTable.dayIndex(DateTime(2027, 3, 1)), 60);
      expect(feb28.fajr.day, 28);
    });

    test('a place outside Turkmenistan is calculated', () {
      final tashkent = PrayerEngine(PrayerConfig(
        latitude: 41.2995,
        longitude: 69.2401,
        location: locationFor('Asia/Tashkent'),
      ));
      expect(tashkent.usesTurkmenTable, isFalse);
      expect(tashkent.day(DateTime(2026, 7, 1)).imsak, tashkent.day(DateTime(2026, 7, 1)).fajr);
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
