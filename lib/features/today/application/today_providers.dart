import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/fast_repository.dart';
import '../../../data/repositories/prayer_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../calendar/domain/hijri_service.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../ramadan/domain/ramadan.dart';
import '../domain/today_logic.dart';

/// Marks for any day.
final dayMarksProvider = StreamProvider.family<Map<Prayer, PrayerStatus>, DayKey>(
  (ref, day) => ref.watch(prayerRepositoryProvider).watchDay(day),
);

final todayMarksProvider = Provider<AsyncValue<Map<Prayer, PrayerStatus>>>(
  (ref) => ref.watch(dayMarksProvider(ref.watch(todayKeyProvider))),
);

final qadaCountsProvider = StreamProvider<Map<Prayer, int>>(
  (ref) => ref.watch(prayerRepositoryProvider).watchQadaCounts(),
);

final qadaTotalProvider = Provider<int>((ref) {
  final m = ref.watch(qadaCountsProvider).value ?? const {};
  return m.values.fold(0, (a, b) => a + b);
});

final hijriServiceProvider = Provider<HijriService>(
  (ref) => HijriService(adjustment: ref.watch(settingsProvider.select((s) => s.hijriAdjustment))),
);

/// Is Ramadan mode active today (setting + adjusted calendar)?
final ramadanTodayProvider = Provider<bool>((ref) {
  final mode = ref.watch(settingsProvider.select((s) => s.ramadanMode));
  final day = ref.watch(todayKeyProvider);
  return isRamadanActive(mode, ref.watch(hijriServiceProvider), day.date);
});

/// Absolute start/end of a local day at the configured location.
(DateTime, DateTime) dayBounds(tz.Location loc, DayKey day) {
  final d = day.date;
  return (tz.TZDateTime(loc, d.year, d.month, d.day), tz.TZDateTime(loc, d.year, d.month, d.day + 1));
}

final todayExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final day = ref.watch(todayKeyProvider);
  final loc = ref.watch(prayerEngineProvider).config.location;
  final (from, to) = dayBounds(loc, day);
  return ref.watch(expenseRepositoryProvider).watchBetween(from, to);
});

final dayTasksProvider = StreamProvider.family<List<Task>, DayKey>(
  (ref, day) => ref.watch(taskRepositoryProvider).watchDay(day),
);

final todayTasksProvider = Provider<AsyncValue<List<Task>>>(
  (ref) => ref.watch(dayTasksProvider(ref.watch(todayKeyProvider))),
);

/// Unmarked prayers of yesterday for the gentle card, or empty when the card
/// should not show (dismissed, or the user hadn't started using the app).
final yesterdayUnmarkedProvider = FutureProvider<List<Prayer>>((ref) async {
  final today = ref.watch(todayKeyProvider);
  final yesterday = today.addDays(-1);
  final marks = await ref.watch(dayMarksProvider(yesterday).future);
  final repo = ref.read(prayerRepositoryProvider);
  final first = await repo.firstLoggedDay();
  if (first == null || first.isAfter(yesterday)) return const [];
  final dismissed = await ref.read(settingsRepositoryProvider).getFlag('unmarkedDismissed');
  if (dismissed == yesterday.value) return const [];
  return unmarkedPrayers(marks);
});

/// Ramadan fasts for the hero's 30-segment bar: (day n, total, statuses).
final ramadanFastBarProvider = StreamProvider<({int day, int total, List<FastStatus?> fasts})?>((ref) {
  final today = ref.watch(todayKeyProvider);
  final info = ramadanDay(ref.watch(hijriServiceProvider), today.date);
  if (info == null) return Stream.value(null);
  final first = DayKey.fromDate(info.first);
  final last = first.addDays(info.total - 1);
  return ref.watch(fastRepositoryProvider).watchRange(first, last).map((m) => (
        day: info.day,
        total: info.total,
        fasts: [for (var i = 0; i < info.total; i++) m[first.addDays(i)]?.status],
      ));
});
