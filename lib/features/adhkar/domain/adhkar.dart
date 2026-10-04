import 'dart:convert';

import '../../../data/db/enums.dart';

/// One dhikr from `assets/adhkar/adhkar.json`.
class AdhkarItem {
  const AdhkarItem({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translations,
    required this.count,
    required this.source,
  });

  final String id;
  final String arabic;
  final String transliteration;

  /// Language code → meaning.
  final Map<String, String> translations;

  /// How many times to recite.
  final int count;

  /// Hadith / Qurʾān reference shown under the card.
  final String source;

  String translation(String lang) => translations[lang] ?? translations['en'] ?? '';

  /// Long texts use the smaller Arabic size (design: > 60 characters).
  bool get isLong => arabic.length > 60;

  factory AdhkarItem.fromJson(Map<String, Object?> j) => AdhkarItem(
        id: j['id']! as String,
        arabic: j['ar']! as String,
        transliteration: j['translit'] as String? ?? '',
        translations: (j['text'] as Map? ?? const {}).map((k, v) => MapEntry(k as String, v as String)),
        count: (j['count'] as num?)?.toInt() ?? 1,
        source: j['source'] as String? ?? '',
      );
}

class AdhkarCatalog {
  const AdhkarCatalog(this.sets);

  final Map<AdhkarSet, List<AdhkarItem>> sets;

  List<AdhkarItem> items(AdhkarSet set) => sets[set] ?? const [];

  factory AdhkarCatalog.fromJsonString(String json) {
    final root = jsonDecode(json) as Map<String, Object?>;
    final raw = root['sets'] as Map<String, Object?>? ?? const {};
    return AdhkarCatalog({
      for (final s in AdhkarSet.values)
        s: [
          for (final e in (raw[s.name] as List?) ?? const [])
            AdhkarItem.fromJson((e as Map).cast<String, Object?>()),
        ],
    });
  }

  static const empty = AdhkarCatalog({});
}

/// Progress of one set on one day. Pure.
class AdhkarProgress {
  const AdhkarProgress(this.items, this.counts);

  final List<AdhkarItem> items;

  /// itemId → recited count.
  final Map<String, int> counts;

  int countOf(AdhkarItem i) => (counts[i.id] ?? 0).clamp(0, i.count);
  bool isItemDone(AdhkarItem i) => countOf(i) >= i.count;
  int get doneItems => items.where(isItemDone).length;
  bool get isComplete => items.isNotEmpty && doneItems == items.length;
  bool get isStarted => counts.values.any((c) => c > 0);

  /// Index of the first unfinished item (where the reader resumes).
  int get resumeIndex {
    final i = items.indexWhere((e) => !isItemDone(e));
    return i < 0 ? 0 : i;
  }

  /// 0…1 across the whole set, counting partial items.
  double get fraction {
    if (items.isEmpty) return 0;
    var sum = 0.0;
    for (final i in items) {
      sum += countOf(i) / i.count;
    }
    return sum / items.length;
  }

  /// Rough reading time in minutes (≈ 0.35 s per Arabic word + 0.6 s per
  /// repetition), at least 1.
  static int estimatedMinutes(List<AdhkarItem> items) {
    var seconds = 0.0;
    for (final i in items) {
      final words = i.arabic.split(RegExp(r'\s+')).length;
      seconds += i.count * (0.6 + words * 0.35);
    }
    final m = (seconds / 60).round();
    return m < 1 ? 1 : m;
  }
}
