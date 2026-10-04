import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../shared/widgets/status_marks.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../prayer/domain/prayer_engine.dart';
import '../application/today_providers.dart';
import '../domain/today_logic.dart';

/// The emerald hero: next prayer (or iftar), big countdown, day arc and the
/// five prayer chips.
class HeroCard extends ConsumerWidget {
  const HeroCard({super.key, required this.onChip});

  final void Function(Prayer prayer) onChip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final now = ref.watch(prayerNowProvider);
    final ramadan = ref.watch(ramadanTodayProvider);
    final marks = ref.watch(todayMarksProvider).value ?? const {};
    final target = heroTarget(now, ramadan: ramadan);
    final fastBar = ramadan ? ref.watch(ramadanFastBarProvider).value : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Gap.screen),
      decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(Radii.hero)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(right: -70, top: -80, child: _StarPattern()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (target.iftar ? l.homeRamadanKicker : l.homeNextPrayer).toUpperCase(),
                  style: WaqtType.kicker(color: c.onHeroMuted),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        target.iftar ? l.homeIftar : l.prayer(target.prayer),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: WaqtType.serif(28, height: 1, color: c.onHero),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      target.iftar ? l.homeMaghribAt(hhmm(target.time)) : hhmm(target.time),
                      style: WaqtType.sans(16, weight: 500, color: c.onHeroMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _Countdown(target: target.time),
                if (fastBar != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    l.homeSuhoorLine(hhmm(_tomorrowFajrIfPast(ref, now)), '${fastBar.day}', '${fastBar.total}'),
                    style: WaqtType.sans(14, weight: 500, color: c.onHeroMuted),
                  ),
                  const SizedBox(height: 9),
                  _FastBar(day: fastBar.day, fasts: fastBar.fasts),
                ],
                const SizedBox(height: 14),
                _DayArc(day: now.today, now: now.now),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final p in Prayer.values) ...[
                      if (p != Prayer.fajr) const SizedBox(width: 6),
                      Expanded(
                        child: PrayerChip(
                          prayer: p,
                          time: now.today[p],
                          state: chipState(p, marks[p], now),
                          onTap: () => onChip(p),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Suhoor ends at the *next* Fajr once today's has passed.
  DateTime _tomorrowFajrIfPast(WidgetRef ref, PrayerNow now) {
    if (now.now.isBefore(now.today.fajr)) return now.today.fajr;
    final engine = ref.read(prayerEngineProvider);
    final d = now.today.date;
    return engine.day(DateTime(d.year, d.month, d.day + 1)).fajr;
  }
}

class _Countdown extends ConsumerWidget {
  const _Countdown({required this.target});
  final DateTime target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final now = ref.watch(secondTickProvider).value ?? ref.read(clockProvider)();
    final parts = countdownParts(target.difference(now));
    final big = WaqtType.hero(color: c.onHero);
    final unit = big.copyWith(fontSize: 30, letterSpacing: 0);
    final word = WaqtType.sans(20, weight: 500, color: c.onHeroMuted);
    final spoken = l.inDuration(l.duration(target.difference(now)));
    return Semantics(
      label: spoken,
      liveRegion: false,
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Text.rich(
          TextSpan(children: [
            if (l.homeIn.isNotEmpty) TextSpan(text: '${l.homeIn}  ', style: word),
            if (parts.hours > 0) ...[
              TextSpan(text: '${parts.hours}', style: big),
              TextSpan(text: '${l.unitH}  ', style: unit),
            ],
            TextSpan(text: '${parts.minutes}', style: big),
            TextSpan(text: l.unitM, style: unit),
            if (l.homeInAfter.isNotEmpty) TextSpan(text: '  ${l.homeInAfter}', style: word),
          ]),
          maxLines: 1,
        ),
      ),
    );
  }
}

