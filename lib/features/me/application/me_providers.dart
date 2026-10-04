import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/adhkar_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/fast_repository.dart';
import '../../../data/repositories/prayer_repository.dart';
import '../../adhkar/application/adhkar_providers.dart';
import '../../adhkar/domain/adhkar.dart';
import '../../prayer/application/prayer_providers.dart';
import '../domain/stats.dart';

/// First day of the current month at the location.
final monthStartProvider = Provider<DayKey>((ref) {
  final today = ref.watch(todayKeyProvider).date;
  return DayKey.fromDate(DateTime(today.year, today.month));
});

/// All prayer marks (by day) since the user started, for streaks/stats.
final allMarksProvider = StreamProvider<(DayKey?, Map<DayKey, Map<Prayer, PrayerStatus>>)>((ref) {
  final repo = ref.watch(prayerRepositoryProvider);
  final today = ref.watch(todayKeyProvider);
  return repo.watchRange(const DayKey('1900-01-01'), today).map((logs) {
    final m = <DayKey, Map<Prayer, PrayerStatus>>{};
    for (final l in logs) {
      (m[l.day] ??= {})[l.prayer] = l.status;
    }
    // Logs are sorted by date, so the first is the earliest day.
    return (logs.isEmpty ? null : logs.first.day, m);
  });
});

final streakProvider = Provider<StreakStats?>((ref) {
  final data = ref.watch(allMarksProvider).value;
  if (data == null) return null;
  final (first, byDay) = data;
  return computeStreak(byDay, today: ref.watch(todayKeyProvider), firstDay: first);
});

class MonthPrayerStats {
  const MonthPrayerStats({required this.onTime, required this.consistency});
  final double? onTime;
  final Map<Prayer, double?> consistency;
}

final monthPrayerStatsProvider = Provider<MonthPrayerStats?>((ref) {
  final data = ref.watch(allMarksProvider).value;
  if (data == null) return null;
  final (first, byDay) = data;
  if (first == null) return const MonthPrayerStats(onTime: null, consistency: {});
  final monthStart = ref.watch(monthStartProvider);
  final now = ref.watch(prayerNowProvider);
  final engine = ref.watch(prayerEngineProvider);
  final from = first.isAfter(monthStart) ? first : monthStart;
  final to = now.dayKey;
  final inMonth = byDay.entries.where((e) => !e.key.isBefore(from));
  return MonthPrayerStats(
    onTime: onTimeShare(inMonth.expand((e) => e.value.values)),
    consistency: consistency(
      byDay,
      from: from,
      to: to,
      hasStarted: (d, p) => d != to || !engine.day(d.date)[p].isAfter(now.now),
    ),
  );
});

/// Days (last ~13 months) with both adhkar sets complete.
final adhkarStreakProvider = StreamProvider<int>((ref) {
  final today = ref.watch(todayKeyProvider);
  final catalog = ref.watch(adhkarCatalogProvider).value ?? AdhkarCatalog.empty;
  return ref.watch(adhkarRepositoryProvider).watchRange(today.addDays(-400), today).map((m) {
    final complete = <DayKey>{};
    final days = {for (final k in m.keys) k.$1};
    for (final d in days) {
      final morning = AdhkarProgress(catalog.items(AdhkarSet.morning), m[(d, AdhkarSet.morning)] ?? const {});
      final evening = AdhkarProgress(catalog.items(AdhkarSet.evening), m[(d, AdhkarSet.evening)] ?? const {});
      if (morning.isComplete && evening.isComplete) complete.add(d);
    }
    return adhkarStreak(complete, today);
  });
});

final monthFastsProvider = StreamProvider<Map<DayKey, FastLog>>((ref) {
  final start = ref.watch(monthStartProvider);
  final d = start.date;
  final end = DayKey.fromDate(DateTime(d.year, d.month + 1, 0));
  return ref.watch(fastRepositoryProvider).watchRange(start, end);
});

final monthExpensesProvider = StreamProvider<ExpenseSummary>((ref) {
  final start = ref.watch(monthStartProvider).date;
  final loc = ref.watch(prayerEngineProvider).config.location;
  final from = tz.TZDateTime(loc, start.year, start.month);
  final to = tz.TZDateTime(loc, start.year, start.month + 1);
  return ref.watch(expenseRepositoryProvider).watchBetween(from, to).map(ExpenseSummary.of);
});
