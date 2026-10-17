import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../data/settings/app_settings.dart';
import '../domain/mushaf.dart';
import '../domain/quran.dart';
import 'reader_widgets.dart';

final _waqf = RegExp('[ۖ-ۜ]');

/// Spans for a word: pause (waqf) signs in [ReaderPalette.waqf], the name of
/// Allah in [ReaderPalette.allah].
List<TextSpan> mushafWordSpans(String word, ReaderPalette p) {
  final allah = isAllahWord(word);
  final spans = <TextSpan>[];
  var pos = 0;
  for (final m in _waqf.allMatches(word)) {
    if (m.start > pos) spans.add(TextSpan(text: word.substring(pos, m.start), style: allah ? TextStyle(color: p.allah) : null));
    spans.add(TextSpan(text: m.group(0), style: TextStyle(color: p.waqf)));
    pos = m.end;
  }
  if (pos < word.length) spans.add(TextSpan(text: word.substring(pos), style: allah ? TextStyle(color: p.allah) : null));
  return spans;
}

/// Plain ayah text with the Mushaf colours (used outside the page layout).
List<TextSpan> mushafTextSpans(String text, ReaderPalette p) {
  final out = <TextSpan>[];
  final words = text.split(' ');
  for (var i = 0; i < words.length; i++) {
    out.addAll(mushafWordSpans(words[i], p));
    if (i < words.length - 1) out.add(const TextSpan(text: ' '));
  }
  return out;
}

/// The page body: the Madani layout line by line, every line stretched to the
/// page width like the printed Mushaf. One font size per page, chosen so the
/// widest line fits.
class MushafLines extends StatelessWidget {
  const MushafLines({
    super.key,
    required this.page,
    required this.lines,
    required this.prefs,
    required this.palette,
    required this.onAyah,
    required this.surahHeader,
  });

  final int page;
  final List<MushafLine> lines;
  final ReaderPrefs prefs;
  final ReaderPalette palette;
  final ValueChanged<int> onAyah;

  /// Banner shown before the first line of a surah (given the surah number).
  final Widget Function(int surah) surahHeader;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final maxW = box.maxWidth * 0.992;
        final family = quranFamily(prefs);
        TextStyle styleAt(double size) =>
            WaqtType.quran(size, family: family, height: 2.0, color: palette.ink);

        final f0 = prefs.arabicSize;
        // Natural width of a line at size f0.
        double measure(String text, double size) {
          final tp = TextPainter(
            text: TextSpan(text: text, style: styleAt(size)),
            textDirection: TextDirection.rtl,
            textScaler: scaler,
          )..layout();
          return tp.width;
        }

        double natural(MushafLine l, double size) {
          final medal = size * 1.35;
          final space = size * 0.2;
          var w = 0.0;
          for (final x in l.words) {
            w += x.isEnd ? medal : measure(x.text, size);
          }
          return w + space * (l.words.length - 1);
        }

        var scale = 1.0;
        for (final l in lines) {
          final w = natural(l, f0);
          if (w > maxW) scale = math.min(scale, maxW / w);
        }
        final size = f0 * scale;

        final seen = <int>{};
        final children = <Widget>[];
        for (final l in lines) {
          final first = l.words.first;
          if (!first.isEnd && !seen.contains(first.ayah) && AyahRef.fromIndex(first.ayah).ayah == 1) {
            children.add(surahHeader(AyahRef.fromIndex(first.ayah).surah));
          }
          for (final x in l.words) {
            seen.add(x.ayah);
          }
          final w = natural(l, size);
          final extra = maxW - w;
          final gaps = l.words.length - 1;
          // Stretch full lines; centre short ones (last lines of a surah…).
          final justify = gaps > 0 && w >= maxW * 0.8 && extra / gaps < size * 1.0;
          children.add(
            SizedBox(
              width: maxW,
              child: Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: justify ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < l.words.length; i++) ...[
                    if (!justify && i > 0) SizedBox(width: size * 0.2),
                    _word(l.words[i], size, styleAt(size)),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.center, children: children);
      },
    );
  }

  Widget _word(MushafWord w, double size, TextStyle style) {
    if (w.isEnd) return _Medallion(number: w.text, size: size * 1.35, palette: palette);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => onAyah(w.ayah),
      child: Text.rich(TextSpan(children: mushafWordSpans(w.text, palette)), style: style, textDirection: TextDirection.rtl),
    );
  }
}

/// Gold ayah-end medallion with the number.
class _Medallion extends StatelessWidget {
  const _Medallion({required this.number, required this.size, required this.palette});
  final String number;
  final double size;
  final ReaderPalette palette;

  @override
  Widget build(BuildContext context) {
    final digits = number.length;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.medal,
        border: Border.all(color: palette.medalRing, width: size * 0.07),
      ),
      child: Text(
        number,
        textDirection: TextDirection.rtl,
        style: WaqtType.sans(size * (digits >= 3 ? 0.36 : 0.44), weight: 700, color: palette.medalInk, height: 1),
      ),
    );
  }
}
