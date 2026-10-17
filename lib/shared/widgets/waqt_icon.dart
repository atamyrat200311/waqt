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
  static const arrowLeft = WaqtIconData(['M19 12H5M12 19l-7-7 7-7']);
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

  // ---- Added for Quran, Library and the new tools (Lucide shapes) ----
  static const quran = WaqtIconData([
    'M12 7v14',
    'M3 18a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h5a4 4 0 0 1 4 4 4 4 0 0 1 4-4h5a1 1 0 0 1 1 1v13a1 1 0 0 1-1 1h-6a3 3 0 0 0-3 3 3 3 0 0 0-3-3z',
    'M6 8h2M6 12h2M16 8h2M16 12h2',
  ]);
  static const library = WaqtIconData(['m16 6 4 14', 'M12 6v14', 'M8 8v12', 'M4 4v16']);
  static final search = WaqtIconData([_circle(11, 11, 7.5), 'm21 21-4.3-4.3']);
  static const bookmark = WaqtIconData(['m19 21-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z']);
  static const bookmarkFilled =
      WaqtIconData(['m19 21-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z'], filled: true);
  static const share = WaqtIconData([
    'M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8',
    'M16 6l-4-4-4 4',
    'M12 2v13',
  ]);
  static final copy = WaqtIconData([
    _rect(8, 8, 14, 14, 2),
    'M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2',
  ]);
  static const textSize = WaqtIconData(['M4 7V4h16v3', 'M9 20h6', 'M12 4v16']);
  static final eye = WaqtIconData([
    'M2.06 12.35a1 1 0 0 1 0-.7 10.75 10.75 0 0 1 19.88 0 1 1 0 0 1 0 .7 10.75 10.75 0 0 1-19.88 0',
    _circle(12, 12, 3),
  ]);
  static const eyeOff = WaqtIconData([
    'M10.73 5.08a10.74 10.74 0 0 1 11.2 6.57 1 1 0 0 1 0 .7 10.75 10.75 0 0 1-1.44 2.49',
    'M14.08 14.16a3 3 0 0 1-4.24-4.24',
    'M17.48 17.5a10.75 10.75 0 0 1-15.42-5.15 1 1 0 0 1 0-.7 10.75 10.75 0 0 1 4.45-5.14',
    'm2 2 20 20',
  ]);
  static final target = WaqtIconData([_circle(12, 12, 10), _circle(12, 12, 6), _circle(12, 12, 2)]);
  static const flame = WaqtIconData([
    'M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.07-2.14-.22-4.05 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.15.43-2.29 1-3a2.5 2.5 0 0 0 2.5 2.5z',
  ]);
  static const sparkles = WaqtIconData([
    'M9.94 15.5A2 2 0 0 0 8.5 14.06l-6.14-1.58a.5.5 0 0 1 0-.96L8.5 9.94A2 2 0 0 0 9.94 8.5l1.58-6.14a.5.5 0 0 1 .96 0L14.06 8.5A2 2 0 0 0 15.5 9.94l6.14 1.58a.5.5 0 0 1 0 .96L15.5 14.06a2 2 0 0 0-1.44 1.44l-1.58 6.14a.5.5 0 0 1-.96 0z',
    'M20 3v4M22 5h-4',
  ]);
  static const handHeart = WaqtIconData([
    'M11 14h2a2 2 0 1 0 0-4h-3c-.6 0-1.1.2-1.4.6L3 16',
    'm7 20 1.6-1.4c.3-.4.8-.6 1.4-.6h4c1.1 0 2.1-.4 2.8-1.2l4.6-4.4a2 2 0 0 0-2.75-2.91l-4.2 3.9',
    'm2 15 6 6',
    'M19.5 8.5c.7-.7 1.5-1.6 1.5-2.7A2.73 2.73 0 0 0 16 4a2.78 2.78 0 0 0-5 1.8c0 1.2.8 2 1.5 2.8L16 12Z',
  ]);
  static const star = WaqtIconData([
    'M11.53 2.3a.53.53 0 0 1 .95 0l2.31 4.68a2.12 2.12 0 0 0 1.6 1.16l5.16.76a.53.53 0 0 1 .3.9l-3.74 3.64a2.12 2.12 0 0 0-.61 1.88l.88 5.14a.53.53 0 0 1-.77.56l-4.62-2.43a2.12 2.12 0 0 0-1.97 0L6.4 21.01a.53.53 0 0 1-.77-.56l.88-5.14a2.12 2.12 0 0 0-.61-1.88L2.16 9.8a.53.53 0 0 1 .3-.91l5.16-.75a2.12 2.12 0 0 0 1.6-1.16z',
  ]);
  static const learn = WaqtIconData([
    'M21.42 10.92a1 1 0 0 0-.02-1.84L12.83 5.18a2 2 0 0 0-1.66 0L2.6 9.08a1 1 0 0 0 0 1.83l8.57 3.91a2 2 0 0 0 1.66 0z',
    'M22 10v6',
    'M6 12.5V16a6 3 0 0 0 12 0v-3.5',
  ]);
  static const scroll = WaqtIconData([
    'M15 12h-5M15 8h-5',
    'M19 17V5a2 2 0 0 0-2-2H4',
    'M8 21h12a2 2 0 0 0 2-2v-1a1 1 0 0 0-1-1H11a1 1 0 0 0-1 1v1a2 2 0 1 1-4 0V5a2 2 0 1 0-4 0v2a1 1 0 0 0 1 1h3',
  ]);
  static final calculator = WaqtIconData([
    _rect(4, 2, 16, 20, 2),
    'M8 6h8M16 14v4M16 10h.01M12 10h.01M8 10h.01M12 14h.01M8 14h.01M12 18h.01M8 18h.01',
  ]);
  static final table = WaqtIconData([_rect(3, 3, 18, 18, 2), 'M3 9h18M3 15h18M9 3v18']);
  static const download = WaqtIconData(['M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4', 'm7 10 5 5 5-5', 'M12 15V3']);
  static const upload = WaqtIconData(['M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4', 'm17 8-5-5-5 5', 'M12 3v12']);
  static const list = WaqtIconData(['M3 12h.01M3 18h.01M3 6h.01M8 12h13M8 18h13M8 6h13']);
  static const repeat = WaqtIconData(['m17 2 4 4-4 4', 'M3 11v-1a4 4 0 0 1 4-4h14', 'm7 22-4-4 4-4', 'M21 13v1a4 4 0 0 1-4 4H3']);
  static const droplet = WaqtIconData(['M12 22a7 7 0 0 0 7-7c0-2-1-3.9-3-5.5s-3.5-4-4-6.5c-.5 2.5-2 4.9-4 6.5C6 11.1 5 13 5 15a7 7 0 0 0 7 7z']);
  static const dumbbell = WaqtIconData([
    'M14.4 14.4 9.6 9.6',
    'M18.66 21.51a2 2 0 1 1-2.83-2.83l-1.77 1.77a2 2 0 1 1-2.83-2.83l6.37-6.37a2 2 0 1 1 2.83 2.83l-1.77 1.77a2 2 0 1 1 2.83 2.83z',
    'm21.5 21.5-1.4-1.4M3.9 3.9 2.5 2.5',
    'M6.4 12.77a2 2 0 1 1-2.83-2.83l1.77-1.77a2 2 0 1 1-2.83-2.83l2.83-2.83a2 2 0 1 1 2.83 2.83l1.77-1.77a2 2 0 1 1 2.83 2.83z',
  ]);
  static const leaf = WaqtIconData([
    'M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10Z',
    'M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12',
  ]);
  static const pen = WaqtIconData([
    'M21.17 6.81a1 1 0 0 0-3.99-3.99L3.84 16.17a2 2 0 0 0-.5.83l-1.32 4.35a.5.5 0 0 0 .62.62l4.35-1.32a2 2 0 0 0 .83-.5z',
  ]);
  static final smile = WaqtIconData([_circle(12, 12, 10), 'M8 14s1.5 2 4 2 4-2 4-2M9 9h.01M15 9h.01']);
  static const kaaba = WaqtIconData([
    'M4 7.5 12 4l8 3.5v10L12 21l-8-3.5z',
    'M4 7.5 12 11l8-3.5M12 11v10',
    'M4 10.5l8 3.5 8-3.5',
  ]);
  static const hourglass = WaqtIconData([
    'M5 22h14M5 2h14',
    'M17 22v-4.17a2 2 0 0 0-.59-1.42L12 12l-4.41 4.41A2 2 0 0 0 7 17.83V22',
    'M7 2v4.17a2 2 0 0 0 .59 1.42L12 12l4.41-4.41A2 2 0 0 0 17 6.17V2',
  ]);
  static const play = WaqtIconData(['M6 3l14 9-14 9z']);
  static const home = WaqtIconData([
    'M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8',
    'M3 10a2 2 0 0 1 .71-1.53l7-6a2 2 0 0 1 2.58 0l7 6A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z',
  ]);
  static const food = WaqtIconData([
    'M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2',
    'M7 2v20',
    'M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3Zm0 0v7',
  ]);
  static const plane = WaqtIconData([
    'M17.8 19.2 16 11l3.5-3.5C21 6 21.5 4 21 3c-1-.5-3 0-4.5 1.5L13 8 4.8 6.2c-.5-.1-.9.1-1.1.5l-.3.5c-.2.5-.1 1 .3 1.3L9 12l-2 3H4l-1 1 3 2 2 3 1-1v-3l3-2 3.5 5.3c.3.4.8.5 1.3.3l.5-.2c.4-.3.6-.7.5-1.2z',
  ]);
  static const mosque = WaqtIconData([
    'M3 21h18',
    'M5 21V11M19 21V11M5 11V8M19 11V8',
    'M8 21v-5a4 4 0 0 1 8 0v5',
    'M12 3c-2 2-6 3.5-6 7h12c0-3.5-4-5-6-7z',
  ]);
  static const shield = WaqtIconData([
    'M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z',
  ]);
  static const heartOutline = WaqtIconData([
    'M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z',
  ]);

  /// Icon by content key (duas.json / guides.json / habits).
  static WaqtIconData byKey(String key) => switch (key) {
        'sun' => sun,
        'moon' => moon,
        'home' => home,
        'food' => food,
        'travel' => plane,
        'mosque' => mosque,
        'heart' => heartOutline,
        'shield' => shield,
        'family' => users,
        'book' => book,
        'star' => star,
        'droplet' => droplet,
        'hands' => handHeart,
        'kaaba' => kaaba,
        'quran' => quran,
        'dumbbell' => dumbbell,
        'leaf' => leaf,
        'pen' => pen,
        'smile' => smile,
        'wallet' => wallet,
        'beads' => beads,
        'clock' => clock,
        _ => star,
      };
  static final medal = WaqtIconData([
    'M7.21 15 2.66 7.14a2 2 0 0 1 .13-2.2L4.4 2.8A2 2 0 0 1 6 2h12a2 2 0 0 1 1.6.8l1.6 2.14a2 2 0 0 1 .14 2.2L16.79 15',
    'M11 12 5.12 2.2M13 12l5.88-9.8M8 7h8',
    _circle(12, 17, 5),
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
