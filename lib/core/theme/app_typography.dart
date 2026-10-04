import 'package:flutter/widgets.dart';

/// Type scale from the style guide. Fraunces and Plus Jakarta Sans are variable
/// fonts, so weight and optical size are applied as font variations as well as
/// [FontWeight] (Flutter does not map weight → `wght` axis on every backend).
abstract final class WaqtType {
  static const serifFamily = 'Fraunces';
  static const sansFamily = 'PlusJakartaSans';
  static const arabicFamily = 'Amiri';

  static const _tabular = [FontFeature.tabularFigures()];

  /// Fraunces and Jakarta lack ʿ ʾ (transliteration) and ﷺ; Amiri has them.
  /// Cyrillic is in none of the bundled fonts and uses the system font.
  static const _fallback = [arabicFamily];

  /// Fraunces display style. [tracking] is in em, like the CSS in the design.
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
        FontVariation.opticalSize((opsz ?? size).clamp(9, 144).toDouble()),
      ],
    );
  }

  /// Plus Jakarta Sans UI style.
  static TextStyle sans(
    double size, {
    double weight = 400,
    double tracking = 0,
    double? height,
    Color? color,
    FontStyle? style,
    TextDecoration? decoration,
    Color? decorationColor,
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
      fontFeatures: _tabular,
      fontVariations: [FontVariation.weight(weight)],
    );
  }

  static TextStyle arabic(double size, {double height = 1.5, Color? color}) {
    return TextStyle(
      fontFamily: arabicFamily,
      fontSize: size,
      height: height,
      color: color,
    );
  }

  // ---- Named roles from the style guide ----

  /// Hero countdown — Fraunces 66/350, opsz 144.
  static TextStyle hero({Color? color}) =>
      serif(66, weight: 350, tracking: -0.035, height: 1, opsz: 144, color: color);

  /// Screen title — Fraunces 34.
  static TextStyle title({Color? color}) =>
      serif(34, tracking: -0.015, height: 1.08, color: color);

  /// Section header — Fraunces 24.
  static TextStyle section({Color? color}) =>
      serif(24, tracking: -0.01, color: color);

  /// List/card item — Jakarta 17/600.
  static TextStyle item({Color? color}) => sans(17, weight: 600, color: color);

  /// Body — Jakarta 15.
  static TextStyle body({Color? color}) => sans(15, color: color);

  /// Kicker — 12/700 caps (call `.toUpperCase()` on the string).
  static TextStyle kicker({Color? color, double size = 12, double tracking = 0.09}) =>
      sans(size, weight: 700, tracking: tracking, color: color);

  static FontWeight _weight(double w) {
    final i = ((w / 100).round() * 100).clamp(100, 900);
    return FontWeight.values[(i ~/ 100) - 1];
  }
}
