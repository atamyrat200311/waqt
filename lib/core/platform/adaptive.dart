import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Small helpers for the iOS vs Android differences called out in the design:
/// tab bar vs NavigationBar, "+" vs extended FAB, sheet grabber sizes, haptics.
abstract final class Adaptive {
  static bool isCupertino(BuildContext context) {
    final p = Theme.of(context).platform;
    return p == TargetPlatform.iOS || p == TargetPlatform.macOS;
  }

  /// Whether animations should be skipped (system "reduce motion").
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Duration helper that collapses to zero when reduce-motion is on.
  static Duration motion(BuildContext context, int ms) =>
      reduceMotion(context) ? Duration.zero : Duration(milliseconds: ms);

  /// Presents a modal bottom sheet with the design's grabber and radius.
  static Future<T?> showSheet<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool expand = false,
    bool useRootNavigator = true,
  }) {
    final c = context.colors;
    final cupertino = isCupertino(context);
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: useRootNavigator,
      useSafeArea: true,
      backgroundColor: c.card,
      barrierColor: c.scrim,
      elevation: 0,
      sheetAnimationStyle: AnimationStyle(
        duration: motion(context, 300),
        reverseDuration: motion(context, 220),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final child = builder(ctx);
        final column = Column(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            SheetGrabber(cupertino: cupertino),
            if (expand) Expanded(child: child) else Flexible(child: child),
          ],
        );
        // Tall sheets (expense) leave the top of the screen visible, as in
        // the design (sheet top at 118 of 844 ≈ 86 %).
        if (!expand) return column;
        return FractionallySizedBox(heightFactor: 0.86, child: column);
      },
    );
  }
}

class SheetGrabber extends StatelessWidget {
  const SheetGrabber({super.key, required this.cupertino});

  final bool cupertino;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Container(
        width: cupertino ? 36 : 32,
        height: cupertino ? 5 : 4,
        decoration: BoxDecoration(
          color: cupertino ? c.hairline : c.muted.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

/// Haptic vocabulary used across the app.
abstract final class Haptics {
  static void tap() => unawaited(HapticFeedback.selectionClick());
  static void light() => unawaited(HapticFeedback.lightImpact());
  static void success() => unawaited(HapticFeedback.mediumImpact());
  static void goal() => unawaited(HapticFeedback.heavyImpact());
}

/// [AnimatedSize] that is skipped entirely under reduce motion (a zero
/// duration makes AnimatedSize re-dirty itself during layout).
class MotionSize extends StatelessWidget {
  const MotionSize({super.key, required this.child, this.ms = 250, this.alignment = Alignment.topCenter});
  final Widget child;
  final int ms;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    if (Adaptive.reduceMotion(context)) return child;
    return AnimatedSize(duration: Duration(milliseconds: ms), alignment: alignment, child: child);
  }
}
