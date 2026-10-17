import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/assets.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/bookmark_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../prayer/application/prayer_providers.dart';
import '../domain/hadith.dart';

/// Keeps a large provider alive for a while after its last listener leaves,
/// so going back and forth is instant but memory is released eventually.
void _keepAliveFor(Ref ref, Duration grace) {
  final link = ref.keepAlive();
  Timer? timer;
  ref.onCancel(() => timer = Timer(grace, link.close));
  ref.onResume(() => timer?.cancel());
  ref.onDispose(() => timer?.cancel());
}

/// Loaded editions, keyed by (book, language). Bukhari/Muslim are several
/// MB each, so they are released 2 minutes after no screen uses them.
final hadithEditionProvider = FutureProvider.autoDispose.family<HadithEdition, (String, String)>((ref, key) async {
  _keepAliveFor(ref, const Duration(minutes: 2));
  final book = HadithBooks.byId(key.$1)!;
  final json = (await loadGzJson(book.asset(key.$2)))! as Map<String, Object?>;
  return HadithEdition.fromJson(book, key.$2, json);
});

/// Normalized texts for search (built lazily, off the UI isolate).
final hadithSearchIndexProvider = FutureProvider.autoDispose.family<List<String>, (String, String)>((ref, key) async {
  _keepAliveFor(ref, const Duration(minutes: 2));
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

/// Today's hadith in the reader's language: Nawawi 40 + Qudsi 40 in English,
/// Nawawi 40 in Turkish, and a pool of short Bukhari hadiths in Russian (also
/// Turkmen), where neither 40-hadith collection is translated.
final hadithOfDayProvider = FutureProvider<DailyHadith?>((ref) async {
  final day = ref.watch(todayKeyProvider).date;
  final pref = ref.watch(hadithLanguageProvider);
  final hasNawawi = HadithBooks.nawawi.languages.contains(pref);
  if (!hasNawawi && pref == 'rus') {
    final j = (await loadGzJson('assets/hadith/daily_rus.json.gz'))! as Map<String, Object?>;
    final pool = (j['h']! as List).cast<List<Object?>>();
    if (pool.isEmpty) return null;
    final n = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    final e = pool[n % pool.length];
    final number = e[0]! as num;
    final section = (e[1] as num?)?.toInt() ?? 0;
    return DailyHadith(
      HadithBooks.bukhari,
      Hadith(number, e[2]! as String, '', section),
      Hadith(number, e[3]! as String, '', section),
    );
  }
  final lang = hasNawawi ? pref : 'eng';
  final nawawi = await ref.watch(hadithEditionProvider(('nawawi', lang)).future);
  final withQudsi = HadithBooks.qudsi.languages.contains(lang);
  final qudsi = withQudsi ? await ref.watch(hadithEditionProvider(('qudsi', lang)).future) : null;
  final pick = hadithOfDay(day, nawawiCount: nawawi.hadiths.length, qudsiCount: qudsi?.hadiths.length ?? 0);
  final edition = pick.book == 'nawawi' ? nawawi : qudsi!;
  final h = edition.byNumber(pick.number) ?? edition.hadiths.first;
  final ar = await ref.watch(hadithEditionProvider((pick.book, 'ara')).future);
  return DailyHadith(edition.book, h, ar.byNumber(h.number));
});
