import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/quran_repository.dart';
import '../../adhkar/application/adhkar_providers.dart';
import '../../me/application/me_providers.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../quran/application/quran_providers.dart';
import '../../today/application/today_providers.dart';
import '../domain/ramadan.dart';

/// Ayahs ≈ one Mushaf page: enough to count "Quran" for the day.
const _quranMinAyahs = 10;

@immutable
class RamadanChallenge {
  const RamadanChallenge({required this.day, required this.total, required this.today, required this.coreDays});
  final int day;
  final int total;
  final RamadanChecks today;

  /// Days so far (incl. today) with fast + all prayers + Quran.
  final int coreDays;
}

bool _allPrayed(Map<Prayer, PrayerStatus>? m) =>
    m != null && m.length == Prayer.values.length && m.values.every((s) => s.isPrayed || s == PrayerStatus.excused);

final _ramadanQuranProvider = StreamProvider<Map<DayKey, int>>((ref) {
  final today = ref.watch(todayKeyProvider);
  final info = ramadanDay(ref.watch(hijriServiceProvider), today.date);
  if (info == null) return Stream.value(const {});
  return ref.watch(quranRepositoryProvider).watchDailyCounts(DayKey.fromDate(info.first), today);
});

/// Today's checklist and the month tally; null outside Ramadan.
final ramadanChallengeProvider = Provider<RamadanChallenge?>((ref) {
  final bar = ref.watch(ramadanFastBarProvider).value;
  if (bar == null) return null;
  final today = ref.watch(todayKeyProvider);
  final marks = ref.watch(allMarksProvider).value?.$2 ?? const <DayKey, Map<Prayer, PrayerStatus>>{};
  final quran = ref.watch(_ramadanQuranProvider).value ?? const <DayKey, int>{};
  final goal = ref.watch(readingGoalProvider);
  final morning = ref.watch(adhkarTodayProvider(AdhkarSet.morning)).isComplete;
  final evening = ref.watch(adhkarTodayProvider(AdhkarSet.evening)).isComplete;
  final expenses = ref.watch(todayExpensesProvider).value ?? const <Expense>[];

  final checks = RamadanChecks(
    fasted: bar.fasts[bar.day - 1] == FastStatus.fasted,
    prayers: _allPrayed(marks[today]),
    quran: goal.done || (quran[today] ?? 0) >= _quranMinAyahs,
    dhikr: morning || evening,
    sadaqa: expenses.any((e) => e.category == ExpenseCategory.sadaqa),
  );
  var core = 0;
  for (var i = 0; i < bar.day; i++) {
    final d = today.addDays(i - (bar.day - 1));
    final read = d == today ? checks.quran : (quran[d] ?? 0) >= _quranMinAyahs;
    if (bar.fasts[i] == FastStatus.fasted && _allPrayed(marks[d]) && read) core++;
  }
  return RamadanChallenge(day: bar.day, total: bar.total, today: checks, coreDays: core);
});