class _FastBar extends StatelessWidget {
  const _FastBar({required this.day, required this.fasts});
  final int day;
  final List<FastStatus?> fasts;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        for (var i = 0; i < fasts.length; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i == day - 1
                    ? c.onHero
                    : fasts[i] == FastStatus.fasted
                        ? c.brass
                        : Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// One of the five chips under the arc.
class PrayerChip extends StatelessWidget {
  const PrayerChip({
    super.key,
    required this.prayer,
    required this.time,
    required this.state,
    required this.onTap,
  });

  final Prayer prayer;
  final DateTime time;
  final ChipState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final current = state == ChipState.current;
    final mark = switch (state) {
      ChipState.done => DoneMark(key: ValueKey('done-$prayer'), checkColor: c.hero),
      ChipState.current => const CurrentMark(),
      ChipState.upcoming => UpcomingMark(color: c.onHeroMuted),
      ChipState.unmarked => UpcomingMark(color: c.onHero),
      ChipState.missed => MissedMark(background: Colors.transparent, color: c.brass),
      ChipState.excused => ExcusedMark(color: c.onHeroMuted),
    };
    return Semantics(
      button: true,
      label: '${l.prayer(prayer)} ${hhmm(time)}',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: Adaptive.motion(context, 250),
        constraints: const BoxConstraints(minHeight: kMinTouch),
        decoration: BoxDecoration(
          color: current ? c.heroLayerStrong : c.heroLayer,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: current ? c.heroLayerStrong : Colors.transparent),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 10, 2, 9),
              child: Column(
                children: [
                  SizedBox.square(dimension: 26, child: Center(child: mark)),
                  const SizedBox(height: 6),
                  Opacity(
                    opacity: state == ChipState.upcoming ? 0.74 : 1,
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l.prayer(prayer),
                            maxLines: 1,
                            style: WaqtType.sans(13, weight: 600, color: c.onHero),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(hhmm(time), style: WaqtType.sans(12, color: c.onHeroMuted)),
                      ],
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

/// The sun arc from Fajr (left) to Isha (right): dashed rest, solid past,
/// prayer dots and the brass sun with a slow glow.
class _DayArc extends StatefulWidget {
  const _DayArc({required this.day, required this.now});
  final PrayerDay day;
  final DateTime now;

  @override
  State<_DayArc> createState() => _DayArcState();
}

class _DayArcState extends State<_DayArc> with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Adaptive.reduceMotion(context)) {
      _glow.stop();
      _glow.value = 0.5;
    } else if (!_glow.isAnimating) {
      _glow.repeat();
    }
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = PrayerEngine.arcProgress(widget.day, widget.now);
    final points = PrayerEngine.arcPoints(widget.day);
    return ExcludeSemantics(
      child: SizedBox(
        height: 92,
        width: double.infinity,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _ArcPainter(
              progress: t,
              points: points.values.toList(),
              glow: _glow,
              ink: c.onHero,
              hero: c.hero,
              brass: c.brass,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.progress,
    required this.points,
    required this.glow,
    required this.ink,
    required this.hero,
    required this.brass,
  }) : super(repaint: glow);

  final double progress;
  final List<double> points;
  final Animation<double> glow;
  final Color ink;
  final Color hero;
  final Color brass;

  Offset _pt(double t, Size s) {
    final p = PrayerEngine.arcPoint(t, s.width, s.height);
    return Offset(p.x, p.y);
  }

  Path _path(double a, double b, Size s) {
    final path = Path();
    const steps = 48;
    for (var i = 0; i <= steps; i++) {
      final p = _pt(a + (b - a) * i / steps, s);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final base = size.height - 10;
    canvas.drawLine(
      Offset(0, base),
      Offset(size.width, base),
      Paint()
        ..color = ink.withValues(alpha: 0.14)
        ..strokeWidth = 1,
    );

    // Dashed remainder (2 on, 5 off).
    final rest = _path(progress, 1, size);
    final dash = Paint()
      ..color = ink.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (final m in rest.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 2, m.length)), dash);
        d += 7;
      }
    }

    if (progress > 0) {
      canvas.drawPath(
        _path(0, progress, size),
        Paint()
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final t in points) {
      final p = _pt(t, size);
      if (t <= progress) {
        canvas.drawCircle(p, 3.5, Paint()..color = ink);
      } else {
        canvas.drawCircle(p, 3.5, Paint()..color = hero);
        canvas.drawCircle(
          p,
          3.5,
          Paint()
            ..color = ink.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
      }
    }

    // Sun: glow pulses opacity .16→.38 and radius 12→16 over 3.4 s.
    final sun = _pt(progress, size);
    final phase = (1 - math.cos(glow.value * 2 * math.pi)) / 2;
    canvas.drawCircle(
      sun,
      12 + 4 * phase,
      Paint()..color = brass.withValues(alpha: 0.16 + 0.22 * phase),
    );
    canvas.drawCircle(sun, 6, Paint()..color = brass);
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.ink != ink || old.brass != brass || old.hero != hero;
}

/// Faint eight-point star lattice in the hero's top-right corner.
class _StarPattern extends StatelessWidget {
  const _StarPattern();

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
            opacity: 0.09,
            child: CustomPaint(size: const Size.square(260), painter: _StarPainter()),
          ),
        ),
      );
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
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
  bool shouldRepaint(_StarPainter old) => false;
}
