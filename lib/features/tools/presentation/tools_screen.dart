import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../data/db/enums.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../adhkar/application/adhkar_providers.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../ramadan/domain/ramadan.dart';
import '../../today/application/today_providers.dart';
import '../application/tools_providers.dart';
import '../domain/qibla.dart';
import '../domain/tasbih.dart';
import 'qibla_compass.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(Gap.title, top + (Adaptive.isCupertino(context) ? 48 : 24), Gap.title, 16),
              child: Semantics(header: true, child: Text(l.toolsTitle, style: WaqtType.title(color: c.ink))),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Gap.screen),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                QiblaCard(),
                SizedBox(height: 12),
                TasbihCard(),
                SizedBox(height: 12),
                _ToolTiles(),
                SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// "QIBLA 234°" with a live compass.
class QiblaCard extends ConsumerWidget {
  const QiblaCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final q = ref.watch(qiblaProvider);
    final compass = ref.watch(compassProvider).value;
    final heading = compass?.heading;
    final deg = q.bearing.round();
    final facing = heading != null && isFacingQibla(q.bearing, heading);
    final hint = compass == null
        ? l.qiblaTurn
        : !compass.hasSensor
            ? l.qiblaNoSensor('$deg')
            : compass.needsCalibration
                ? l.qiblaCalibrate
                : facing
                    ? l.qiblaFacing
                    : l.qiblaTurn;

    return WaqtCard(
      radius: Radii.heroCard(context),
      padding: const EdgeInsets.all(20),
      onTap: () => context.push(Routes.qiblaFull),
      semanticLabel: '${l.qibla}: ${l.qiblaFromNorth('$deg')}. $hint',
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Kicker(l.qibla, color: c.accent, size: 13, tracking: 0.06),
                const SizedBox(height: 8),
                Text('$deg°', style: WaqtType.serif(48, tracking: -0.03, height: 1, color: c.ink)),
                const SizedBox(height: 8),
                Text(hint, style: WaqtType.sans(14, color: facing ? c.accent : c.muted, height: 1.4, weight: facing ? 600 : 400)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          QiblaCompass(bearing: q.bearing, heading: heading),
        ],
      ),
    );
  }
}

/// Emerald tasbih counter (33 · 33 · 34 by default).
class TasbihCard extends ConsumerWidget {
  const TasbihCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final s = ref.watch(tasbihProvider);
    final ctl = ref.read(tasbihProvider.notifier);
    final phase = s.current;

