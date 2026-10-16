import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// "Liquid glass" surface (iOS 26 style): frosted backdrop blur, a tinted
/// translucent body, a soft specular sheen from the top edge and a bright
/// hairline rim that fades around the shape. Used for the floating iOS tab
/// bar, reader toolbars and floating buttons.
///
/// Falls back to an opaque surface when the platform asks for high contrast
/// (the closest Flutter signal to "Reduce transparency").
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = 28,
    this.blur = 22,
    this.tint,
    this.opacity,
    this.padding,
    this.shadow = true,
    this.shape = BoxShape.rectangle,
    this.solid = false,
  });

  final Widget child;
  final double radius;
  final double blur;

  /// Body tint; defaults to the card colour.
  final Color? tint;

  /// Body opacity over the blurred backdrop (defaults per brightness).
  final double? opacity;
  final EdgeInsetsGeometry? padding;
  final bool shadow;
  final BoxShape shape;

  /// Opaque card surface instead of glass (Android, where the design uses
  /// Material surfaces).
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final highContrast = solid || (MediaQuery.maybeHighContrastOf(context) ?? false);
    final base = tint ?? c.card;
    final alpha = highContrast ? 1.0 : (opacity ?? (c.isDark ? 0.5 : 0.55));
    final borderRadius = shape == BoxShape.circle ? null : BorderRadius.circular(radius);

    Widget body = CustomPaint(
      painter: _GlassPainter(
        fill: base.withValues(alpha: alpha),
        dark: c.isDark,
        radius: radius,
        circle: shape == BoxShape.circle,
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );

    if (!highContrast) {
      // Blur plus a saturation lift, so colour behind the glass glows
      // through instead of turning grey (the "liquid" look).
      body = BackdropFilter(
        filter: ui.ImageFilter.compose(
          outer: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          inner: const ui.ColorFilter.matrix(_saturate),
        ),
        child: body,
      );
    }

    body = shape == BoxShape.circle
        ? ClipOval(child: body)
        : ClipRRect(borderRadius: borderRadius!, child: body);

    if (!shadow) return body;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: c.isDark ? 0.36 : 0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: c.isDark ? 0.25 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: body,
    );
  }
}

/// Saturation 1.6 colour matrix (luminance weights 0.2126/0.7152/0.0722).
const _saturate = <double>[
  1.4725, -0.4291, -0.0433, 0, 0, //
  -0.1275, 1.1709, -0.0433, 0, 0,
  -0.1275, -0.4291, 1.5567, 0, 0,
  0, 0, 0, 1, 0,
];

class _GlassPainter extends CustomPainter {
  _GlassPainter({required this.fill, required this.dark, required this.radius, required this.circle});

  final Color fill;
  final bool dark;
  final double radius;
  final bool circle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = circle
        ? RRect.fromRectAndRadius(rect, Radius.circular(size.shortestSide / 2))
        : RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.drawRRect(rrect, Paint()..color = fill);

    // Specular sheen: light falling on the top of the glass.
    final sheen = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: dark ? 0.10 : 0.38),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0, 0.55],
      ).createShader(rect);
    canvas.drawRRect(rrect, sheen);

    // Rim: bright at the top-left and bottom-right, nearly gone at the sides,
    // like light refracting through a thick edge.
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: dark ? 0.32 : 0.95),
          Colors.white.withValues(alpha: dark ? 0.06 : 0.25),
          Colors.white.withValues(alpha: dark ? 0.18 : 0.6),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(rect);
    canvas.drawRRect(rrect.deflate(0.5), rim);
  }

  @override
  bool shouldRepaint(_GlassPainter old) =>
      old.fill != fill || old.dark != dark || old.radius != radius || old.circle != circle;
}

/// Round glass icon button (reader toolbars).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.size = 44,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: Glass(
          shape: BoxShape.circle,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
