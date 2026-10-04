import 'package:flutter/widgets.dart';

import '../platform/adaptive.dart';

/// Spacing and radius constants from the design artboards.
abstract final class Gap {
  static const xs = 4.0;
  static const s = 6.0;
  static const m = 10.0;
  static const l = 12.0;
  static const xl = 16.0;
  static const xxl = 20.0;
  static const section = 28.0;

  /// Horizontal margin of cards on every screen.
  static const screen = 16.0;

  /// Horizontal padding of large titles.
  static const title = 20.0;
}

abstract final class Radii {
  static const pill = 999.0;
  static const hero = 28.0;
  static const sheet = 28.0;
  static const bigButton = 18.0;
  static const iconTile = 14.0;
  static const smallTile = 13.0;
  static const segment = 12.0;
  static const segmentInner = 9.0;
  static const listGroup = 20.0;

  /// Cards are 24 on iOS and 28 on Android (Material 3 large shape).
  static double card(BuildContext context) =>
      Adaptive.isCupertino(context) ? 24 : 28;

  /// Hero/tool cards use 28 on both platforms.
  static double heroCard(BuildContext context) => 28;
}

/// Minimum touch target from the accessibility bar.
const double kMinTouch = 44;
