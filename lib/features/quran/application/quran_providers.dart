import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/assets.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/bookmark_repository.dart';
import '../../../data/repositories/quran_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../prayer/application/prayer_providers.dart';
import '../domain/quran.dart';
import '../domain/translations.dart';

/// Uthmani text, 6236 ayahs.
final quranArabicProvider = FutureProvider<List<String>>((ref) => loadGzStrings('assets/quran/ar.json.gz'));

final quranTranslitProvider =
    FutureProvider<List<String>>((ref) => loadGzStrings('assets/quran/translit.json.gz'));

final quranTranslationTextProvider = FutureProvider.family<List<String>, String>(
  (ref, id) => loadGzStrings(QuranTranslations.byId(id).asset),
);

/// The translation the user reads with.
final activeTranslationProvider = Provider<QuranTranslation>((ref) {
  final chosen = ref.watch(settingsProvider.select((s) => s.reader.translation));
  final lang = ref.watch(appLanguageProvider);
  return QuranTranslations.byId(QuranTranslations.resolve(chosen, lang));
});

/// Everything the reader needs, loaded together.
@immutable
class QuranTexts {
  const QuranTexts({required this.arabic, required this.translit, required this.translation});
  final List<String> arabic;
  final List<String> translit;
  final List<String> translation;
}

final quranTextsProvider = FutureProvider<QuranTexts>((ref) async {
  final t = ref.watch(activeTranslationProvider);
  final results = await Future.wait([
    ref.watch(quranArabicProvider.future),
    ref.watch(quranTranslitProvider.future),
    ref.watch(quranTranslationTextProvider(t.id).future),
  ]);
  return QuranTexts(arabic: results[0], translit: results[1], translation: results[2]);
});

/// Normalized copies for search (built in a background isolate).
@immutable
class QuranSearchIndex {
  const QuranSearchIndex(this.arabic, this.translation);
  final List<String> arabic;
  final List<String> translation;
}

final quranSearchIndexProvider = FutureProvider<QuranSearchIndex>((ref) async {
  final texts = await ref.watch(quranTextsProvider.future);
  return compute(_buildIndex, (texts.arabic, texts.translation));
});

QuranSearchIndex _buildIndex((List<String>, List<String>) input) => QuranSearchIndex(
      [for (final a in input.$1) normalizeArabic(a)],
      [for (final t in input.$2) normalizeLatin(t)],
    );

// ---------------------------------------------------------------- bookmarks

final ayahBookmarksProvider = StreamProvider<List<Bookmark>>(
  (ref) => ref.watch(bookmarkRepositoryProvider).watch(BookmarkKind.ayah),
);

final ayahBookmarkRefsProvider = Provider<Set<String>>(
  (ref) => {for (final b in ref.watch(ayahBookmarksProvider).value ?? const <Bookmark>[]) b.ref},
);

// ---------------------------------------------------------------- reading

final _readingDaysProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(quranRepositoryProvider).watchReadingDays(),
);

/// Ayahs read per day over the last two weeks.
final quranRecentDailyProvider = StreamProvider<Map<DayKey, int>>((ref) {
  final today = ref.watch(todayKeyProvider);
  return ref.watch(quranRepositoryProvider).watchDailyCounts(today.addDays(-13), today);
});

final quranTodayReadProvider = Provider<int>((ref) {
  final today = ref.watch(todayKeyProvider);
  return ref.watch(quranRecentDailyProvider).value?[today] ?? 0;
});

final quranStreakProvider = Provider<int>((ref) {
  final days = ref.watch(_readingDaysProvider).value ?? const <String>{};
  return readingStreak(days, ref.watch(todayKeyProvider).date);
});

final _readSinceKhatmProvider = StreamProvider<int>((ref) {
  final plan = ref.watch(settingsProvider.select((s) => s.khatmPlan));
  if (plan == null) return Stream.value(0);
  return ref.watch(quranRepositoryProvider).watchDistinctSince(DayKey(plan.start));
});

/// Ayahs read since the khatm plan began (to tick them in the surah list).
final khatmReadAyahsProvider = StreamProvider<Set<int>>((ref) {
  final plan = ref.watch(settingsProvider.select((s) => s.khatmPlan));
  if (plan == null) return Stream.value(const <int>{});
  return ref.watch(quranRepositoryProvider).watchReadSince(DayKey(plan.start));
});

final khatmProgressProvider = Provider<KhatmProgress?>((ref) {
  final plan = ref.watch(settingsProvider.select((s) => s.khatmPlan));
  if (plan == null) return null;
  final total = ref.watch(_readSinceKhatmProvider).value ?? 0;
  return khatmProgress(
    plan: plan,
    today: ref.watch(todayKeyProvider).date,
    readTotal: total,
    readToday: ref.watch(quranTodayReadProvider),
  );
});

/// Today's target and progress for the reading ring (khatm or daily goal).
@immutable
class ReadingGoal {
  const ReadingGoal({required this.read, required this.target, required this.streak, this.khatm});
  final int read;
  final int target;
  final int streak;
  final KhatmProgress? khatm;
  double get fraction => target <= 0 ? 1 : (read / target).clamp(0, 1).toDouble();
  bool get done => read >= target;
}

final readingGoalProvider = Provider<ReadingGoal>((ref) {
  final khatm = ref.watch(khatmProgressProvider);
  final goal = ref.watch(settingsProvider.select((s) => s.reader.dailyGoal));
  return ReadingGoal(
    read: ref.watch(quranTodayReadProvider),
    target: khatm != null && !khatm.complete ? khatm.todayTarget : goal,
    streak: ref.watch(quranStreakProvider),
    khatm: khatm,
  );
});

// ---------------------------------------------------------------- hifz

final hifzProvider = StreamProvider<List<HifzRow>>((ref) => ref.watch(quranRepositoryProvider).watchHifz());

/// Surahs due for review today or overdue.
final hifzDueProvider = Provider<List<HifzRow>>((ref) {
  final today = ref.watch(todayKeyProvider);
  return [
    for (final h in ref.watch(hifzProvider).value ?? const <HifzRow>[])
      if (!DayKey(h.nextReview).isAfter(today)) h,
  ];
});

/// Distinct ayah-reads this calendar month (sum of daily counts).
final quranMonthAyahsProvider = StreamProvider<int>((ref) {
  final today = ref.watch(todayKeyProvider);
  final d = today.date;
  return ref
      .watch(quranRepositoryProvider)
      .watchDailyCounts(DayKey.fromDate(DateTime(d.year, d.month)), today)
      .map((m) => m.values.fold<int>(0, (a, b) => a + b));
});
