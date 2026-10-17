import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../domain/tajweed.dart';

/// Rule colours, after the usual Mushaf tajweed key. Silent letters
/// (hamzat wasl, lam shamsiyyah…) are muted instead of coloured.
const _light = <String, Color>{
  'ham_wasl': Color(0xFF9AA09C),
  'slnt': Color(0xFF9AA09C),
  'laam_shamsiyah': Color(0xFF9AA09C),
  'madda_normal': Color(0xFF537FFF),
  'madda_permissible': Color(0xFF4050FF),
  'madda_necessary': Color(0xFF000EBC),
  'madda_obligatory': Color(0xFF2144C1),
  'qalaqah': Color(0xFFDD0008),
  'ikhafa_shafawi': Color(0xFFD500B7),
  'ikhafa': Color(0xFF9400A8),
  'idgham_shafawi': Color(0xFF58B800),
  'iqlab': Color(0xFF26BFFD),
  'idgham_ghunnah': Color(0xFF169777),
  'idgham_wo_ghunnah': Color(0xFF169200),
  'idgham_mutajanisayn': Color(0xFF9AA09C),
  'idgham_mutaqaribayn': Color(0xFF9AA09C),
  'ghunnah': Color(0xFFFF7E1E),
};

/// Colour of a rule on a light or dark page (dark: lighter so it stays
/// readable on the near-black background).
Color? tajweedColor(String? rule, {required bool dark}) {
  final c = _light[rule];
  if (c == null || !dark) return c;
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness(hsl.lightness.clamp(0.68, 0.85)).withSaturation((hsl.saturation * 0.9).clamp(0, 1)).toColor();
}

final _waqf = RegExp('[\u06D6-\u06DC]');

/// Spans for one ayah with tajweed colours. Pause (waqf) signs are tinted
/// too. [recognizer] is attached to every span so a tap anywhere in the
/// ayah still registers.
List<TextSpan> tajweedSpans(String tagged, {required bool dark, GestureRecognizer? recognizer}) {
  final pause = TextStyle(color: dark ? const Color(0xFFFF7BA9) : const Color(0xFFC2185B));
  final out = <TextSpan>[];
  for (final r in parseTajweed(tagged)) {
    final color = tajweedColor(r.rule, dark: dark);
    if (r.rule != null || !_waqf.hasMatch(r.text)) {
      out.add(TextSpan(text: r.text, recognizer: recognizer, style: color == null ? null : TextStyle(color: color)));
      continue;
    }
    var pos = 0;
    for (final m in _waqf.allMatches(r.text)) {
      if (m.start > pos) out.add(TextSpan(text: r.text.substring(pos, m.start), recognizer: recognizer));
      out.add(TextSpan(text: m.group(0), recognizer: recognizer, style: pause));
      pos = m.end;
    }
    if (pos < r.text.length) out.add(TextSpan(text: r.text.substring(pos), recognizer: recognizer));
  }
  return out;
}
