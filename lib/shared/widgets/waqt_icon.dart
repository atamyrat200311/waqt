import 'package:flutter/widgets.dart';
import 'package:path_drawing/path_drawing.dart';

/// Icon set from the design: 24 px grid, 2 px stroke, round caps and joins
/// (Lucide shapes). Paths are copied from the artboards; rects and circles are
/// expressed as path data so everything goes through one painter.
class WaqtIconData {
  const WaqtIconData(this.paths, {this.filled = false});

  final List<String> paths;

  /// Filled icons (the sadaqa heart) are filled *and* stroked.
  final bool filled;
}

String _rect(double x, double y, double w, double h, double r) =>
    'M${x + r} ${y}h${w - 2 * r}a$r $r 0 0 1 $r ${r}v${h - 2 * r}'
    'a$r $r 0 0 1 -$r ${r}h-${w - 2 * r}a$r $r 0 0 1 -$r -${r}v-${h - 2 * r}'
    'a$r $r 0 0 1 $r -${r}z';

String _circle(double cx, double cy, double r) =>
    'M${cx - r} ${cy}a$r $r 0 1 0 ${2 * r} 0a$r $r 0 1 0 -${2 * r} 0z';

abstract final class WaqtIcons {
  static const today = WaqtIconData([
    'M12 3v3M4.9 7.9 7 10M19.1 7.9 17 10M2 18h20M7 18a5 5 0 0 1 10 0',
  ]);
  static final tools = WaqtIconData([
    _rect(3, 3, 7.5, 7.5, 2),
    _rect(13.5, 3, 7.5, 7.5, 2),
    _rect(3, 13.5, 7.5, 7.5, 2),
    _rect(13.5, 13.5, 7.5, 7.5, 2),
  ]);
  static final me = WaqtIconData([_circle(12, 8, 4), 'M4 21a8 8 0 0 1 16 0']);
  static const book = WaqtIconData([
    'M2 4h6a4 4 0 0 1 4 4v13a3 3 0 0 0-3-3H2z',
    'M22 4h-6a4 4 0 0 0-4 4v13a3 3 0 0 1 3-3h7z',
  ]);
  static const moon = WaqtIconData(['M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z']);
  static final calendar =
      WaqtIconData([_rect(3, 5, 18, 16, 3), 'M3 10h18M8 3v4M16 3v4']);
  static const qada = WaqtIconData(['M3 12a9 9 0 1 0 3-6.7L3 8', 'M3 3v5h5']);
  static const bell = WaqtIconData([
    'M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9',
    'M10.3 21a1.94 1.94 0 0 0 3.4 0',
  ]);
  static const bellOff = WaqtIconData([
    'M8.7 3A6 6 0 0 1 18 8a21.3 21.3 0 0 0 .6 5',
    'M17 17H3s3-2 3-9a4.67 4.67 0 0 1 .3-1.7',
    'M10.3 21a1.94 1.94 0 0 0 3.4 0',
    'm2 2 20 20',
  ]);
  static final pin = WaqtIconData([
    'M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z',
    _circle(12, 10, 3),
  ]);
  static final lock = WaqtIconData([_rect(4, 11, 16, 10, 2), 'M8 11V7a4 4 0 0 1 8 0v4']);
  static const plus = WaqtIconData(['M12 5v14M5 12h14']);
  static const minus = WaqtIconData(['M5 12h14']);
  static const check = WaqtIconData(['M5 12.5l4.5 4.5L19 7.5']);
  static const heart = WaqtIconData([
    'M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z',
  ], filled: true);
  static const chevronRight = WaqtIconData(['m9 18 6-6-6-6']);
  static const chevronLeft = WaqtIconData(['m15 18-6-6 6-6']);
  static const chevronDown = WaqtIconData(['m6 9 6 6 6-6']);
  static const close = WaqtIconData(['M18 6 6 18M6 6l12 12']);
  static final users = WaqtIconData([
    'M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2',
    _circle(9, 7, 4),
    'M22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75',
  ]);
  static final clock = WaqtIconData([_circle(12, 12, 9), 'M12 7v5l3 2']);
  static const backspace = WaqtIconData([
    'M21 5H9l-7 7 7 7h12a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1Z',
    'm16 9-5 6M11 9l5 6',
  ]);
  static final sliders = WaqtIconData([
    'M4 6h9M17 6h3M4 12h3M11 12h9M4 18h11M19 18h1',
    _circle(15, 6, 2),
    _circle(9, 12, 2),
    _circle(17, 18, 2),
  ]);
  static final compass = WaqtIconData([
    _circle(12, 12, 10),
    'm16.24 7.76-1.804 5.411a2 2 0 0 1-1.265 1.265L7.76 16.24l1.804-5.411a2 2 0 0 1 1.265-1.265z',
  ]);
  static final beads = WaqtIconData([
    _circle(12, 4.5, 1.6),
    _circle(18.4, 8.2, 1.6),
    _circle(18.4, 15.8, 1.6),
    _circle(12, 19.5, 1.6),
    _circle(5.6, 15.8, 1.6),
    _circle(5.6, 8.2, 1.6),
  ]);
  static const trash = WaqtIconData([
    'M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2',
  ]);
  static final globe = WaqtIconData([
    _circle(12, 12, 10),
    'M2 12h20M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z',
  ]);
  static const locate = WaqtIconData(['M3 11l19-9-9 19-2-8-8-2z']);
  static final battery = WaqtIconData([_rect(2, 7, 16, 10, 2), 'M22 11v2']);
  static final sun = WaqtIconData([
    _circle(12, 12, 4),
    'M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41',
  ]);
  static const arrowRight = WaqtIconData(['M5 12h14M12 5l7 7-7 7']);
  static const edit = WaqtIconData([
    'M12 20h9',
    'M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z',
  ]);
  static final info = WaqtIconData([_circle(12, 12, 10), 'M12 16v-4M12 8h.01']);
  static final widgets = WaqtIconData([
    _rect(3, 3, 18, 8, 3),
    _rect(3, 14, 8, 7, 2.5),
    _rect(14, 14, 7, 7, 2.5),
  ]);
  static const moveToday = WaqtIconData(['M5 12h14M12 5l7 7-7 7', 'M3 4v16']);
  static const wallet = WaqtIconData([
    'M19 7V5a2 2 0 0 0-2-2H5a2 2 0 0 0 0 4h15a1 1 0 0 1 1 1v4h-3a2 2 0 0 0 0 4h3a1 1 0 0 0 1-1v-2',
    'M3 5v14a2 2 0 0 0 2 2h15a1 1 0 0 0 1-1v-4',
  ]);
  static const listCheck = WaqtIconData([
    'M11 18H3M15 18l2 2 4-4M16 12H3M16 6H3',
  ]);
}

class WaqtIcon extends StatelessWidget {
  const WaqtIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 2,
    this.semanticLabel,
  });

  final WaqtIconData icon;
  final double? size;
  final Color? color;
  final double strokeWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final s = size ?? theme.size ?? 24;
    final col = color ?? theme.color ?? const Color(0xFF14201B);
    final painted = SizedBox.square(
      dimension: s,
      child: CustomPaint(
        painter: _IconPainter(icon, col, strokeWidth),
      ),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: painted);
    return Semantics(label: semanticLabel, child: painted);
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.icon, this.color, this.strokeWidth);

  final WaqtIconData icon;
  final Color color;
  final double strokeWidth;

  static final Map<String, Path> _cache = {};

  static Path _path(String d) => _cache.putIfAbsent(d, () => parseSvgPathData(d));

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.scale(scale);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (final d in icon.paths) {
      final p = _path(d);
      if (icon.filled) canvas.drawPath(p, fill);
      canvas.drawPath(p, stroke);
    }
  }

  @override
  bool shouldRepaint(_IconPainter old) =>
      old.icon != icon || old.color != color || old.strokeWidth != strokeWidth;
}
