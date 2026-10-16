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

  String get translit => surahTranslit[number - 1];
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
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ā': 'a', 'ã': 'a', 'å': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', 'ı': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'ō': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u',
  'ç': 'c', 'ş': 's', 'ğ': 'g', 'ñ': 'n', 'ň': 'n', 'ý': 'y', 'ž': 'z',
  'ḥ': 'h', 'ṣ': 's', 'ḍ': 'd', 'ṭ': 't', 'ẓ': 'z', 'ё': 'е', 'ʿ': '', 'ʾ': '', "'": '', '`': '', '’': '', '‘': '',
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
    final t = normalizeLatin(s.translit);
    return t.contains(nq) || normalizeLatin(s.meaning(language)).contains(nq) || normalizeLatin(s.meaning('en')).contains(nq);
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
  AyahRef(2, 152), AyahRef(2, 153), AyahRef(2, 186), AyahRef(2, 286), AyahRef(3, 8), AyahRef(3, 139),
  AyahRef(3, 159), AyahRef(3, 173), AyahRef(3, 190), AyahRef(4, 28), AyahRef(6, 162), AyahRef(7, 23),
  AyahRef(8, 46), AyahRef(9, 40), AyahRef(9, 51), AyahRef(11, 88), AyahRef(12, 87), AyahRef(13, 11),
  AyahRef(13, 28), AyahRef(14, 7), AyahRef(16, 97), AyahRef(16, 128), AyahRef(17, 24), AyahRef(17, 80),
  AyahRef(18, 10), AyahRef(20, 25), AyahRef(20, 114), AyahRef(21, 87), AyahRef(23, 118), AyahRef(25, 63),
  AyahRef(25, 74), AyahRef(28, 24), AyahRef(29, 69), AyahRef(31, 17), AyahRef(33, 41), AyahRef(39, 10),
  AyahRef(39, 53), AyahRef(40, 60), AyahRef(41, 34), AyahRef(42, 30), AyahRef(47, 7), AyahRef(49, 10),
  AyahRef(49, 13), AyahRef(50, 16), AyahRef(51, 56), AyahRef(55, 13), AyahRef(57, 4), AyahRef(59, 18),
  AyahRef(64, 16), AyahRef(65, 2), AyahRef(65, 3), AyahRef(67, 2), AyahRef(93, 5), AyahRef(94, 5),
  AyahRef(94, 6), AyahRef(103, 1), AyahRef(112, 1),
];

AyahRef dailyAyah(DateTime day) {
  final n = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  return dailyAyahPool[n % dailyAyahPool.length];
}

// ---------------------------------------------------------------- khatm

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

/// Where a plan stands today.
@immutable
class KhatmProgress {
  const KhatmProgress({
    required this.plan,
    required this.dayNumber,
    required this.readTotal,
    required this.readToday,
    required this.todayTarget,
  });

  final KhatmPlan plan;

  /// 1-based day of the plan (can exceed `plan.days` when overdue).
  final int dayNumber;

  /// Distinct ayahs read since the plan started.
  final int readTotal;
  final int readToday;

  /// Ayahs to read today so the plan finishes on time (re-spread daily, so a
  /// missed day is caught up gently over the remaining days).
  final int todayTarget;

  double get fraction => (readTotal / totalAyahs).clamp(0, 1).toDouble();
  bool get complete => readTotal >= totalAyahs;
  int get daysLeft => (plan.days - dayNumber + 1).clamp(0, plan.days);
  bool get todayDone => complete || readToday >= todayTarget;

  /// Behind the straight-line schedule as of the end of yesterday (with a
  /// one-page grace), so today's reading can still catch up.
  bool get behind {
    if (complete) return false;
    final expectedYesterday = totalAyahs * (dayNumber - 1) / plan.days;
    return (readTotal - readToday) + 10 < expectedYesterday;
  }

  /// Roughly 10.3 ayahs per Mushaf page on average.
  static int pagesFor(int ayahs) => (ayahs * totalPages / totalAyahs).ceil();
}

KhatmProgress khatmProgress({
  required KhatmPlan plan,
  required DateTime today,
  required int readTotal,
  required int readToday,
}) {
  final start = DateTime.parse(plan.start);
  final t = DateTime(today.year, today.month, today.day);
  final dayNumber = (t.difference(DateTime(start.year, start.month, start.day)).inHours / 24).round() + 1;
  final remainingBeforeToday = (totalAyahs - (readTotal - readToday)).clamp(0, totalAyahs);
  final daysLeft = (plan.days - dayNumber + 1).clamp(1, plan.days);
  final target = (remainingBeforeToday / daysLeft).ceil();
  return KhatmProgress(
    plan: plan,
    dayNumber: dayNumber.clamp(1, 100000),
    readTotal: readTotal,
    readToday: readToday,
    todayTarget: target,
  );
}

// ---------------------------------------------------------------- hifz

/// Review ladder in days (spaced repetition for memorized surahs).
const hifzLadder = [1, 3, 7, 14, 30, 90];

/// Next (step, days until review) after a review rated [strong] or not.
(int, int) hifzNext(int step, {required bool strong}) {
  final next = strong ? (step + 1).clamp(0, hifzLadder.length - 1) : 0;
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
