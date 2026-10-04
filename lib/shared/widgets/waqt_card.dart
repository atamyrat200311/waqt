import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';

/// Card from the design: hairline border, no shadow, radius 24 (iOS) / 28
/// (Android). Optional [onTap] adds an ink ripple clipped to the shape.
class WaqtCard extends StatelessWidget {
  const WaqtCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.border = true,
    this.radius,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool border;
  final double? radius;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = BorderRadius.circular(radius ?? Radii.card(context));
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = InkWell(onTap: onTap, borderRadius: r, child: content);
    }
    final card = Material(
      color: color ?? c.card,
      shape: RoundedRectangleBorder(
        borderRadius: r,
        side: border ? BorderSide(color: c.hairline) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
    if (onTap == null && semanticLabel == null) return card;
    return Semantics(button: onTap != null, label: semanticLabel, child: card);
  }
}

/// Grouped list card: rows separated by hairlines (Qada rows, Tasks, Settings).
class WaqtGroup extends StatelessWidget {
  const WaqtGroup({super.key, required this.children, this.radius});

  final List<Widget> children;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return WaqtCard(
      padding: EdgeInsets.zero,
      radius: radius,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: c.hairline),
            children[i],
          ],
        ],
      ),
    );
  }
}
