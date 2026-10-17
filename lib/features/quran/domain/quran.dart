import 'package:flutter/foundation.dart';

import 'quran_index_data.dart';
import 'surah_names.dart';

/// Total ayahs in the Quran (Hafs, Kufan count).
const totalAyahs = 6236;
const totalPages = 604;
const totalSurahs = 114;

/// A surah:ayah reference (both 1-based).
@immutable
class AyahRef implements Comparable<AyahRef> {
  const AyahRef(this.surah, this.ayah);

  /// From a global index (0…6235).
  factory AyahRef.fromIndex(int index) {
    final s = surahOfIndex(index);
    return AyahRef(s, index - surahStarts[s - 1] + 1);
  }

  /// Parses `2:255` / `2 255` / `2.255`; null if out of range.
  static AyahRef? tryParse(String input) {
    final m = RegExp(r'^\s*(\d{1,3})\s*[:.\s]\s*(\d{1,3})\s*$').firstMatch(input);
    if (m == null) return null;
    final s = int.parse(m.group(1)!);
    final a = int.parse(m.group(2)!);
    if (s < 1 || s > totalSurahs || a < 1 || a > surahAyahCounts[s - 1]) return null;
    return AyahRef(s, a);
  }

  final int surah;
  final int ayah;

  int get index => surahStarts[surah - 1] + ayah - 1;

  @override
  String toString() => '$surah:$ayah';

  @override
  int compareTo(AyahRef other) => index.compareTo(other.index);

  @override
  bool operator ==(Object other) => other is AyahRef && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);
}

/// Last element of [starts] that is ≤ [index], 1-based (binary search).
int _bucket(List<int> starts, int index) {
  var lo = 0;
  var hi = starts.length - 1;
  while (lo < hi) {
    final mid = (lo + hi + 1) >> 1;
    if (starts[mid] <= index) {
      lo = mid;
    } else {
      hi = mid - 1;
    }
  }
  return lo + 1;
}

int surahOfIndex(int index) => _bucket(surahStarts, index);
int juzOfIndex(int index) => _bucket(juzStarts, index);
int pageOfIndex(int index) => _bucket(pageStarts, index);

/// Hizb quarter 1…240 (4 per hizb, 8 per juz).
int rubOfIndex(int index) => _bucket(rubStarts, index);

bool isSajda(int index) => sajdaAyahs.contains(index);

/// Inclusive global index range of a Mushaf page (1-based).
(int, int) pageRange(int page) {
  final start = pageStarts[page - 1];
  final end = page == totalPages ? totalAyahs - 1 : pageStarts[page] - 1;
  return (start, end);
}

(int, int) juzRange(int juz) {
  final start = juzStarts[juz - 1];
  final end = juz == 30 ? totalAyahs - 1 : juzStarts[juz] - 1;
  return (start, end);
}

/// Static facts about one surah.
@immutable
class SurahInfo {
  const SurahInfo(this.number);
  final int number;

  /// UI language for surah names; kept in sync by the app root so every
  /// screen (and context-free helpers like share text) name surahs the same.
  static String language = 'en';

  /// Display name in the UI language (Cyrillic for ru, Turkmen for tk).
  String get translit => surahName(number, language);

  /// Latin transliteration regardless of language (search, sharing abroad).
  String get latin => surahTranslit[number - 1];
  String get arabic => surahArabicNames[number - 1];
  int get ayahCount => surahAyahCounts[number - 1];
  bool get medinan => surahMedinan[number - 1];
  int get startIndex => surahStarts[number - 1];
  int get endIndex => startIndex + ayahCount - 1;
  int get startPage => pageOfIndex(startIndex);
  int get startJuz => juzOfIndex(startIndex);
  String meaning(String language) => surahMeaning(number, language);

  /// Every surah except Al-Fatihah (whose first ayah *is* the basmala) and
  /// At-Tawbah opens with a basmala that is not counted as an ayah.
  bool get hasBasmala => number != 1 && number != 9;

  static final all = List<SurahInfo>.unmodifiable([for (var i = 1; i <= totalSurahs; i++) SurahInfo(i)]);
}

// ---------------------------------------------------------------- search

final _arabicMarks = RegExp('[ؐ-ًؚ-ٰٟۖ-ۭ࣓-ࣿـ]');

