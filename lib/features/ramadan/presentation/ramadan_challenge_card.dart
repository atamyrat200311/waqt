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
import '../../../data/repositories/fast_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/ornaments.dart';
import '../../../shared/widgets/share_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../expenses/presentation/expense_sheet.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../quran/presentation/quran_reader.dart';
import '../../today/application/today_providers.dart';
import '../../today/presentation/mark_sheet.dart';
import '../application/ramadan_challenge.dart';

/// Ramadan challenge: five daily goals with one-tap actions and a share card.
class RamadanChallengeCard extends ConsumerWidget {
  const RamadanChallengeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ch = ref.watch(ramadanChallengeProvider);
    if (ch == null) return const SizedBox.shrink();
    final c = context.colors;
    final l = context.l10n;
    final t = ch.today;
    final now = ref.watch(prayerNowProvider);

    final items = <(WaqtIconData, String, bool, VoidCallback)>[
      (WaqtIcons.moon, l.ramadanItemFast, t.fasted, () {
        Haptics.success();
        ref.read(fastRepositoryProvider).set(now.dayKey, FastType.ramadan, t.fasted ? null : FastStatus.fasted);
      }),
      (WaqtIcons.mosque, l.ramadanItemPrayers, t.prayers, () {
        // Open the first prayer whose time has come and isn't marked yet.
        final marks = ref.read(todayMarksProvider).value ?? const <Prayer, PrayerStatus>{};
        final open = Prayer.values.where((p) => now.hasStarted(p) && !marks.containsKey(p));
        if (open.isNotEmpty) {
          showMarkSheet(context, open.first, now.dayKey);
        } else {
          context.go(Routes.today);
        }
      }),
      (WaqtIcons.quran, l.ramadanItemQuran, t.quran, () {
        openReader(context, ref.read(settingsProvider).quranLastRead ?? 0);
      }),
      (WaqtIcons.beads, l.ramadanItemDhikr, t.dhikr, () {
        final evening = !now.now.isBefore(now.today[Prayer.asr]);
        context.push(Routes.adhkar(evening ? 'evening' : 'morning'));
      }),
      (WaqtIcons.heart, l.ramadanItemSadaqa, t.sadaqa, () => showExpenseSheet(context, category: ExpenseCategory.sadaqa)),
    ];

    final share = ShareCardData(
      kicker: '${l.ramadanChallenge} · ${l.ramadanDayOf('${ch.day}', '${ch.total}')}',
      big: '${t.score}/5',
      text: [for (final (_, label, done, _) in items) '${done ? '✓' : '○'}  $label'].join('\n'),
      reference: l.ramadanCoreDays(ch.coreDays),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(Radii.heroCard(context))),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned(right: -80, top: -100, child: StarPattern()),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 8, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Kicker(
                          '${l.ramadanChallenge} · ${l.ramadanDayOf('${ch.day}', '${ch.total}')}',
                          color: c.onHeroMuted,
                          size: 12,
                          tracking: 0.08,
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: l.share,
                        excludeSemantics: true,
                        child: InkResponse(
                          radius: 22,
                          onTap: () => showShareCardSheet(context, share),
                          child: SizedBox.square(
                            dimension: 44,
                            child: Center(child: WaqtIcon(WaqtIcons.share, size: 19, color: c.onHero)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(l.ramadanChallengeScore('${t.score}'), style: WaqtType.serif(26, weight: 500, color: c.onHero)),
                  const SizedBox(height: 2),
                  Text(l.ramadanCoreDays(ch.coreDays), style: WaqtType.sans(13.5, color: c.onHeroAccent, weight: 600)),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        for (final (icon, label, done, onTap) in items)
                          Expanded(
                            child: Semantics(
                              button: true,
                              checked: done,
                              label: label,
                              excludeSemantics: true,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: onTap,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Column(
                                    children: [
                                      AnimatedContainer(
                                        duration: Adaptive.motion(context, 220),
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: done ? c.brass : c.heroLayerStrong,
                                        ),
                                        child: Center(
                                          child: WaqtIcon(
                                            done ? WaqtIcons.check : icon,
                                            size: 20,
                                            strokeWidth: done ? 2.6 : 2,
                                            color: done ? c.hero : c.onHero,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(label, style: WaqtType.sans(11.5, weight: 600, color: c.onHeroMuted)),
                                      ),
                                    ],
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
          ],
        ),
      ),
    );
  }
}

/// Before Ramadan: what the challenge is.
class RamadanChallengeTeaser extends StatelessWidget {
  const RamadanChallengeTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: c.mint, borderRadius: BorderRadius.circular(Radii.card(context))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: WaqtIcons.moon, background: c.card, color: c.onMint),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.ramadanChallenge, style: WaqtType.item(color: c.ink)),
                const SizedBox(height: 4),
                Text(l.ramadanChallengeIntro, style: WaqtType.sans(14, color: c.onMint, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
