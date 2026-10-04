import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import 'prayer_engine.dart';

/// Period mode: prayers whose time has come since the mode was switched on
/// and that are still unmarked get `excused`. Pure; the caller writes them.
///
/// [since] is the day period mode was switched on; [marked] holds existing
/// marks per day. Never looks back more than [maxDays] (in case the mode was
/// left on for a long time without opening the app).
List<(DayKey, Prayer)> prayersToExcuse({
  required PrayerEngine engine,
  required DayKey since,
  required DateTime now,
  required Map<DayKey, Set<Prayer>> marked,
  int maxDays = 14,
}) {
  final today = DayKey.fromDate(engine.localDate(now));
  var day = since;
  final earliest = today.addDays(-(maxDays - 1));
  if (day.isBefore(earliest)) day = earliest;
  final out = <(DayKey, Prayer)>[];
  while (!day.isAfter(today)) {
    final times = engine.day(day.date);
    final done = marked[day] ?? const {};
    for (final p in Prayer.values) {
      if (!times[p].isAfter(now) && !done.contains(p)) out.add((day, p));
    }
    day = day.addDays(1);
  }
  return out;
}
