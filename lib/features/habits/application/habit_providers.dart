import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/dates.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../quran/domain/quran.dart' show readingStreak;

final habitsProvider = StreamProvider<List<HabitRow>>((ref) => ref.watch(habitRepositoryProvider).watchActive());

/// habitId → days done over the last ~4 months (enough for streaks).
final habitLogsProvider = StreamProvider<Map<int, Set<String>>>((ref) {
  final today = ref.watch(todayKeyProvider);
  return ref.watch(habitRepositoryProvider).watchLogs(today.addDays(-120), today);
});

@immutable
class HabitView {
  const HabitView(this.habit, this.days, this.streak, this.doneToday);
  final HabitRow habit;
  final Set<String> days;
  final int streak;
  final bool doneToday;
}

final habitViewsProvider = Provider<List<HabitView>>((ref) {
  final habits = ref.watch(habitsProvider).value ?? const <HabitRow>[];
  final logs = ref.watch(habitLogsProvider).value ?? const <int, Set<String>>{};
  final today = ref.watch(todayKeyProvider);
  return [
    for (final h in habits)
      HabitView(
        h,
        logs[h.id] ?? const {},
        readingStreak(logs[h.id] ?? const {}, today.date),
        (logs[h.id] ?? const {}).contains(today.value),
      ),
  ];
});

/// (done today, total) for the Today card.
final habitsTodayProvider = Provider<(int, int)>((ref) {
  final v = ref.watch(habitViewsProvider);
  return (v.where((h) => h.doneToday).length, v.length);
});

/// Last [n] days ending today, oldest first.
List<DayKey> lastDays(DayKey today, int n) => [for (var i = n - 1; i >= 0; i--) today.addDays(-i)];
