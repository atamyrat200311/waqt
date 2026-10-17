import 'package:flutter/foundation.dart';

/// A word (or the ayah-end number) on a Mushaf line.
@immutable
class MushafWord {
  const MushafWord(this.text, this.ayah, {this.isEnd = false});

  /// Arabic text. For [isEnd] this is the ayah number in Arabic-Indic digits.
  final String text;

  /// Global ayah index 0…6235.
  final int ayah;
  final bool isEnd;
}

/// One printed line of the Madani Mushaf (1-based [number] on the page;
/// lines taken by surah banners are simply absent).
@immutable
class MushafLine {
  const MushafLine(this.number, this.words);
  final int number;
  final List<MushafWord> words;
}

/// Parses assets/quran/mushaf_lines.json.gz (see tool/build_mushaf.dart):
/// 604 pages → lines.
List<List<MushafLine>> parseMushaf(Object? json) => [
      for (final page in (json! as List).cast<List<Object?>>())
        [
          for (final line in page.cast<Map<String, Object?>>())
            MushafLine(line['n']! as int, [
              for (final t in (line['w']! as List).cast<List<Object?>>())
                MushafWord(t[0]! as String, (t[1]! as num).toInt(), isEnd: t.length > 2),
            ]),
        ],
    ];

final _marks = RegExp('[ً-ٰٟـۖ-ۭ‌-‏ ]');
final _allah = RegExp('^[وفبلكت]?ا?لله\$');

/// Whether [word] is the name "Allah" (alone or with a one-letter prefix:
/// بِٱللَّهِ، وَٱللَّهُ، لِلَّهِ…) — drawn in a distinct colour in the Mushaf style.
bool isAllahWord(String word) => _allah.hasMatch(word.replaceAll('ٱ', 'ا').replaceAll(_marks, ''));
