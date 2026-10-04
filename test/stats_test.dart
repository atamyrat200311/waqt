import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/data/db/enums.dart';
import 'package:waqt/features/me/domain/stats.dart';

Map<Prayer, PrayerStatus> all(PrayerStatus s) => {for (final p in Prayer.values) p: s};

void main() {
  const today = DayKey('2026-10-04');
  DayKey ago(int n) => today.addDays(-n);

  group('classifyDay', () {
    test('kept / broken / skipped / pending', () {
      expect(classifyDay(all(PrayerStatus.late)), StreakDay.kept);
      expect(classifyDay({...all(PrayerStatus.onTime), Prayer.asr: PrayerStatus.missed}), StreakDay.broken);
      expect(classifyDay(all(PrayerStatus.excused)), StreakDay.skipped);
      expect(classifyDay({...all(PrayerStatus.excused), Prayer.fajr: PrayerStatus.onTime}), StreakDay.kept);
      expect(classifyDay({Prayer.fajr: PrayerStatus.onTime}), StreakDay.broken);
      expect(classifyDay({Prayer.fajr: PrayerStatus.onTime}, isToday: true), StreakDay.pending);
    });
  });

  group('computeStreak', () {
    test('incomplete today does not break; counts back through yesterday', () {
      final byDay = {
        ago(3): all(PrayerStatus.onTime),
        ago(2): all(PrayerStatus.congregation),
        ago(1): all(PrayerStatus.late),
        today: {Prayer.fajr: PrayerStatus.onTime},
      };
      final s = computeStreak(byDay, today: today);
      expect(s.current, 3);
      expect(s.lastDays.last, StreakDay.pending);
      expect(s.lastDays, hasLength(14));
    });

    test('complete today counts once', () {
      final s = computeStreak({ago(1): all(PrayerStatus.onTime), today: all(PrayerStatus.onTime)}, today: today);
      expect(s.current, 2);
    });

    test('excused days neither break nor extend', () {
      final byDay = {
        ago(4): all(PrayerStatus.onTime),
        ago(3): all(PrayerStatus.excused),
        ago(2): all(PrayerStatus.excused),
        ago(1): all(PrayerStatus.onTime),
      };
      expect(computeStreak(byDay, today: today).current, 2);
    });

    test('a missed day breaks; best remembers the longest run', () {
      final byDay = {
        ago(10): all(PrayerStatus.onTime),
        ago(9): all(PrayerStatus.onTime),
        ago(8): all(PrayerStatus.onTime),
        ago(7): all(PrayerStatus.onTime),
        ago(6): {...all(PrayerStatus.onTime), Prayer.isha: PrayerStatus.missed},
        ago(5): all(PrayerStatus.onTime),
        ago(4): all(PrayerStatus.onTime),
        ago(3): all(PrayerStatus.onTime),
        ago(2): all(PrayerStatus.onTime),
        ago(1): all(PrayerStatus.onTime),
      };
      final s = computeStreak(byDay, today: today);
      expect(s.current, 5);
      expect(s.best, 5);
      expect(computeStreak(byDay..remove(ago(1)), today: today).current, 0);
    });

    test('a gap day (nothing marked) breaks the streak', () {
      final s = computeStreak({ago(3): all(PrayerStatus.onTime), ago(1): all(PrayerStatus.onTime)}, today: today);
      expect(s.current, 1);
      expect(s.best, 1);
    });
  });

  test('consistency excludes excused days and prayers not started yet', () {
    final byDay = {
      ago(2): {...all(PrayerStatus.onTime), Prayer.fajr: PrayerStatus.missed},
      ago(1): {...all(PrayerStatus.late), Prayer.fajr: PrayerStatus.excused},
      today: {Prayer.fajr: PrayerStatus.onTime},
    };
    final c = consistency(
      byDay,
      from: ago(2),
      to: today,
      hasStarted: (d, p) => d != today || p == Prayer.fajr,
    );
    expect(c[Prayer.fajr], 0.5); // missed, (excused skipped), prayed
    expect(c[Prayer.dhuhr], 1.0); // two days; today's Dhuhr hasn't started
    expect(weakestPrayer(c), Prayer.fajr);
  });

  test('on-time share ignores excused', () {
    expect(onTimeShare([PrayerStatus.onTime, PrayerStatus.late, PrayerStatus.excused, PrayerStatus.congregation]), 2 / 3);
    expect(onTimeShare(const []), isNull);
  });

  test('adhkar streak starts from yesterday until today is complete', () {
    final days = {ago(1), ago(2), ago(4)};
    expect(adhkarStreak(days, today), 2);
    expect(adhkarStreak({...days, today}, today), 3);
    expect(adhkarStreak(const {}, today), 0);
  });
}
