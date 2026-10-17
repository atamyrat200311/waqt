import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';

/// Faint girih-style star lattice used on emerald hero surfaces.
class StarPattern extends StatelessWidget {
  const StarPattern({super.key, this.size = 260, this.opacity = 0.09, this.color = Colors.white});

  final double size;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: ShaderMask(
          shaderCallback: (r) => const RadialGradient(
            center: Alignment(0.2, -0.2),
            radius: 0.75,
            colors: [Colors.black, Colors.black, Colors.transparent],
            stops: [0, 0.15, 0.68],
          ).createShader(r),
          blendMode: BlendMode.dstIn,
          child: Opacity(
            opacity: opacity,
            child: CustomPaint(size: Size.square(size), painter: _StarPainter(color)),
          ),
        ),
      );
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const cell = 44.0;
    for (var x = 0.0; x < size.width; x += cell) {
      for (var y = 0.0; y < size.height; y += cell) {
        final r = Rect.fromLTWH(x + 13, y + 13, 18, 18);
        canvas.drawRect(r, paint);
        canvas.save();
        canvas.translate(x + 22, y + 22);
        canvas.rotate(math.pi / 4);
        canvas.drawRect(const Rect.fromLTWH(-9, -9, 18, 18), paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
}

/// Eight-point star (two overlapping squares) with a number inside — the
/// surah / ayah / Name badge.
class StarBadge extends StatelessWidget {
  const StarBadge({
    super.key,
    required this.label,
    required this.color,
    this.size = 38,
    this.fill,
    this.textColor,
  });

  final String label;
  final Color color;
  final Color? fill;
  final Color? textColor;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _BadgePainter(color, fill),
          child: Center(
            // The badge is a fixed shape: shrink the number rather than overflow.
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size * 0.16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: WaqtType.sans(label.length > 2 ? size * 0.27 : size * 0.33, weight: 700, color: textColor ?? color),
                ),
              ),
            ),
          ),
        ),
      );
}

class _BadgePainter extends CustomPainter {
  _BadgePainter(this.color, this.fill);
  final Color color;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final half = size.width * 0.34;
    final sq = Rect.fromCenter(center: Offset.zero, width: half * 2, height: half * 2);
    final path = Path()..addRRect(RRect.fromRectAndRadius(sq, Radius.circular(half * 0.18)));
    final rotated = path.transform((Matrix4.identity()..rotateZ(math.pi / 4)).storage);
    final star = Path.combine(PathOperation.union, path, rotated).shift(c);
    if (fill != null) canvas.drawPath(star, Paint()..color = fill!);
    canvas.drawPath(
      star,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_BadgePainter old) => old.color != color || old.fill != fill;
}

/// Ornamental ayah-end marker ۝ with the number in Arabic-Indic digits,
/// rendered as inline text so it flows with the ayah.
String ayahEndMark(String arabicNumber) => '۝$arabicNumber';
