import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';

/// How one day counts for the prayer streak.
enum StreakDay {
  /// Every prayer prayed or excused, at least one prayed.
  kept,

  /// Every prayer excused (period mode): neither breaks nor extends.
  skipped,

  /// Something missing or missed.
  broken,

  /// Today, not complete yet (does not break the streak).
  pending,
}

StreakDay classifyDay(Map<Prayer, PrayerStatus> marks, {bool isToday = false}) {
  var prayed = 0;
  var excused = 0;
  for (final p in Prayer.values) {
    final s = marks[p];
    if (s == null || s == PrayerStatus.missed) {
      return isToday ? StreakDay.pending : StreakDay.broken;
    }
    if (s.isPrayed) prayed++;
    if (s == PrayerStatus.excused) excused++;
  }
  if (prayed == 0 && excused == Prayer.values.length) return StreakDay.skipped;
  return StreakDay.kept;
}

class StreakStats {
  const StreakStats({required this.current, required this.best, required this.lastDays});

  final int current;
  final int best;

  /// Oldest → newest (today last), for the 14-day bar.
  final List<StreakDay> lastDays;
}

/// Streak from per-day marks. [byDay] may omit days with no marks.
StreakStats computeStreak(
  Map<DayKey, Map<Prayer, PrayerStatus>> byDay, {
  required DayKey today,
  DayKey? firstDay,
  int window = 14,
}) {
  StreakDay classify(DayKey d) => classifyDay(byDay[d] ?? const {}, isToday: d == today);

  // Current: walk back from today; pending today and skipped days are neutral.
  var current = 0;
  var d = today;
  final start = firstDay ?? (byDay.keys.isEmpty ? today : byDay.keys.reduce((a, b) => a.isBefore(b) ? a : b));
  while (!d.isBefore(start)) {
    final c = classify(d);
    if (c == StreakDay.broken) break;
    if (c == StreakDay.kept) current++;
    d = d.addDays(-1);
  }

  // Best: forward scan over the whole history.
  var best = 0;
  var run = 0;
  d = start;
  while (!d.isAfter(today)) {
    switch (classify(d)) {
      case StreakDay.kept:
        run++;
        if (run > best) best = run;
      case StreakDay.broken:
        run = 0;
      case StreakDay.skipped || StreakDay.pending:
        break;
    }
    d = d.addDays(1);
  }

  final last = [for (var i = window - 1; i >= 0; i--) classify(today.addDays(-i))];
  return StreakStats(current: current, best: best < current ? current : best, lastDays: last);
}

/// Per-prayer share of days prayed (any form), excluding excused days.
/// [hasStarted] says whether a prayer's time has begun on a day (so today's
/// later prayers don't count against you).
Map<Prayer, double?> consistency(
  Map<DayKey, Map<Prayer, PrayerStatus>> byDay, {
  required DayKey from,
  required DayKey to,
  required bool Function(DayKey day, Prayer p) hasStarted,
}) {
  final out = <Prayer, double?>{};
  for (final p in Prayer.values) {
    var prayed = 0;
    var total = 0;
    var d = from;
    while (!d.isAfter(to)) {
      final s = byDay[d]?[p];
      if (s != PrayerStatus.excused && hasStarted(d, p)) {
        total++;
        if (s?.isPrayed ?? false) prayed++;
      }
      d = d.addDays(1);
    }
    out[p] = total == 0 ? null : prayed / total;
  }
  return out;
}

/// Share of marked prayers (excluding excused) prayed on time or in
/// congregation. Null with no data.
double? onTimeShare(Iterable<PrayerStatus> marks) {
  var onTime = 0;
  var total = 0;
  for (final s in marks) {
    if (s == PrayerStatus.excused) continue;
    total++;
    if (s.isOnTime) onTime++;
  }
  return total == 0 ? null : onTime / total;
}

/// The prayer with the lowest consistency (ties → earliest), if any data.
Prayer? weakestPrayer(Map<Prayer, double?> c) {
  Prayer? weakest;
  double? low;
  for (final p in Prayer.values) {
    final v = c[p];
    if (v == null) continue;
    if (low == null || v < low) {
      low = v;
      weakest = p;
    }
  }
  return weakest;
}

/// Consecutive days (ending today, or yesterday if today isn't done yet)
/// with both morning and evening adhkar complete.
int adhkarStreak(Set<DayKey> completeDays, DayKey today) {
  var d = completeDays.contains(today) ? today : today.addDays(-1);
  var n = 0;
  while (completeDays.contains(d)) {
    n++;
    d = d.addDays(-1);
  }
  return n;
}