/// Folds Arabic for search: removes diacritics/Quranic marks and tatweel,
/// unifies alef/ya/ta-marbuta/hamza forms.
String normalizeArabic(String s) => s
    .replaceAll(_arabicMarks, '')
    .replaceAll(RegExp('[آأإٱٲٳ]'), 'ا')
    .replaceAll('ى', 'ي')
    .replaceAll('ی', 'ي')
    .replaceAll('ة', 'ه')
    .replaceAll(RegExp('[ؤئ]'), 'ء')
    .replaceAll(RegExp(r'\s+'), ' ');

const _latinFold = {
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'ā': 'a',
  'ã': 'a',
  'å': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'ē': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ī': 'i',
  'ı': 'i',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'ö': 'o',
  'ō': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ū': 'u',
  'ç': 'c',
  'ş': 's',
  'ğ': 'g',
  'ñ': 'n',
  'ň': 'n',
  'ý': 'y',
  'ž': 'z',
  'ḥ': 'h',
  'ṣ': 's',
  'ḍ': 'd',
  'ṭ': 't',
  'ẓ': 'z',
  'ё': 'е',
  'ʿ': '',
  'ʾ': '',
  "'": '',
  '`': '',
  '’': '',
  '‘': '',
};

/// Lower-cases and strips accents / apostrophes for Latin & Cyrillic search.
String normalizeLatin(String s) {
  final lower = s.toLowerCase();
  final b = StringBuffer();
  for (final ch in lower.split('')) {
    b.write(_latinFold[ch] ?? ch);
  }
  return b.toString().replaceAll(RegExp(r'[\-_]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool _isArabic(String s) => RegExp('[؀-ۿ]').hasMatch(s);

/// Surahs whose transliterated name, number, Arabic name or meaning matches.
List<SurahInfo> searchSurahs(String query, String language) {
  final q = query.trim();
  if (q.isEmpty) return SurahInfo.all;
  final n = int.tryParse(q);
  if (n != null) return [if (n >= 1 && n <= totalSurahs) SurahInfo(n)];
  if (_isArabic(q)) {
    final nq = normalizeArabic(q);
    return SurahInfo.all.where((s) => normalizeArabic(s.arabic).contains(nq)).toList();
  }
  final nq = normalizeLatin(q).replaceAll(RegExp(r'^(al|an|ar|as|at|ad|az|ash|adh)\s'), '');
  return SurahInfo.all.where((s) {
    final t = normalizeLatin(s.latin);
    return t.contains(nq) ||
        normalizeLatin(surahName(s.number, language)).contains(normalizeLatin(q)) ||
        normalizeLatin(s.meaning(language)).contains(nq) ||
        normalizeLatin(s.meaning('en')).contains(nq);
  }).toList();
}

/// Full-text search over the Arabic and one translation. Returns global
/// indexes in Mushaf order, capped at [limit].
List<int> searchAyahs({
  required String query,
  required List<String> arabicNormalized,
  List<String>? translationNormalized,
  int limit = 200,
}) {
  final q = query.trim();
  if (q.length < 2) return const [];
  final out = <int>[];
  if (_isArabic(q)) {
    final nq = normalizeArabic(q);
    for (var i = 0; i < arabicNormalized.length && out.length < limit; i++) {
      if (arabicNormalized[i].contains(nq)) out.add(i);
    }
  } else if (translationNormalized != null) {
    final nq = normalizeLatin(q);
    for (var i = 0; i < translationNormalized.length && out.length < limit; i++) {
      if (translationNormalized[i].contains(nq)) out.add(i);
    }
  }
  return out;
}

// ---------------------------------------------------------------- daily ayah

/// Short, well-known ayahs for the "Ayah of the day" card (rotates daily).
const dailyAyahPool = <AyahRef>[
  AyahRef(2, 152),
  AyahRef(2, 153),
  AyahRef(2, 186),
  AyahRef(2, 286),
  AyahRef(3, 8),
  AyahRef(3, 139),
  AyahRef(3, 159),
  AyahRef(3, 173),
  AyahRef(3, 190),
  AyahRef(4, 28),
  AyahRef(6, 162),
  AyahRef(7, 23),
  AyahRef(8, 46),
  AyahRef(9, 40),
  AyahRef(9, 51),
  AyahRef(11, 88),
  AyahRef(12, 87),
  AyahRef(13, 11),
  AyahRef(13, 28),
  AyahRef(14, 7),
  AyahRef(16, 97),
  AyahRef(16, 128),
  AyahRef(17, 24),
  AyahRef(17, 80),
  AyahRef(18, 10),
  AyahRef(20, 25),
  AyahRef(20, 114),
  AyahRef(21, 87),
  AyahRef(23, 118),
  AyahRef(25, 63),
  AyahRef(25, 74),
  AyahRef(28, 24),
  AyahRef(29, 69),
  AyahRef(31, 17),
  AyahRef(33, 41),
  AyahRef(39, 10),
  AyahRef(39, 53),
  AyahRef(40, 60),
  AyahRef(41, 34),
  AyahRef(42, 19),
  AyahRef(47, 7),
  AyahRef(49, 10),
  AyahRef(49, 13),
  AyahRef(50, 16),
  AyahRef(51, 56),
  AyahRef(55, 13),
  AyahRef(57, 4),
  AyahRef(59, 18),
  AyahRef(64, 16),
  AyahRef(65, 2),
  AyahRef(65, 3),
  AyahRef(67, 2),
  AyahRef(93, 5),
  AyahRef(94, 5),
  AyahRef(94, 6),
  AyahRef(103, 1),
  AyahRef(112, 1),
];

AyahRef dailyAyah(DateTime day) {
  final n = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  return dailyAyahPool[n % dailyAyahPool.length];
}

// ---------------------------------------------------------------- khatm

/// Share of a Mushaf page each ayah represents (1 / ayahs on its page), so
/// progress is measured in pages: short Juz ʿAmma ayahs weigh less than the
/// long ayahs of Al-Baqarah. Sums to [totalPages].
final List<double> ayahPageWeights = () {
  final w = List<double>.filled(totalAyahs, 0);
  for (var p = 1; p <= totalPages; p++) {
    final (a, b) = pageRange(p);
    final share = 1 / (b - a + 1);
    for (var i = a; i <= b; i++) {
      w[i] = share;
    }
  }
  return w;
}();

/// Pages represented by a set of ayahs.
double pagesOf(Iterable<int> ayahs) => ayahs.fold<double>(0, (sum, i) => sum + ayahPageWeights[i]);

/// A plan to finish the whole Quran in [days] days starting on [start].
@immutable
class KhatmPlan {
  const KhatmPlan({required this.start, required this.days});

  /// `yyyy-MM-dd`.
  final String start;
  final int days;

  Map<String, Object?> toJson() => {'start': start, 'days': days};

  static KhatmPlan? fromJson(Object? j) {
    if (j is! Map) return null;
    final start = j['start'];
    final days = j['days'];
    if (start is! String || days is! num || days < 1) return null;
    return KhatmPlan(start: start, days: days.toInt());
  }

  @override
  bool operator ==(Object other) => other is KhatmPlan && other.start == start && other.days == days;

  @override
  int get hashCode => Object.hash(start, days);
}

/// Where a plan stands today. All amounts are Mushaf pages (of 604).
@immutable
class KhatmProgress {
  const KhatmProgress({
    required this.plan,
    required this.dayNumber,
    required this.readPages,
    required this.readTodayPages,
    required this.todayTargetPages,
    required this.allRead,
  });

  final KhatmPlan plan;

  /// 1-based day of the plan (can exceed `plan.days` when overdue).
  final int dayNumber;

  /// Pages read since the plan started (each ayah counted once).
  final double readPages;

  /// Pages read today that had not been read earlier in this plan.
  final double readTodayPages;

  /// Pages to read today so the plan finishes on time. What's left is
  /// re-spread over the remaining days, so a missed day is caught up gently.
  final double todayTargetPages;

  /// Every ayah has been read at least once since the start.
  final bool allRead;

  double get fraction => allRead ? 1 : (readPages / totalPages).clamp(0, 1).toDouble();
  bool get complete => allRead;
  int get daysLeft => (plan.days - dayNumber + 1).clamp(0, plan.days);

  /// Day for display ("Day 30 of 30" rather than "Day 35 of 30").
  int get dayShown => dayNumber.clamp(1, plan.days);

  /// The plan's last day has passed and the Quran isn't finished yet.
  bool get overdue => !complete && dayNumber > plan.days;

  /// The plan's original daily pace in pages.
  double get pace => totalPages / plan.days;

  /// Pages left as of this morning.
  double get remainingBeforeToday => (totalPages - (readPages - readTodayPages)).clamp(0, totalPages).toDouble();

  /// Days to add so the rest fits the original pace from today.
  int get extensionDays => (dayNumber - 1 + (remainingBeforeToday / pace).ceil()).clamp(plan.days + 1, 100000) - plan.days;

  /// Pages behind the straight-line schedule as of the end of yesterday.
  double get pagesBehind {
    final expectedYesterday = totalPages * ((dayNumber - 1).clamp(0, plan.days)) / plan.days;
    return (expectedYesterday - (readPages - readTodayPages)).clamp(0, totalPages).toDouble();
  }

  /// More than two days' worth behind (shown with the page count).
  bool get farBehind => !complete && pagesBehind > 2 * pace;

  /// Small tolerance so floating sums don't leave "0.01 pages" to go.
  bool get todayDone => complete || readTodayPages + 0.05 >= todayTargetPages;

  /// Whole pages for display.
  int get readPagesRounded => readPages.floor();
  int get targetPagesRounded => todayTargetPages.ceil();
  int get readTodayRounded => readTodayPages.round();

  /// Behind the straight-line schedule as of the end of yesterday (with a
  /// one-page grace), so today's reading can still catch up.
  bool get behind {
    if (complete) return false;
    return pagesBehind > 1;
  }
}

KhatmProgress khatmProgress({
  required KhatmPlan plan,
  required DateTime today,
  required double readPages,
  required double readTodayPages,
  bool allRead = false,
}) {
  final start = DateTime.parse(plan.start);
  final t = DateTime(today.year, today.month, today.day);
  final dayNumber = (t.difference(DateTime(start.year, start.month, start.day)).inHours / 24).round() + 1;
  final remainingBeforeToday = (totalPages - (readPages - readTodayPages)).clamp(0, totalPages).toDouble();
  final daysLeft = (plan.days - dayNumber + 1).clamp(1, plan.days);
  // Once overdue, ask for the plan's usual daily amount instead of everything left.
  final target = dayNumber > plan.days
      ? (totalPages / plan.days).clamp(0, remainingBeforeToday).toDouble()
      : remainingBeforeToday / daysLeft;
  return KhatmProgress(
    plan: plan,
    dayNumber: dayNumber.clamp(1, 100000),
    readPages: readPages,
    readTodayPages: readTodayPages,
    todayTargetPages: target,
    allRead: allRead || readPages >= totalPages - 0.001,
  );
}

/// First ayah not yet read in the plan (where "continue khatm" resumes).
int firstUnread(Set<int> read) {
  for (var i = 0; i < totalAyahs; i++) {
    if (!read.contains(i)) return i;
  }
  return 0;
}

/// Last ayah of today's portion when reading [pages] pages from [from].
int portionEnd(int from, double pages) {
  var sum = 0.0;
  var i = from;
  while (i < totalAyahs - 1 && sum + ayahPageWeights[i] < pages - 0.001) {
    sum += ayahPageWeights[i];
    i++;
  }
  return i;
}

// ---------------------------------------------------------------- hifz

/// Review ladder in days (spaced repetition for memorized surahs).
const hifzLadder = [1, 3, 7, 14, 30, 90];

/// How a memorization review went.
enum HifzGrade {
  /// Forgot a lot: start the ladder again tomorrow.
  again,

  /// Shaky: one step back down the ladder.
  hard,

  /// Solid: one step up.
  good,
}

/// Next (step, days until review) after a review.
(int, int) hifzNext(int step, {required HifzGrade grade}) {
  final next = switch (grade) {
    HifzGrade.again => 0,
    HifzGrade.hard => (step - 1).clamp(0, hifzLadder.length - 1),
    HifzGrade.good => (step + 1).clamp(0, hifzLadder.length - 1),
  };
  return (next, hifzLadder[next]);
}

// ---------------------------------------------------------------- streak

/// Consecutive days with any Quran reading ending today (or yesterday if
/// today has no reading yet — a day in progress never breaks the streak).
int readingStreak(Set<String> daysWithReading, DateTime today) {
  String key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  var d = DateTime(today.year, today.month, today.day);
  if (!daysWithReading.contains(key(d))) d = d.subtract(const Duration(days: 1));
  var n = 0;
  while (daysWithReading.contains(key(d))) {
    n++;
    d = DateTime(d.year, d.month, d.day - 1);
  }
  return n;
}
