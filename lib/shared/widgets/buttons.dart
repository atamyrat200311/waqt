import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/dimens.dart';
import 'waqt_icon.dart';

enum PillStyle { primary, mint, outline, brass, brassSoft, fill, ghost }

/// Rounded pill button (44 tall by default) used for "Start", "Made up"…
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = PillStyle.primary,
    this.icon,
    this.height = 44,
    this.minWidth = 0,
    this.radius = Radii.pill,
    this.fontSize = 15,
    this.expand = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillStyle style;
  final WaqtIconData? icon;
  final double height;
  final double minWidth;
  final double radius;
  final double fontSize;
  final bool expand;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null;
    final (bg, fg, side) = switch (style) {
      PillStyle.primary => (c.primary, c.onPrimary, BorderSide.none),
      PillStyle.mint => (c.mint, c.onMint, BorderSide.none),
      PillStyle.outline => (Colors.transparent, c.muted, BorderSide(color: c.hairline)),
      PillStyle.brass => (c.brassText, c.onBrassText, BorderSide.none),
      PillStyle.brassSoft => (c.brassSoft, c.brassText, BorderSide.none),
      PillStyle.fill => (c.fill, c.ink, BorderSide.none),
      PillStyle.ghost => (Colors.transparent, c.accent, BorderSide.none),
    };
    final effectiveBg = enabled || style == PillStyle.outline ? bg : c.fill;
    final effectiveFg = enabled ? fg : c.muted;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: side);
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height, minWidth: minWidth),
        child: Material(
          color: effectiveBg,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    WaqtIcon(icon!, size: 18, color: effectiveFg),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: WaqtType.sans(fontSize, weight: 600, color: effectiveFg),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width 56-tall button with radius 18 (Save, Add to qada…).
class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = PillStyle.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillStyle style;

  @override
  Widget build(BuildContext context) => PillButton(
        label: label,
        onPressed: onPressed,
        style: style,
        height: 56,
        radius: Radii.bigButton,
        fontSize: 16,
        expand: true,
      );
}

/// Round icon button (44×44) — header "+", sheet close, bell toggles.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.size = 44,
    this.iconSize = 22,
    this.background,
    this.foreground,
    this.border = false,
  });

  final WaqtIconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double size;
  final double iconSize;
  final Color? background;
  final Color? foreground;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hit = size < kMinTouch ? kMinTouch : size;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: hit,
        child: Center(
          child: Material(
            color: background ?? Colors.transparent,
            shape: CircleBorder(side: border ? BorderSide(color: c.hairline) : BorderSide.none),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox.square(
                dimension: size,
                child: Center(child: WaqtIcon(icon, size: iconSize, color: foreground ?? c.accent)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
