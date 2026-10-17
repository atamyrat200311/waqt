import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/share_card.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../habits/application/habit_providers.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../quran/application/quran_providers.dart';
import '../../quran/domain/quran.dart';
import '../../quran/presentation/ayah_actions.dart';
import '../../quran/presentation/quran_reader.dart';

/// "Continue Al-Baqarah · today 6 of 10 ayahs" with the reading ring.
class TodayQuranRow extends ConsumerWidget {
  const TodayQuranRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final last = ref.watch(settingsProvider.select((s) => s.quranLastRead));
    final g = ref.watch(readingGoalProvider);
    final r = AyahRef.fromIndex(last ?? 0);
    final surah = SurahInfo(r.surah);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: WaqtCard(
        onTap: () => openReader(context, last ?? 0),
        semanticLabel: '${l.quranContinue}: ${surah.translit} ${r.surah}:${r.ayah}',
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
        child: Row(
          children: [
            ProgressRing(
              value: g.fraction,
              color: c.brass,
              track: c.track,
              strokeWidth: 4.5,
              size: 46,
              child: Center(
                child: g.done
                    ? WaqtIcon(WaqtIcons.check, size: 19, color: c.brass, strokeWidth: 2.6)
                    : WaqtIcon(WaqtIcons.quran, size: 19, color: c.accent),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    last == null ? l.quranStart : '${surah.translit} · ${r.surah}:${r.ayah}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WaqtType.item(color: c.ink),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          g.done
                              ? l.quranGoalDone
                              : (g.pages
                                    ? l.quranGoalPages('${g.read}', '${g.target}')
                                    : l.quranGoal('${g.read}', '${g.target}')),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WaqtType.sans(13, color: c.muted),
                        ),
                      ),
                      if (g.streak > 0) ...[
                        const SizedBox(width: 8),
                        WaqtIcon(WaqtIcons.flame, size: 13, color: c.brass),
                        const SizedBox(width: 2),
                        Text('${g.streak}', style: WaqtType.sans(13, weight: 700, color: c.brassText)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              surah.arabic,
              textDirection: TextDirection.rtl,
              style: WaqtType.arabic(20, height: 1.3, color: c.accent),
            ),
          ],
        ),
      ),
    );
  }
}

/// Habits as tappable round toggles (hidden until the first habit exists).
class TodayHabitsRow extends ConsumerWidget {
  const TodayHabitsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final views = ref.watch(habitViewsProvider);
    final c = context.colors;
    final l = context.l10n;
    if (views.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: WaqtCard(
          onTap: () => context.push(Routes.habits),
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
          child: Row(
            children: [
              IconTile(icon: WaqtIcons.sparkles, small: true, background: c.mint, color: c.onMint),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.habitsTitle, style: WaqtType.item(color: c.ink)),
                    Text(l.habitsEmptyShort, style: WaqtType.sans(13, color: c.muted)),
                  ],
                ),
              ),
              WaqtIcon(WaqtIcons.plus, size: 20, color: c.accent),
            ],
          ),
        ),
      );
    }
    final today = ref.watch(todayKeyProvider);
    final (done, total) = ref.watch(habitsTodayProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: WaqtCard(
        padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => context.push(Routes.habits),
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l.habitsTitle, style: WaqtType.sans(13, weight: 500, color: c.muted)),
                  ),
                  Text(
                    l.habitsDoneToday('$done', '$total'),
                    style: WaqtType.sans(13, weight: 600, color: done == total ? c.brassText : c.muted),
                  ),
                  const SizedBox(width: 2),
                  WaqtIcon(WaqtIcons.chevronRight, size: 16, color: c.muted),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final v in views)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Semantics(
                        button: true,
                        checked: v.doneToday,
                        label: v.habit.title,
                        excludeSemantics: true,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            v.doneToday ? Haptics.light() : Haptics.success();
                            ref.read(habitRepositoryProvider).setDone(v.habit.id, today, !v.doneToday);
                          },
                          child: SizedBox(
                            width: 70,
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: Adaptive.motion(context, 200),
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: v.doneToday ? c.brass : c.fill,
                                  ),
                                  child: Center(
                                    child: WaqtIcon(
                                      v.doneToday ? WaqtIcons.check : WaqtIcons.byKey(v.habit.icon),
                                      size: 20,
                                      strokeWidth: v.doneToday ? 2.6 : 2,
                                      color: v.doneToday ? c.onBrassText : c.muted,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  v.habit.title,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: WaqtType.sans(11.5, color: c.ink, height: 1.2),
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
    );
  }
}

/// A short ayah to reflect on, rotating daily.
class AyahOfDayCard extends ConsumerWidget {
  const AyahOfDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final texts = ref.watch(quranTextsProvider).value;
    if (texts == null) return const SizedBox.shrink();
    final ref0 = dailyAyah(ref.watch(todayKeyProvider).date);
    final translation = ref.watch(activeTranslationProvider);
    final i = ref0.index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: WaqtCard(
        onTap: () => openReader(context, i),
        padding: const EdgeInsets.fromLTRB(18, 14, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                WaqtIcon(WaqtIcons.sparkles, size: 15, color: c.accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l.quranOfDay.toUpperCase(),
                    style: WaqtType.kicker(color: c.accent, size: 11.5, tracking: 0.08),
                  ),
                ),
                Semantics(
                  button: true,
                  label: l.share,
                  excludeSemantics: true,
                  child: InkResponse(
                    radius: 22,
                    onTap: () => showShareCardSheet(context, ayahShareData(context, i, texts, kicker: l.quranOfDay)),
                    child: SizedBox.square(
                      dimension: 44,
                      child: Center(child: WaqtIcon(WaqtIcons.share, size: 18, color: c.muted)),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                texts.arabic[i],
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: WaqtType.quran(texts.arabic[i].length > 120 ? 21 : 25, height: 1.9, color: c.ink),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                texts.translation[i],
                textAlign: TextAlign.center,
                style: WaqtType.serif(15.5, height: 1.55, color: c.ink),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ayahReference(i),
              textAlign: TextAlign.center,
              style: WaqtType.sans(12.5, weight: 600, color: c.accent),
            ),
            if (translation.language != l.localeName)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  l.translationLabel('${translation.label} · ${translation.author}'),
                  textAlign: TextAlign.center,
                  style: WaqtType.sans(11.5, color: c.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
