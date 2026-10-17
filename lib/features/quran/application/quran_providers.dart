import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/assets.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/bookmark_repository.dart';
import '../../../data/repositories/quran_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../prayer/application/prayer_providers.dart';
import '../domain/mushaf.dart';
import '../domain/quran.dart';
import '../domain/translations.dart';

/// Uthmani text, 6236 ayahs.
final quranArabicProvider = FutureProvider<List<String>>((ref) => loadGzStrings('assets/quran/ar.json.gz'));

final quranTajweedProvider =
    FutureProvider<List<String>>((ref) => loadGzStrings('assets/quran/ar_tajweed.json.gz'));

/// Madani Mushaf line layout (604 pages), for the Mushaf style.
final mushafPagesProvider = FutureProvider<List<List<MushafLine>>>(
  (ref) async => parseMushaf(await loadGzJson('assets/quran/mushaf_lines.json.gz')),
);

final quranTranslitProvider = FutureProvider<List<String>>((ref) => loadGzStrings('assets/quran/translit.json.gz'));

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
  const QuranTexts({
    required this.arabic,
    required this.translit,
    required this.translation,
    this.translationCredit,
    this.tajweed,
  });
  final List<String> arabic;

  /// Same ayahs with tajweed markup; null unless the reader turned it on.
  final List<String>? tajweed;
  final List<String> translit;
  final List<String> translation;

  /// "Saheeh International" etc., for share cards.
  final String? translationCredit;
}

final quranTextsProvider = FutureProvider<QuranTexts>((ref) async {
  final t = ref.watch(activeTranslationProvider);
  final tajweed = ref.watch(settingsProvider.select((s) => s.reader.tajweed));
  final results = await Future.wait([
    ref.watch(quranArabicProvider.future),
    ref.watch(quranTranslitProvider.future),
    ref.watch(quranTranslationTextProvider(t.id).future),
    if (tajweed) ref.watch(quranTajweedProvider.future),
  ]);
  return QuranTexts(
    arabic: results[0],
    translit: results[1],
    translation: results[2],
    translationCredit: t.author,
    tajweed: tajweed ? results[3] : null,
  );
});

/// Normalized copies for search (built in a background isolate).
@immutable
class QuranSearchIndex {
  const QuranSearchIndex(this.arabic, this.translation);
  final List<String> arabic;
  final List<String> translation;
}

/// Simple (imlaʾi) spelling of the Arabic, used only for search so ordinary
/// typing (الصلاة, ابراهيم) matches the Uthmani text.
final quranArabicSearchProvider =
    FutureProvider<List<String>>((ref) => loadGzStrings('assets/quran/ar_search.json.gz'));

final quranSearchIndexProvider = FutureProvider<QuranSearchIndex>((ref) async {
  final texts = await ref.watch(quranTextsProvider.future);
  final simple = await ref.watch(quranArabicSearchProvider.future);
  return compute(_buildIndex, (simple, texts.translation));
});

QuranSearchIndex _buildIndex((List<String>, List<String>) input) =>
    QuranSearchIndex([for (final a in input.$1) normalizeArabic(a)], [for (final t in input.$2) normalizeLatin(t)]);

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

/// Ayahs read since the khatm plan began (to tick them in the surah list).
final khatmReadAyahsProvider = StreamProvider<Set<int>>((ref) {
  final plan = ref.watch(settingsProvider.select((s) => s.khatmPlan));
  if (plan == null) return Stream.value(const <int>{});
  return ref.watch(quranRepositoryProvider).watchReadSince(DayKey(plan.start));
});

/// Ayahs read for the first time in this plan today.
final _khatmNewTodayProvider = StreamProvider<Set<int>>((ref) {
  final plan = ref.watch(settingsProvider.select((s) => s.khatmPlan));
  if (plan == null) return Stream.value(const <int>{});
  return ref.watch(quranRepositoryProvider).watchFirstReadOn(DayKey(plan.start), ref.watch(todayKeyProvider));
});

final khatmProgressProvider = Provider<KhatmProgress?>((ref) {
  final plan = ref.watch(settingsProvider.select((s) => s.khatmPlan));
  if (plan == null) return null;
  final read = ref.watch(khatmReadAyahsProvider).value ?? const <int>{};
  final newToday = ref.watch(_khatmNewTodayProvider).value ?? const <int>{};
  return khatmProgress(
    plan: plan,
    today: ref.watch(todayKeyProvider).date,
    readPages: pagesOf(read),
    readTodayPages: pagesOf(newToday),
    allRead: read.length >= totalAyahs,
  );
});

/// Where "continue khatm" resumes: the first ayah not yet read in the plan.
final khatmNextAyahProvider = Provider<int>(
  (ref) => firstUnread(ref.watch(khatmReadAyahsProvider).value ?? const <int>{}),
);

/// Today's target and progress for the reading ring (khatm or daily goal).
@immutable
class ReadingGoal {
  const ReadingGoal({required this.read, required this.target, required this.streak, this.khatm});

  /// Ayahs today (daily goal) or pages today (khatm plan, see [pages]).
  final int read;
  final int target;
  final int streak;
  final KhatmProgress? khatm;

  /// True when [read]/[target] are pages of an active khatm plan.
  bool get pages => khatm != null && !khatm!.complete;
  double get fraction => pages
      ? (khatm!.todayTargetPages <= 0 ? 1 : (khatm!.readTodayPages / khatm!.todayTargetPages).clamp(0, 1).toDouble())
      : target <= 0
      ? 1
      : (read / target).clamp(0, 1).toDouble();
  bool get done => pages ? khatm!.todayDone : read >= target;
}

final readingGoalProvider = Provider<ReadingGoal>((ref) {
  final khatm = ref.watch(khatmProgressProvider);
  final goal = ref.watch(settingsProvider.select((s) => s.reader.dailyGoal));
  final active = khatm != null && !khatm.complete;
  return ReadingGoal(
    read: active ? khatm.readTodayRounded : ref.watch(quranTodayReadProvider),
    target: active ? khatm.targetPagesRounded : goal,
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
