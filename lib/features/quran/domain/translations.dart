import 'package:flutter/foundation.dart';

/// A bundled Quran translation (see tool/build_content.dart).
@immutable
class QuranTranslation {
  const QuranTranslation(this.id, this.language, this.label, this.author, {this.rtl = false});

  /// Asset id: `assets/quran/<id>.json.gz`.
  final String id;

  /// Language code of the translation text.
  final String language;

  /// Language name in that language.
  final String label;
  final String author;
  final bool rtl;

  String get asset => 'assets/quran/$id.json.gz';
}

abstract final class QuranTranslations {
  static const all = <QuranTranslation>[
    QuranTranslation('en_sahih', 'en', 'English', 'Saheeh International'),
    QuranTranslation('ru_kuliev', 'ru', 'Русский', 'Эльмир Кулиев'),
    QuranTranslation('tr_diyanet', 'tr', 'Türkçe', 'Diyanet İşleri'),
    QuranTranslation('uz_mansour', 'uz', 'Ўзбекча', 'Алоуддин Мансур'),
    QuranTranslation('kk_altai', 'kk', 'Қазақша', 'Халифа Алтай'),
    QuranTranslation('ky_hakimov', 'ky', 'Кыргызча', 'Шамсалдин Хакимов'),
    QuranTranslation('tg_arifi', 'tg', 'Тоҷикӣ', 'IslamHouse'),
    QuranTranslation('az_musayev', 'az', 'Azərbaycanca', 'Alixan Musayev'),
  ];

  /// Default translation for an app language. Turkmen has no bundled
  /// translation; Russian is the most widely read alternative.
  static String defaultFor(String appLanguage) => switch (appLanguage) {
        'ru' || 'tk' => 'ru_kuliev',
        'tr' => 'tr_diyanet',
        _ => 'en_sahih',
      };

  static QuranTranslation byId(String id) => all.firstWhere((t) => t.id == id, orElse: () => all.first);

  /// The chosen translation id, falling back to the language default.
  static String resolve(String? chosen, String appLanguage) =>
      chosen != null && all.any((t) => t.id == chosen) ? chosen : defaultFor(appLanguage);
}
