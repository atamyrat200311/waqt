import 'package:flutter/foundation.dart';

import '../../quran/domain/quran.dart' show normalizeArabic, normalizeLatin;

/// A bundled hadith collection (see tool/build_content.dart).
@immutable
class HadithBook {
  const HadithBook(this.id, this.languages, this.arabicName, {this.featured = false});

  final String id;

  /// Edition languages bundled: `ara`, `eng`, `rus`, `tur`.
  final List<String> languages;
  final String arabicName;

  /// Short collections suited to daily reading (hadith of the day pool).
  final bool featured;

  List<String> get translations => [for (final l in languages) if (l != 'ara') l];
  String asset(String lang) => 'assets/hadith/${id}_$lang.json.gz';
}

abstract final class HadithBooks {
  static const nawawi = HadithBook('nawawi', ['ara', 'eng', 'tur'], 'الأربعون النووية', featured: true);
  static const qudsi = HadithBook('qudsi', ['ara', 'eng'], 'الأحاديث القدسية', featured: true);
  static const bukhari = HadithBook('bukhari', ['ara', 'eng', 'rus', 'tur'], 'صحيح البخاري');
  static const muslim = HadithBook('muslim', ['ara', 'eng', 'rus', 'tur'], 'صحيح مسلم');

  static const all = [nawawi, qudsi, bukhari, muslim];

  static HadithBook? byId(String id) => all.where((b) => b.id == id).firstOrNull;

  /// Hadith edition language for an app language (Turkmen readers default
  /// to Russian, the most widely read of the bundled translations).
  static String preferredLanguage(String appLanguage) => switch (appLanguage) {
        'tr' => 'tur',
        'ru' || 'tk' => 'rus',
        _ => 'eng',
      };

  /// Best available edition of [book] for [preferred] (falls back to English).
  static String languageFor(HadithBook book, String preferred) =>
      book.languages.contains(preferred) ? preferred : 'eng';
}

@immutable
class HadithSection {
  const HadithSection(this.id, this.name, this.first, this.last);
  final int id;
  final String name;

  /// Hadith number range (inclusive).
  final num first;
  final num last;
}

@immutable
class Hadith {
  const Hadith(this.number, this.text, this.grade, this.section);

  /// Hadith number (may be fractional in a few Muslim editions, e.g. 2.01).
  final num number;
  final String text;

  /// Grading(s), joined with " · " (empty for the Sahihayn).
  final String grade;
  final int section;

  String get label => number == number.roundToDouble() ? '${number.toInt()}' : '$number';
}

/// One language edition of a book.
class HadithEdition {
  HadithEdition(this.book, this.language, this.sections, this.hadiths)
      : _byNumber = {for (final h in hadiths) h.number: h};

  factory HadithEdition.fromJson(HadithBook book, String language, Map<String, Object?> json) {
    final sections = [
      for (final s in (json['s']! as List).cast<List<Object?>>())
        HadithSection(s[0]! as int, s[1]! as String, s[2]! as num, s[3]! as num),
    ];
    final hadiths = [
      for (final h in (json['h']! as List).cast<List<Object?>>())
        Hadith(h[0]! as num, h[1]! as String, h[2]! as String, (h[3]! as num).toInt()),
    ];
    return HadithEdition(book, language, sections, hadiths);
  }

  final HadithBook book;
  final String language;
  final List<HadithSection> sections;
  final List<Hadith> hadiths;
  final Map<num, Hadith> _byNumber;

  Hadith? byNumber(num n) => _byNumber[n];

  /// Hadith in a section, in order.
  List<Hadith> inSection(int sectionId) => [for (final h in hadiths) if (h.section == sectionId) h];

  /// Books with a single section (40 hadith) are shown as one flat list.
  bool get flat => sections.length <= 1;
}

/// Case/diacritic-insensitive search; a number (`123` or `#123`) jumps.
List<Hadith> searchHadith(HadithEdition e, List<String> normalized, String query, {int limit = 150}) {
  final q = query.trim();
  if (q.isEmpty) return const [];
  final n = num.tryParse(q.replaceFirst('#', ''));
  if (n != null) {
    final h = e.byNumber(n);
    return h == null ? const [] : [h];
  }
  if (q.length < 3) return const [];
  final arabic = RegExp('[؀-ۿ]').hasMatch(q);
  final nq = arabic ? normalizeArabic(q) : normalizeLatin(q);
  final out = <Hadith>[];
  for (var i = 0; i < e.hadiths.length && out.length < limit; i++) {
    if (normalized[i].contains(nq)) out.add(e.hadiths[i]);
  }
  return out;
}

List<String> normalizeHadithTexts(HadithEdition e) => [
      for (final h in e.hadiths)
        e.language == 'ara' ? normalizeArabic(h.text) : normalizeLatin(h.text),
    ];

/// Hadith of the day: rotates through the featured (40-hadith) books.
({String book, num number}) hadithOfDay(DateTime day, {required int nawawiCount, required int qudsiCount}) {
  final n = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  final total = nawawiCount + qudsiCount;
  final i = n % total;
  return i < nawawiCount ? (book: 'nawawi', number: i + 1) : (book: 'qudsi', number: i - nawawiCount + 1);
}
