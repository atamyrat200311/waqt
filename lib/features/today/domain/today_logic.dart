import '../../../data/db/enums.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../prayer/domain/prayer_engine.dart';

/// Visual state of a prayer chip / timeline row. States differ by shape.
enum ChipState {
  /// Prayed (any form): filled brass circle + check.
  done,

  /// Window open now and unmarked: brass ring + dot.
  current,

  /// Not started yet: dashed circle at 74 %.
  upcoming,

  /// Window passed, nothing marked: dashed circle at full opacity.
  unmarked,

  /// Marked missed (in qada).
  missed,

  /// Period mode.
  excused,
}

ChipState chipState(Prayer p, PrayerStatus? status, PrayerNow now) {
  if (status != null) {
    if (status.isPrayed) return ChipState.done;
    if (status == PrayerStatus.missed) return ChipState.missed;
    return ChipState.excused;
  }
  final w = now.current;
  if (w != null && w.prayer == p && w.day == now.today.date) return ChipState.current;
  return now.hasStarted(p) ? ChipState.unmarked : ChipState.upcoming;
}

/// Which adhkar set the "Up next" card offers, or null for none.
///
/// Morning: Fajr → Dhuhr. Evening: shown (as upcoming) from Dhuhr and due
/// from Asr until midnight. Nothing before Fajr.
AdhkarSet? adhkarUpNext(PrayerNow now, {required bool morningDone, required bool eveningDone}) {
  final d = now.today;
  final t = now.now;
  if (t.isBefore(d.fajr)) return null;
  if (t.isBefore(d[Prayer.dhuhr])) {
    if (!morningDone) return AdhkarSet.morning;
    return eveningDone ? null : AdhkarSet.evening;
  }
  return eveningDone ? null : AdhkarSet.evening;
}

/// What the hero card counts down to.
class HeroTarget {
  const HeroTarget({required this.prayer, required this.time, required this.iftar});
  final Prayer prayer;
  final DateTime time;

  /// Ramadan: counting down to iftar (Maghrib) instead of the next prayer.
  final bool iftar;
}

HeroTarget heroTarget(PrayerNow now, {required bool ramadan}) {
  final d = now.today;
  final maghrib = d[Prayer.maghrib];
  if (ramadan && !now.now.isBefore(d.fajr) && now.now.isBefore(maghrib)) {
    return HeroTarget(prayer: Prayer.maghrib, time: maghrib, iftar: true);
  }
  return HeroTarget(prayer: now.next.prayer, time: now.next.time, iftar: false);
}

/// Countdown parts as shown on the hero: minutes rounded up ("in 1h 12m").
({int hours, int minutes}) countdownParts(Duration d) {
  final totalMin = d.isNegative ? 0 : (d.inSeconds / 60).ceil();
  return (hours: totalMin ~/ 60, minutes: totalMin % 60);
}

/// Task window that fits "now" (default when adding a task).
TaskWindow defaultTaskWindow(PrayerNow now) {
  final d = now.today;
  final t = now.now;
  if (t.isBefore(d.fajr)) return TaskWindow.beforeFajr;
  if (t.isBefore(d.sunrise)) return TaskWindow.afterFajr;
  if (t.isBefore(d[Prayer.dhuhr])) return TaskWindow.beforeDhuhr;
  if (t.isBefore(d[Prayer.asr])) return TaskWindow.afterDhuhr;
  if (t.isBefore(d[Prayer.maghrib])) return TaskWindow.afterAsr;
  if (t.isBefore(d.isha)) return TaskWindow.afterMaghrib;
  return TaskWindow.afterIsha;
}

/// Time span of a task window on a day: (from, until); either may be null
/// ("until 12:39", "from 15:57"); both null for "anytime".
(DateTime?, DateTime?) taskWindowSpan(TaskWindow w, PrayerDay d) => switch (w) {
      TaskWindow.beforeFajr => (null, d.fajr),
      TaskWindow.afterFajr => (d.fajr, d[Prayer.dhuhr]),
      TaskWindow.beforeDhuhr => (null, d[Prayer.dhuhr]),
      TaskWindow.afterDhuhr => (d[Prayer.dhuhr], d[Prayer.asr]),
      TaskWindow.afterAsr => (d[Prayer.asr], null),
      TaskWindow.afterMaghrib => (d[Prayer.maghrib], null),
      TaskWindow.afterIsha => (d.isha, null),
      TaskWindow.anytime => (null, null),
    };

/// Prayers of a past day with no mark at all.
List<Prayer> unmarkedPrayers(Map<Prayer, PrayerStatus> marks) =>
    [for (final p in Prayer.values) if (!marks.containsKey(p)) p];
