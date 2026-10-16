import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/assets.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/bookmark_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../prayer/application/prayer_providers.dart';
import '../domain/hadith.dart';

/// Loaded editions, keyed by (book, language). Kept alive: books are large
/// and reopened often.
final hadithEditionProvider = FutureProvider.family<HadithEdition, (String, String)>((ref, key) async {
  final book = HadithBooks.byId(key.$1)!;
  final json = (await loadGzJson(book.asset(key.$2)))! as Map<String, Object?>;
  return HadithEdition.fromJson(book, key.$2, json);
});

/// Normalized texts for search (built lazily, off the UI isolate).
final hadithSearchIndexProvider = FutureProvider.family<List<String>, (String, String)>((ref, key) async {
  final e = await ref.watch(hadithEditionProvider(key).future);
  return compute(normalizeHadithTexts, e);
});

/// The reader's preferred translation language (`eng` / `rus` / `tur`).
final hadithLanguageProvider = Provider<String>((ref) {
  final chosen = ref.watch(settingsProvider.select((s) => s.reader.hadithLanguage));
  return chosen ?? HadithBooks.preferredLanguage(ref.watch(appLanguageProvider));
});

/// The edition language to show for a book.
final hadithBookLanguageProvider = Provider.family<String, String>((ref, bookId) {
  return HadithBooks.languageFor(HadithBooks.byId(bookId)!, ref.watch(hadithLanguageProvider));
});

final hadithBookmarksProvider = StreamProvider<List<Bookmark>>(
  (ref) => ref.watch(bookmarkRepositoryProvider).watch(BookmarkKind.hadith),
);

final hadithBookmarkRefsProvider = Provider<Set<String>>(
  (ref) => {for (final b in ref.watch(hadithBookmarksProvider).value ?? const <Bookmark>[]) b.ref},
);

/// Today's hadith with its translation and Arabic (null while loading).
@immutable
class DailyHadith {
  const DailyHadith(this.book, this.hadith, this.arabic);
  final HadithBook book;
  final Hadith hadith;
  final Hadith? arabic;
}

final hadithOfDayProvider = FutureProvider<DailyHadith?>((ref) async {
  final day = ref.watch(todayKeyProvider).date;
  final pref = ref.watch(hadithLanguageProvider);
  final nawawi = await ref.watch(hadithEditionProvider(('nawawi', HadithBooks.languageFor(HadithBooks.nawawi, pref))).future);
  final qudsi = await ref.watch(hadithEditionProvider(('qudsi', HadithBooks.languageFor(HadithBooks.qudsi, pref))).future);
  final pick = hadithOfDay(day, nawawiCount: nawawi.hadiths.length, qudsiCount: qudsi.hadiths.length);
  final edition = pick.book == 'nawawi' ? nawawi : qudsi;
  final h = edition.byNumber(pick.number) ?? edition.hadiths.first;
  final ar = await ref.watch(hadithEditionProvider((pick.book, 'ara')).future);
  return DailyHadith(edition.book, h, ar.byNumber(h.number));
});
