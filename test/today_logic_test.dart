import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:waqt/data/db/enums.dart';
import 'package:waqt/features/adhkar/domain/adhkar.dart';
import 'package:waqt/features/prayer/application/prayer_providers.dart';
import 'package:waqt/features/prayer/domain/prayer_engine.dart';
import 'package:waqt/features/today/domain/today_logic.dart';

void main() {
  setUpAll(ensureTimeZones);

  final engine = PrayerEngine(PrayerConfig(
    latitude: 37.9601,
    longitude: 58.3261,
    location: locationFor('Asia/Ashgabat'),
  ));
  final day = engine.day(DateTime(2026, 10, 4));
  PrayerNow at(DateTime t) => prayerNowAt(engine, t);
  DateTime after(Prayer p, [int min = 1]) => day[p].add(Duration(minutes: min));

  group('chipState', () {
    test('done / missed / excused come from the mark', () {
      final n = at(after(Prayer.asr));
      expect(chipState(Prayer.fajr, PrayerStatus.late, n), ChipState.done);
      expect(chipState(Prayer.fajr, PrayerStatus.missed, n), ChipState.missed);
      expect(chipState(Prayer.fajr, PrayerStatus.excused, n), ChipState.excused);
    });

    test('open window is current; passed is unmarked; later is upcoming', () {
      final n = at(after(Prayer.asr));
      expect(chipState(Prayer.asr, null, n), ChipState.current);
      expect(chipState(Prayer.dhuhr, null, n), ChipState.unmarked);
      expect(chipState(Prayer.isha, null, n), ChipState.upcoming);
    });

    test('between sunrise and Dhuhr nothing is current', () {
      final n = at(day.sunrise.add(const Duration(minutes: 30)));
      expect(chipState(Prayer.fajr, null, n), ChipState.unmarked);
      expect(chipState(Prayer.dhuhr, null, n), ChipState.upcoming);
    });

    test("after midnight, yesterday's Isha window does not ring today's Isha", () {
      final n = at(tz.TZDateTime(locationFor('Asia/Ashgabat'), 2026, 10, 5, 1));
      expect(chipState(Prayer.isha, null, n), ChipState.upcoming);
    });
  });

  group('adhkar up next', () {
    test('morning after Fajr, evening from Dhuhr, none when both done', () {
      expect(adhkarUpNext(at(after(Prayer.fajr)), morningDone: false, eveningDone: false), AdhkarSet.morning);
      expect(adhkarUpNext(at(after(Prayer.fajr)), morningDone: true, eveningDone: false), AdhkarSet.evening);
      expect(adhkarUpNext(at(after(Prayer.dhuhr)), morningDone: false, eveningDone: false), AdhkarSet.evening);
      expect(adhkarUpNext(at(after(Prayer.isha)), morningDone: true, eveningDone: true), isNull);
      expect(adhkarUpNext(at(day.fajr.subtract(const Duration(minutes: 5))), morningDone: false, eveningDone: false), isNull);
    });
  });

  group('hero', () {
    test('counts down to the next prayer, or to iftar during a Ramadan day', () {
      final n = at(after(Prayer.dhuhr, 10));
      expect(heroTarget(n, ramadan: false).prayer, Prayer.asr);
      final r = heroTarget(n, ramadan: true);
      expect(r.iftar, isTrue);
      expect(r.time, day[Prayer.maghrib]);
      expect(heroTarget(at(after(Prayer.maghrib)), ramadan: true).iftar, isFalse);
    });

    test('countdown rounds minutes up', () {
      expect(countdownParts(const Duration(hours: 1, minutes: 11, seconds: 1)), (hours: 1, minutes: 12));
      expect(countdownParts(const Duration(seconds: 59)), (hours: 0, minutes: 1));
      expect(countdownParts(const Duration(seconds: -5)), (hours: 0, minutes: 0));
    });
  });

  test('default task window follows the time of day', () {
    expect(defaultTaskWindow(at(after(Prayer.fajr))), TaskWindow.afterFajr);
    expect(defaultTaskWindow(at(day.sunrise.add(const Duration(hours: 1)))), TaskWindow.beforeDhuhr);
    expect(defaultTaskWindow(at(after(Prayer.asr))), TaskWindow.afterAsr);
    expect(defaultTaskWindow(at(after(Prayer.isha))), TaskWindow.afterIsha);
    final (from, until) = taskWindowSpan(TaskWindow.afterDhuhr, day);
    expect(from, day[Prayer.dhuhr]);
    expect(until, day[Prayer.asr]);
  });

  test('unmarked prayers', () {
    expect(unmarkedPrayers({Prayer.fajr: PrayerStatus.onTime, Prayer.isha: PrayerStatus.excused}),
        [Prayer.dhuhr, Prayer.asr, Prayer.maghrib]);
  });

  group('adhkar progress', () {
    const items = [
      AdhkarItem(id: 'a', arabic: 'سُبْحَانَ اللَّهِ', transliteration: '', translations: {'en': 'x'}, count: 3, source: ''),
      AdhkarItem(id: 'b', arabic: 'الْحَمْدُ لِلَّهِ', transliteration: '', translations: {'en': 'y'}, count: 1, source: ''),
    ];

    test('completion, resume index and fraction', () {
      const p = AdhkarProgress(items, {'a': 3});
      expect(p.isComplete, isFalse);
      expect(p.resumeIndex, 1);
      expect(p.fraction, 0.5);
      expect(const AdhkarProgress(items, {'a': 5, 'b': 1}).isComplete, isTrue);
      expect(items.first.translation('tk'), 'x');
    });
  });
}
