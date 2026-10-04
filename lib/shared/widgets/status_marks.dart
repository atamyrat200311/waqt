import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/platform/adaptive.dart';
import '../../core/theme/app_colors.dart';
import 'waqt_icon.dart';

/// Overshoot curve of the design's check "pop" (cubic-bezier(.3,1.4,.5,1)).
const popCurve = Cubic(0.3, 1.4, 0.5, 1);

/// Done: filled brass circle with a check that pops in and draws.
class DoneMark extends StatelessWidget {
  const DoneMark({
    super.key,
    this.size = 26,
    this.color,
    this.checkColor,
    this.animate = true,
  });

  final double size;
  final Color? color;
  final Color? checkColor;

  /// Pop in on first build (set false for static lists).
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color ?? c.brass, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: _DrawnCheck(
        size: size * 0.58,
        color: checkColor ?? c.hero,
        animate: animate && !Adaptive.reduceMotion(context),
      ),
    );
    if (!animate || Adaptive.reduceMotion(context)) return circle;
    return circle
        .animate()
        .scaleXY(begin: 0.3, end: 1, duration: 480.ms, curve: popCurve)
        .fadeIn(duration: 200.ms);
  }
}

class _DrawnCheck extends StatefulWidget {
  const _DrawnCheck({required this.size, required this.color, required this.animate});
  final double size;
  final Color color;
  final bool animate;

  @override
  State<_DrawnCheck> createState() => _DrawnCheckState();
}

class _DrawnCheckState extends State<_DrawnCheck> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
    value: widget.animate ? 0 : 1,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _CheckPainter(Curves.easeOut.transform(_c.value), widget.color),
        ),
      );
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final path = Path()
      ..moveTo(5 * s, 12.5 * s)
      ..lineTo(9.5 * s, 17 * s)
      ..lineTo(19 * s, 7.5 * s);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (t >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    for (final m in path.computeMetrics()) {
      canvas.drawPath(m.extractPath(0, m.length * t), paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.t != t || old.color != color;
}

/// Current: brass ring with a centre dot.
class CurrentMark extends StatelessWidget {
  const CurrentMark({super.key, this.size = 26, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final col = color ?? context.colors.brass;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: col, width: 2)),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.31,
        height: size * 0.31,
        decoration: BoxDecoration(color: col, shape: BoxShape.circle),
      ),
    );
  }
}

/// Upcoming: dashed circle.
class UpcomingMark extends StatelessWidget {
  const UpcomingMark({super.key, this.size = 26, this.color, this.strokeWidth = 1.5});
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _DashedCirclePainter(color ?? context.colors.muted, strokeWidth),
      );
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter(this.color, this.strokeWidth);
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (size.width - strokeWidth) / 2;
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    const dashes = 14;
    const sweep = 2 * math.pi / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: r), i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color || old.strokeWidth != strokeWidth;
}

/// Missed (added to qada): soft brass circle with the qada arrow.
class MissedMark extends StatelessWidget {
  const MissedMark({super.key, this.size = 26, this.background, this.color});
  final double size;
  final Color? background;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background ?? c.brassSoft,
        border: Border.all(color: color ?? c.brass, width: 1.5),
      ),
      alignment: Alignment.center,
      child: WaqtIcon(WaqtIcons.qada, size: size * 0.55, color: color ?? c.brassText, strokeWidth: 2.6),
    );
  }
}

/// Excused (period mode): circle with a horizontal dash.
class ExcusedMark extends StatelessWidget {
  const ExcusedMark({super.key, this.size = 26, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final col = color ?? context.colors.muted;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: col, width: 1.5)),
      alignment: Alignment.center,
      child: WaqtIcon(WaqtIcons.minus, size: size * 0.55, color: col, strokeWidth: 2.6),
    );
  }
}
