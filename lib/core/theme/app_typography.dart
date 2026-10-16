import 'package:flutter/widgets.dart';

/// Type scale from the style guide, re-cut for readability: Literata (a
/// serif designed for long-form screen reading) for display text and Inter
/// for UI. Both are variable fonts with full Latin-extended (Turkmen ň ý ž),
/// Turkish and Cyrillic coverage, so every app language renders in the brand
/// faces. Weight and optical size are applied as font variations as well as
/// [FontWeight] (Flutter does not map weight → `wght` axis on every backend).
abstract final class WaqtType {
  static const serifFamily = 'Literata';
  static const sansFamily = 'Inter';
  static const arabicFamily = 'Amiri';

  /// Quran text faces (OFL). Amiri Quran is tuned for the Uthmani script and
  /// its pause marks; Scheherazade New is a plainer, very legible Naskh.
  static const quranFamily = 'AmiriQuran';
  static const quranAltFamily = 'ScheherazadeNew';

  static const _tabular = [FontFeature.tabularFigures()];

  /// Literata and Inter lack ﷺ and Arabic; Amiri has them.
  static const _fallback = [arabicFamily];

  /// Literata display style. [tracking] is in em, like the CSS in the design.
  static TextStyle serif(
    double size, {
    double weight = 400,
    double tracking = 0,
    double? height,
    double? opsz,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: serifFamily,
      fontFamilyFallback: _fallback,
      fontSize: size,
      fontWeight: _weight(weight),
      letterSpacing: tracking * size,
      height: height,
      color: color,
      fontFeatures: _tabular,
      fontVariations: [
        FontVariation.weight(weight),
        FontVariation.opticalSize((opsz ?? size).clamp(7, 72).toDouble()),
      ],
    );
  }

  /// Inter UI style.
  static TextStyle sans(
    double size, {
    double weight = 400,
    double tracking = 0,
    double? height,
    Color? color,
    FontStyle? style,
    TextDecoration? decoration,
    Color? decorationColor,
    bool tabular = false,
  }) {
    return TextStyle(
      fontFamily: sansFamily,
      fontFamilyFallback: _fallback,
      fontSize: size,
      fontWeight: _weight(weight),
      letterSpacing: tracking * size,
      height: height,
      color: color,
      fontStyle: style,
      decoration: decoration,
      decorationColor: decorationColor,
      // Tabular figures only for numbers that update in place (times,
      // counters); Inter's tabular set also widens hyphens in words.
      fontFeatures: tabular ? _tabular : null,
      fontVariations: [
        FontVariation.weight(weight),
        FontVariation.opticalSize(size.clamp(14, 32).toDouble()),
      ],
    );
  }

  static TextStyle arabic(double size, {double height = 1.5, Color? color, double weight = 400}) {
    return TextStyle(
      fontFamily: arabicFamily,
      fontSize: size,
      height: height,
      color: color,
      fontWeight: _weight(weight),
    );
  }

  /// Quran ayah text. [family] is one of [quranFamily] / [quranAltFamily].
  static TextStyle quran(double size, {String family = quranFamily, double height = 2.0, Color? color}) {
    return TextStyle(
      fontFamily: family,
      fontFamilyFallback: const [arabicFamily],
      fontSize: size,
      height: height,
      color: color,
    );
  }

  // ---- Named roles from the style guide ----

  /// Hero countdown — Literata 66/400, display optical size.
  static TextStyle hero({Color? color}) =>
      serif(66, weight: 400, tracking: -0.035, height: 1, opsz: 72, color: color);

  /// Screen title — Literata 34/500.
  static TextStyle title({Color? color}) =>
      serif(34, weight: 500, tracking: -0.02, height: 1.1, color: color);

  /// Section header — Literata 24/500.
  static TextStyle section({Color? color}) =>
      serif(24, weight: 500, tracking: -0.015, color: color);

  /// List/card item — Inter 17/600.
  static TextStyle item({Color? color}) => sans(17, weight: 600, tracking: -0.01, color: color);

  /// Body — Inter 15.
  static TextStyle body({Color? color}) => sans(15, color: color);

  /// Kicker — 12/700 caps (call `.toUpperCase()` on the string).
  static TextStyle kicker({Color? color, double size = 12, double tracking = 0.09}) =>
      sans(size, weight: 700, tracking: tracking, color: color);

  static FontWeight _weight(double w) {
    final i = ((w / 100).round() * 100).clamp(100, 900);
    return FontWeight.values[(i ~/ 100) - 1];
  }
}
