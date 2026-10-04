import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/platform/adaptive.dart';

/// Circular progress ring (tasbih / adhkar counter). Animates between values
/// in 200–250 ms unless reduce motion is on.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    required this.track,
    this.strokeWidth = 4,
    this.size = 184,
    this.child,
  });

  final double value;
  final Color color;
  final Color track;
  final double strokeWidth;
  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(end: value.clamp(0, 1)),
        duration: Adaptive.motion(context, 230),
        curve: Curves.easeOut,
        builder: (context, v, child) => CustomPaint(
          size: Size.square(size),
          painter: _RingPainter(v, color, track, strokeWidth),
          child: child,
        ),
        child: SizedBox.square(dimension: size, child: child),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color, this.track, this.strokeWidth);
  final double value;
  final Color color;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(strokeWidth / 2 + 2);
    canvas.drawArc(
      r,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    if (value <= 0) return;
    canvas.drawArc(
      r,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

/// Brass ring that expands and fades on every tap (design "tap ripple").
class TapRipple extends StatefulWidget {
  const TapRipple({super.key, required this.trigger, required this.color, this.inset = 6});

  /// Changes on every tap (e.g. the count).
  final int trigger;
  final Color color;
  final double inset;

  @override
  State<TapRipple> createState() => _TapRippleState();
}

class _TapRippleState extends State<TapRipple> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500), value: 1);

  @override
  void didUpdateWidget(TapRipple old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && !Adaptive.reduceMotion(context)) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = Curves.easeOut.transform(_c.value);
            return Padding(
              padding: EdgeInsets.all(widget.inset),
              child: Transform.scale(
                scale: 0.85 + 0.4 * t,
                child: Opacity(
                  opacity: (0.5 * (1 - t)).clamp(0, 1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.color, width: 2),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            );
          },
        ),
      );
}
