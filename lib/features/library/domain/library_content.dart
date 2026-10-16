import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../quran/domain/quran.dart' show normalizeArabic, normalizeLatin;

/// Localized text from the content JSON ({en, tk, tr, ru}). A leading "?"
/// marks a translation for review and is stripped for display.
@immutable
class Loc {
  const Loc(this.values);
  factory Loc.fromJson(Object? j) =>
      Loc(j is Map ? {for (final e in j.entries) '${e.key}': '${e.value}'} : const {});

  final Map<String, String> values;

  String of(String lang) {
    final v = values[lang] ?? values['en'] ?? '';
    final s = v.startsWith('?') ? v.substring(1) : v;
    return s.isEmpty ? (values['en'] ?? '') : s;
  }

  bool get isEmpty => values.isEmpty;
}

@immutable
class DuaCategory {
  const DuaCategory(this.id, this.icon, this.title);
  final String id;
  final String icon;
  final Loc title;
}

@immutable
class Dua {
  const Dua({
    required this.id,
    required this.category,
    required this.title,
    required this.arabic,
    required this.translit,
    required this.text,
    required this.source,
    required this.count,
  });

  final String id;
  final String category;
  final Loc title;
  final String arabic;
  final String translit;
  final Loc text;
  final String source;
  final int count;

  bool matches(String query, String lang) {
    final q = query.trim();
    if (q.isEmpty) return true;
    if (RegExp('[؀-ۿ]').hasMatch(q)) return normalizeArabic(arabic).contains(normalizeArabic(q));
    final nq = normalizeLatin(q);
    return normalizeLatin(title.of(lang)).contains(nq) ||
        normalizeLatin(text.of(lang)).contains(nq) ||
        normalizeLatin(translit).contains(nq) ||
        normalizeLatin(title.of('en')).contains(nq);
  }
}

@immutable
class DuaCatalog {
  const DuaCatalog(this.categories, this.duas);

  factory DuaCatalog.fromJson(String raw) {
    final j = jsonDecode(raw) as Map<String, Object?>;
    return DuaCatalog(
      [
        for (final c in (j['categories']! as List).cast<Map<String, Object?>>())
          DuaCategory(c['id']! as String, c['icon'] as String? ?? 'star', Loc.fromJson(c['title'])),
      ],
      [
        for (final d in (j['duas']! as List).cast<Map<String, Object?>>())
          Dua(
            id: d['id']! as String,
            category: d['category']! as String,
            title: Loc.fromJson(d['title']),
            arabic: d['ar'] as String? ?? '',
            translit: d['translit'] as String? ?? '',
            text: Loc.fromJson(d['text']),
            source: d['source'] as String? ?? '',
            count: (d['count'] as num?)?.toInt() ?? 1,
          ),
      ],
    );
  }

  static const empty = DuaCatalog([], []);

  final List<DuaCategory> categories;
  final List<Dua> duas;

  Dua? byId(String id) => duas.where((d) => d.id == id).firstOrNull;
}

@immutable
class AllahName {
  const AllahName(this.number, this.arabic, this.translit, this.meaning, this.note);
  final int number;
  final String arabic;
  final String translit;
  final Loc meaning;
  final Loc note;

  static List<AllahName> listFromJson(String raw) => [
        for (final n in (jsonDecode(raw) as List).cast<Map<String, Object?>>())
          AllahName(
            (n['n']! as num).toInt(),
            n['ar']! as String,
            n['translit']! as String,
            Loc.fromJson(n['meaning']),
            Loc.fromJson(n['note']),
          ),
      ];
}

@immutable
class GuideStep {
  const GuideStep(this.title, this.text, this.arabic, this.translit);
  final Loc title;
  final Loc text;
  final String? arabic;
  final String? translit;
}

@immutable
class Guide {
  const Guide({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.intro,
    required this.steps,
    required this.note,
  });

  final String id;
  final String icon;
  final Loc title;
  final Loc subtitle;
  final Loc intro;
  final List<GuideStep> steps;
  final Loc note;

  static List<Guide> listFromJson(String raw) => [
        for (final g in (jsonDecode(raw) as List).cast<Map<String, Object?>>())
          Guide(
            id: g['id']! as String,
            icon: g['icon'] as String? ?? 'book',
            title: Loc.fromJson(g['title']),
            subtitle: Loc.fromJson(g['subtitle']),
            intro: Loc.fromJson(g['intro']),
            note: Loc.fromJson(g['note']),
            steps: [
              for (final s in (g['steps'] as List? ?? const []).cast<Map<String, Object?>>())
                GuideStep(
                  Loc.fromJson(s['title']),
                  Loc.fromJson(s['text']),
                  (s['ar'] as String?)?.trim().isEmpty ?? true ? null : s['ar'] as String,
                  (s['translit'] as String?)?.trim().isEmpty ?? true ? null : s['translit'] as String,
                ),
            ],
          ),
      ];
}

/// Multiple-choice question for the Names practice: the right meaning plus
/// three distinct distractors, shuffled.
@immutable
class NameQuestion {
  const NameQuestion(this.name, this.options, this.answer);
  final AllahName name;
  final List<AllahName> options;
  final int answer;
}

List<NameQuestion> buildNameQuiz(List<AllahName> names, {int count = 10, int? seed}) {
  if (names.length < 4) return const [];
  final rnd = seed == null ? null : _Lcg(seed);
  int next(int max) => rnd?.next(max) ?? DateTime.now().microsecondsSinceEpoch % max;
  final pool = [...names];
  final out = <NameQuestion>[];
  final used = <int>{};
  while (out.length < count && used.length < names.length) {
    final q = pool[next(pool.length)];
    if (!used.add(q.number)) continue;
    final opts = <AllahName>[q];
    while (opts.length < 4) {
      final d = pool[next(pool.length)];
      if (!opts.any((o) => o.number == d.number)) opts.add(d);
    }
    // Shuffle deterministically.
    for (var i = opts.length - 1; i > 0; i--) {
      final j = next(i + 1);
      final t = opts[i];
      opts[i] = opts[j];
      opts[j] = t;
    }
    out.add(NameQuestion(q, opts, opts.indexWhere((o) => o.number == q.number)));
  }
  return out;
}

class _Lcg {
  _Lcg(this._state);
  int _state;
  int next(int max) {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return _state % max;
  }
}