    void tap() {
      switch (ctl.tap()) {
        case TasbihTap.counted || TasbihTap.restarted:
          Haptics.tap();
        case TasbihTap.phaseDone:
          Haptics.success();
        case TasbihTap.complete:
          Haptics.goal();
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(Radii.heroCard(context))),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: '${l.tasbih}: ${s.isComplete ? l.tasbihComplete('${s.goal}') : phase.transliteration}',
                  excludeSemantics: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => showTasbihSettings(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Kicker(l.tasbih, color: c.onHeroMuted, size: 13, tracking: 0.06),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                s.isComplete ? l.tasbihComplete('${s.goal}') : phase.transliteration,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: WaqtType.sans(16, weight: 600, color: c.onHero),
                              ),
                            ),
                            const SizedBox(width: 4),
                            WaqtIcon(WaqtIcons.chevronDown, size: 14, color: c.onHeroMuted),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.white.withValues(alpha: 0.1),
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Haptics.light();
                    ctl.reset();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: SizedBox(
                      height: 36,
                      child: Row(
                        children: [
                          WaqtIcon(WaqtIcons.qada, size: 14, color: c.onHero),
                          const SizedBox(width: 6),
                          Text(l.reset, style: WaqtType.sans(13, weight: 600, color: c.onHero)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 18, 0, 6),
            child: Semantics(
              button: true,
              label: '${l.tasbihTapA11y}. ${s.count} / ${phase.target}',
              excludeSemantics: true,
              child: GestureDetector(
                onTap: tap,
                child: SizedBox.square(
                  dimension: 176,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(decoration: BoxDecoration(color: c.heroLayer, shape: BoxShape.circle)),
                      ProgressRing(
                        value: s.progress,
                        color: c.brass,
                        track: Colors.white.withValues(alpha: 0.1),
                        size: 176,
                      ),
                      TapRipple(trigger: s.total, color: c.brass, inset: 4),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (phase.arabic.isNotEmpty)
                            Text(
                              phase.arabic,
                              textDirection: TextDirection.rtl,
                              style: WaqtType.arabic(20, height: 1.2, color: c.onHeroMuted),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            s.isComplete ? '${s.goal}' : '${s.count}',
                            style: WaqtType.serif(58, tracking: -0.03, height: 1, color: c.onHero),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.isComplete ? l.tasbihTapAgain : l.tasbihOf('${phase.target}'),
                            style: WaqtType.sans(13, color: c.onHeroMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (s.phases.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < s.phases.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    AnimatedContainer(
                      duration: Adaptive.motion(context, 300),
                      width: i == s.phase && !s.isComplete ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: i < s.phase || s.isComplete
                            ? c.brass
                            : i == s.phase
                                ? c.onHero
                                : Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> showTasbihSettings(BuildContext context) =>
    Adaptive.showSheet<void>(context, builder: (_) => const _TasbihSettings());

class _TasbihSettings extends ConsumerStatefulWidget {
  const _TasbihSettings();

  @override
  ConsumerState<_TasbihSettings> createState() => _TasbihSettingsState();
}

class _TasbihSettingsState extends ConsumerState<_TasbihSettings> {
  final _phrase = TextEditingController();
  final _goal = TextEditingController(text: '100');

  @override
  void dispose() {
    _phrase.dispose();
    _goal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final ctl = ref.read(tasbihProvider.notifier);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.tasbih, style: WaqtType.serif(28, color: c.ink)),
          const SizedBox(height: 16),
          BigButton(
            label: l.tasbihPreset,
            style: PillStyle.mint,
            onPressed: () {
              ctl.usePreset();
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 22),
          Text(l.tasbihCustom, style: WaqtType.sans(16, weight: 600, color: c.ink)),
          const SizedBox(height: 8),
          TextField(
            controller: _phrase,
            maxLength: 60,
            decoration: InputDecoration(labelText: l.tasbihPhrase, counterText: ''),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _goal,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l.tasbihGoal),
          ),
          const SizedBox(height: 16),
          BigButton(
            label: l.save,
            onPressed: () {
              ctl.useCustom(_phrase.text, int.tryParse(_goal.text) ?? 100);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _ToolTiles extends ConsumerWidget {
  const _ToolTiles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final now = ref.watch(prayerNowProvider);
    final morning = ref.watch(adhkarTodayProvider(AdhkarSet.morning));
    final evening = ref.watch(adhkarTodayProvider(AdhkarSet.evening));
    final afterAsr = !now.now.isBefore(now.today[Prayer.asr]);
    final (adhkarSet, adhkarSub) = afterAsr
        ? (AdhkarSet.evening, evening.isComplete ? l.toolsAdhkarDone : l.toolsEveningDue)
        : (AdhkarSet.morning, morning.isComplete ? l.toolsAdhkarDone : l.toolsMorningDue);

    final hijri = ref.watch(hijriServiceProvider);
    final day = ref.watch(todayKeyProvider).date;
    final h = hijri.fromGregorian(day);
    final rDay = ramadanDay(hijri, day);
    final ramadanSub = rDay != null ? l.toolsRamadanNow('${rDay.day}') : l.ramadanInDays('${daysUntilRamadan(hijri, day)}');

    Widget tile(WaqtIconData icon, String title, String sub, VoidCallback onTap, {bool brass = false}) => Expanded(
          child: WaqtCard(
            onTap: onTap,
            radius: Adaptive.isCupertino(context) ? 22 : 28,
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              height: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconTile(
                    icon: icon,
                    small: true,
                    background: brass ? c.brassSoft : c.mint,
                    color: brass ? c.brassText : c.onMint,
                  ),
                  const Spacer(),
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: WaqtType.sans(14, weight: 600, color: c.ink)),
                  const SizedBox(height: 2),
                  Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: WaqtType.sans(12, color: c.muted)),
                ],
              ),
            ),
          ),
        );

    return Row(
      children: [
        tile(WaqtIcons.book, l.toolsAdhkar, adhkarSub, () => context.push(Routes.adhkar(adhkarSet.name))),
        const SizedBox(width: 10),
        tile(WaqtIcons.calendar, l.toolsCalendar, l.dayMonthHijri(h.day, h.month), () => context.push(Routes.calendar)),
        const SizedBox(width: 10),
        tile(WaqtIcons.moon, l.toolsRamadan, ramadanSub, () => context.push(Routes.ramadan), brass: true),
      ],
    );
  }
}
