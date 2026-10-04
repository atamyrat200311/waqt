import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Compass dial from the Tools artboard: the dial (ticks + N) turns with the
/// phone, the brass needle points at the Qibla, the ink mark on top is where
/// the phone points. Scales from the 148 px design.
class QiblaCompass extends StatefulWidget {
  const QiblaCompass({super.key, required this.bearing, required this.heading, this.size = 148});

  /// Qibla bearing from north (degrees).
  final double bearing;

  /// Phone heading from north, or null without a sensor (dial stays north-up).
  final double? heading;
  final double size;

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> {
  /// Heading unwrapped across 359°→0° so the dial never spins the long way.
  late double _continuous = widget.heading ?? 0;

  @override
  void didUpdateWidget(QiblaCompass old) {
    super.didUpdateWidget(old);
    final h = widget.heading ?? 0;
    var delta = (h - _continuous) % 360;
    if (delta > 180) delta -= 360;
    _continuous += delta;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: _continuous),
        duration: const Duration(milliseconds: 180),
        builder: (context, smooth, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _CompassPainter(
            bearing: widget.bearing,
            heading: smooth,
            ink: c.ink,
            muted: c.muted,
            hairline: c.hairline,
            bg: c.bg,
            brass: c.brass,
            brassSoft: c.brassSoft,
            brassText: c.brassText,
          ),
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({
    required this.bearing,
    required this.heading,
    required this.ink,
    required this.muted,
    required this.hairline,
    required this.bg,
    required this.brass,
    required this.brassSoft,
    required this.brassText,
  });

  final double bearing;
  final double heading;
  final Color ink;
  final Color muted;
  final Color hairline;
  final Color bg;
  final Color brass;
  final Color brassSoft;
  final Color brassText;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 148;
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    canvas.drawCircle(center, r, Paint()..color = bg);
    canvas.drawCircle(
      center,
      r - 0.5,
      Paint()
        ..color = hairline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    double rad(double d) => d * math.pi / 180;

    // Ticks every 6°, major every 90°, rotated against the heading.
    for (var i = 0; i < 60; i++) {
      final major = i % 15 == 0;
      final a = rad(i * 6 - heading);
      final outer = r - 4 * s;
      final inner = outer - (major ? 9 : 5) * s;
      final dir = Offset(math.sin(a), -math.cos(a));
      canvas.drawLine(
        center + dir * inner,
        center + dir * outer,
        Paint()
          ..color = (major ? ink : muted).withValues(alpha: major ? 0.9 : 0.45)
          ..strokeWidth = 1.5 * s
          ..strokeCap = StrokeCap.round,
      );
    }

    // N label.
    final na = rad(-heading);
    final nPos = center + Offset(math.sin(na), -math.cos(na)) * (52 * s);
    final tp = TextPainter(
      text: TextSpan(text: 'N', style: WaqtType.sans(12 * s, weight: 700, color: brassText)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, nPos - Offset(tp.width / 2, tp.height / 2));

    // Phone direction marker at the top.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, 0), width: 4 * s, height: 12 * s),
        Radius.circular(2 * s),
      ),
      Paint()..color = ink,
    );

    // Needle towards the Qibla.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rad(bearing - heading));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(-1 * s, -48 * s, 2 * s, 48 * s), Radius.circular(1 * s)),
      Paint()..color = brass,
    );
    final head = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, -52 * s), width: 12 * s, height: 12 * s),
      Radius.circular(2 * s),
    );
    canvas.drawRRect(head, Paint()..color = ink);
    canvas.save();
    canvas.clipRRect(head);
    canvas.drawRect(
      Rect.fromLTWH(head.left, head.top, head.width, 3 * s),
      Paint()..color = brass,
    );
    canvas.restore();
    canvas.restore();

    // Centre.
    canvas.drawCircle(center, 10 * s, Paint()..color = brassSoft);
    canvas.drawCircle(center, 6 * s, Paint()..color = brass);
  }

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.heading != heading || old.bearing != bearing || old.ink != ink || old.bg != bg;
}
