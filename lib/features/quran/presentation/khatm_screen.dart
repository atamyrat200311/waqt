import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/rows.dart';
import '../../../shared/widgets/share_card.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../application/quran_providers.dart';
import '../domain/quran.dart';
import 'ayah_actions.dart';
import 'quran_reader.dart';

const _durations = [7, 10, 15, 20, 30, 60, 90, 180, 365];

class KhatmScreen extends ConsumerStatefulWidget {
  const KhatmScreen({super.key});

  @override
  ConsumerState<KhatmScreen> createState() => _KhatmScreenState();
}

class _KhatmScreenState extends ConsumerState<KhatmScreen> {
  int _days = 30;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final k = ref.watch(khatmProgressProvider);
    return SubScreen(
      title: l.khatmTitle,
      backLabel: l.quranTitle,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
          sliver: SliverList.list(children: k == null ? _setup(context) : _active(context, k)),
        ),
      ],
    );
  }

  List<Widget> _setup(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final goal = ref.watch(settingsProvider.select((s) => s.reader.dailyGoal));
    return [
      WaqtCard(
        color: c.mint,
        border: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WaqtIcon(WaqtIcons.target, color: c.onMint),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l.khatmIntro, style: WaqtType.sans(15, color: c.onMint, height: 1.45)),
            ),
          ],
        ),
      ),
      SectionTitle(l.khatmChoose, padding: const EdgeInsets.fromLTRB(6, 22, 6, 10)),
      WaqtGroup(
        children: [
          for (final d in _durations)
            Semantics(
              selected: d == _days,
              child: WaqtRow(
                title: d == 30 ? '${l.khatmDays(d)} · ${l.khatmRamadan}' : l.khatmDays(d),
                subtitle: l.khatmPerDay('${(totalPages / d).ceil()}'),
                onTap: () {
                  Haptics.tap();
                  setState(() => _days = d);
                },
                trailing: d == _days ? WaqtIcon(WaqtIcons.check, color: c.accent, size: 20) : const SizedBox(width: 20),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      BigButton(
        label: l.khatmStart,
        onPressed: () {
          Haptics.success();
          final today = ref.read(todayKeyProvider);
          ref.read(settingsProvider.notifier).setKhatmPlan(KhatmPlan(start: today.value, days: _days));
        },
      ),
      SectionTitle(l.quranDailyGoal, padding: const EdgeInsets.fromLTRB(6, 28, 6, 10)),
      WaqtCard(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(l.quranDailyGoalValue(goal), style: WaqtType.sans(16, weight: 600, color: c.ink)),
            ),
            CircleIconButton(
              icon: WaqtIcons.minus,
              semanticLabel: '−',
              background: c.fill,
              onPressed: goal <= 1
                  ? null
                  : () => ref
                        .read(settingsProvider.notifier)
                        .setReader((r) => r.copyWith(dailyGoal: goal <= 10 ? goal - 1 : goal - 5)),
            ),
            CircleIconButton(
              icon: WaqtIcons.plus,
              semanticLabel: '+',
              background: c.fill,
              onPressed: () => ref
                  .read(settingsProvider.notifier)
                  .setReader((r) => r.copyWith(dailyGoal: goal < 10 ? goal + 1 : goal + 5)),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
        child: Text(l.quranReadTracking, style: WaqtType.sans(13, color: c.muted, height: 1.4)),
      ),
    ];
  }

  List<Widget> _active(BuildContext context, KhatmProgress k) {
    final c = context.colors;
    final l = context.l10n;
    final recent = ref.watch(quranRecentDailyProvider).value ?? const {};
    final today = ref.watch(todayKeyProvider);
    final reminder = ref.watch(settingsProvider.select((s) => s.quranReminder));
    final next = ref.watch(khatmNextAyahProvider);

    final status = k.complete
        ? l.khatmComplete
        : k.todayDone
        ? l.khatmTodayDone
        : k.behind
        ? l.khatmBehind
        : l.khatmOnTrack;

    final bars = [for (var i = 13; i >= 0; i--) recent[today.addDays(-i)] ?? 0];
    final maxBar = bars.fold<int>(1, (m, v) => v > m ? v : m);

    return [
      WaqtCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ProgressRing(
              value: k.fraction,
              color: c.brass,
              track: c.fill,
              strokeWidth: 10,
              size: 170,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${(k.fraction * 100).floor()}%', style: WaqtType.serif(44, weight: 400, color: c.ink)),
                    Text(
                      l.khatmProgress('${k.readPagesRounded}', '$totalPages'),
                      style: WaqtType.sans(12.5, color: c.muted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              k.complete ? l.khatmComplete : l.khatmDayOf('${k.dayNumber}', '${k.plan.days}'),
              textAlign: TextAlign.center,
              style: WaqtType.serif(22, weight: 500, color: c.ink),
            ),
            const SizedBox(height: 6),
            if (!k.complete)
              Text(
                status,
                textAlign: TextAlign.center,
                style: WaqtType.sans(14.5, color: k.behind ? c.brassText : c.accent, weight: 600),
              ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      if (!k.complete) ...[
        WaqtCard(
          child: Row(
            children: [
              ProgressRing(
                value: k.todayTargetPages <= 0 ? 1 : (k.readTodayPages / k.todayTargetPages).clamp(0, 1).toDouble(),
                color: c.primary,
                track: c.fill,
                strokeWidth: 5,
                size: 48,
                child: Center(child: WaqtIcon(WaqtIcons.quran, size: 20, color: c.accent)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.khatmTodayTarget('${k.targetPagesRounded}', ayahReference(next)),
                      style: WaqtType.sans(15, weight: 600, color: c.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l.quranGoalPages('${k.readTodayRounded}', '${k.targetPagesRounded}')} · ${l.khatmDaysLeft(k.daysLeft)}',
                      style: WaqtType.sans(13, color: c.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        BigButton(label: l.quranContinue, onPressed: () => openReader(context, next)),
      ] else ...[
        BigButton(
          label: l.share,
          style: PillStyle.brass,
          onPressed: () => showShareCardSheet(
            context,
            ShareCardData(kicker: l.khatmShort, big: '۞', text: l.khatmShareText, reference: l.khatmComplete),
          ),
        ),
        const SizedBox(height: 8),
        PillButton(
          label: l.khatmNewPlan,
          style: PillStyle.fill,
          expand: true,
          onPressed: () => ref.read(settingsProvider.notifier).setKhatmPlan(null),
        ),
      ],
      const SizedBox(height: 10),
      if (bars.any((b) => b > 0))
        WaqtCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Kicker(l.khatmLast14),
              const SizedBox(height: 10),
              SizedBox(
                height: 72,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < bars.length; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Semantics(
                            label: '${bars[i]}',
                            child: Container(
                              height: 6 + 60 * bars[i] / maxBar,
                              decoration: BoxDecoration(
                                color: i == bars.length - 1
                                    ? c.brass
                                    : (bars[i] > 0 ? c.primary.withValues(alpha: 0.75) : c.fill),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 10),
      WaqtGroup(
        children: [
          ToggleRow(
            title: l.khatmReminder,
            value: reminder,
            onChanged: (v) => ref.read(settingsProvider.notifier).setQuranReminder(v),
          ),
          if (!k.complete)
            WaqtRow(
              title: l.khatmEnd,
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog.adaptive(
                    content: Text(l.khatmEndConfirm),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.khatmEnd)),
                    ],
                  ),
                );
                if (ok ?? false) await ref.read(settingsProvider.notifier).setKhatmPlan(null);
              },
            ),
        ],
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(l.quranReadTracking, style: WaqtType.sans(13, color: c.muted, height: 1.4)),
      ),
    ];
  }
}
