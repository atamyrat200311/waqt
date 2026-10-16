import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/ornaments.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/segmented.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../application/quran_providers.dart';
import '../domain/quran.dart';
import 'quran_reader.dart';

/// Quran tab: continue card, today's reading, khatm & memorize, surah/juz index.
class QuranHomeScreen extends ConsumerStatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  ConsumerState<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends ConsumerState<QuranHomeScreen> {
  bool _juz = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final lang = l.localeName;
    final read = ref.watch(khatmReadAyahsProvider).value ?? const <int>{};

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TabHeader(
              title: l.quranTitle,
              actions: [
                CircleIconButton(
                  icon: WaqtIcons.search,
                  semanticLabel: l.quranSearch,
                  background: c.card,
                  border: true,
                  onPressed: () => context.push(Routes.quranSearch),
                ),
                CircleIconButton(
                  icon: WaqtIcons.bookmark,
                  semanticLabel: l.quranBookmarks,
                  background: c.card,
                  border: true,
                  onPressed: () => context.push(Routes.quranBookmarks),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
            sliver: SliverList.list(
              children: [
                const ContinueReadingCard(),
                const SizedBox(height: 10),
                const ReadingGoalCard(),
                const SizedBox(height: 10),
                const _QuickTiles(),
                const SizedBox(height: 22),
                Segmented<bool>(
                  value: _juz,
                  options: [(false, l.quranSurahs), (true, l.quranJuzTab)],
                  onChanged: (v) => setState(() => _juz = v),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
            sliver: DecoratedSliver(
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(Radii.card(context)),
                border: Border.all(color: c.hairline),
              ),
              sliver: _juz
                  ? SliverList.separated(
                      itemCount: 30,
                      separatorBuilder: (_, _) => Divider(height: 1, color: c.hairline, indent: 64),
                      itemBuilder: (context, i) => _JuzRow(juz: i + 1),
                    )
                  : SliverList.separated(
                      itemCount: totalSurahs,
                      separatorBuilder: (_, _) => Divider(height: 1, color: c.hairline, indent: 64),
                      itemBuilder: (context, i) {
                        final s = SurahInfo.all[i];
                        var done = read.isNotEmpty;
                        if (done) {
                          for (var a = s.startIndex; a <= s.endIndex; a++) {
                            if (!read.contains(a)) {
                              done = false;
                              break;
                            }
                          }
                        }
                        return SurahRow(
                          surah: s,
                          language: lang,
                          done: done,
                          onTap: () => openReader(context, s.startIndex),
                        );
                      },
                    ),
            ),
          ),
          const SliverToBoxAdapter(child: BottomSpace()),
        ],
      ),
    );
  }
}

/// One surah in the index.
class SurahRow extends StatelessWidget {
  const SurahRow({
    super.key,
    required this.surah,
    required this.language,
    required this.onTap,
    this.done = false,
    this.trailing,
  });

  final SurahInfo surah;
  final String language;
  final VoidCallback onTap;
  final bool done;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
        child: Row(
          children: [
            StarBadge(
              label: '${surah.number}',
              color: done ? c.brass : c.hairline,
              fill: done ? c.brassSoft : null,
              textColor: done ? c.brassText : c.ink,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.translit, style: WaqtType.sans(16, weight: 600, color: c.ink)),
                  const SizedBox(height: 2),
                  Text(
                    '${surah.meaning(language)} · ${l.quranAyahCount(surah.ayahCount)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WaqtType.sans(13, color: c.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                Text(
                  surah.arabic,
                  textDirection: TextDirection.rtl,
                  style: WaqtType.arabic(21, height: 1.3, color: c.accent),
                ),
          ],
        ),
      ),
    );
  }
}

class _JuzRow extends ConsumerWidget {
  const _JuzRow({required this.juz});
  final int juz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final (start, _) = juzRange(juz);
    final r = AyahRef.fromIndex(start);
    final arabic = ref.watch(quranArabicProvider).value;
    final words = arabic?[start].split(' ').take(3).join(' ');
    return InkWell(
      onTap: () => openReader(context, start),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
        child: Row(
          children: [
            StarBadge(label: '$juz', color: c.hairline, textColor: c.ink, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.quranJuzN('$juz'), style: WaqtType.sans(16, weight: 600, color: c.ink)),
                  const SizedBox(height: 2),
                  Text(
                    '${SurahInfo(r.surah).translit} ${r.surah}:${r.ayah} · ${l.quranPageN('${pageOfIndex(start)}')}',
                    style: WaqtType.sans(13, color: c.muted),
                  ),
                ],
              ),
            ),
            if (words != null)
              Flexible(
                child: Text(
                  words,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: WaqtType.quran(18, height: 1.6, color: c.muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Emerald hero: where you stopped, one tap to continue.
class ContinueReadingCard extends ConsumerWidget {
  const ContinueReadingCard({super.key, this.compact = false});

  /// Smaller variant for Home.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final last = ref.watch(settingsProvider.select((s) => s.quranLastRead));
    final index = last ?? 0;
    final r = AyahRef.fromIndex(index);
    final surah = SurahInfo(r.surah);
    final page = pageOfIndex(index);

    return Semantics(
      button: true,
      label: '${last == null ? l.quranStart : l.quranContinue}: ${surah.translit}, ${l.quranAyahN('${r.ayah}')}',
      excludeSemantics: true,
      child: Material(
        color: c.hero,
        borderRadius: BorderRadius.circular(Radii.heroCard(context)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openReader(context, index),
          child: Stack(
            children: [
              const Positioned(right: -70, top: -90, child: StarPattern()),
              Padding(
                padding: EdgeInsets.all(compact ? 18 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Kicker(
                                last == null ? l.quranStart : l.quranContinue,
                                color: c.onHeroMuted,
                                size: 12,
                                tracking: 0.09,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                surah.translit,
                                style: WaqtType.serif(compact ? 24 : 28, weight: 500, color: c.onHero),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                last == null
                                    ? l.quranStartHint
                                    : '${l.quranAyahN('${r.ayah}')} · ${l.quranPageN('$page')} · ${l.quranJuzN('${juzOfIndex(index)}')}',
                                style: WaqtType.sans(14, color: c.onHeroMuted, height: 1.35),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          surah.arabic,
                          textDirection: TextDirection.rtl,
                          style: WaqtType.arabic(compact ? 28 : 34, height: 1.2, color: c.onHero),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 14 : 18),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: last == null ? 0 : page / totalPages,
                              minHeight: 5,
                              backgroundColor: c.heroLayerStrong,
                              valueColor: AlwaysStoppedAnimation(c.brass),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(color: c.heroLayerStrong, borderRadius: BorderRadius.circular(99)),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Text(l.quranReadSurah, style: WaqtType.sans(14.5, weight: 600, color: c.onHero)),
                              const SizedBox(width: 6),
                              WaqtIcon(WaqtIcons.arrowRight, size: 16, color: c.onHero),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Today's reading ring + streak (+ khatm day).
class ReadingGoalCard extends ConsumerWidget {
  const ReadingGoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final g = ref.watch(readingGoalProvider);
    final k = g.khatm;
    return WaqtCard(
      onTap: () => context.push(Routes.khatm),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ProgressRing(
            value: g.fraction,
            color: c.brass,
            track: c.fill,
            strokeWidth: 6,
            size: 62,
            child: Center(
              child: g.done
                  ? WaqtIcon(WaqtIcons.check, size: 24, color: c.brass, strokeWidth: 2.6)
                  : Text('${g.read}', style: WaqtType.serif(20, weight: 500, color: c.ink)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Kicker(k != null && !k.complete ? l.khatmDayOf('${k.dayNumber}', '${k.plan.days}') : l.quranToday),
                const SizedBox(height: 4),
                Text(
                  g.done
                      ? l.quranGoalDone
                      : (g.pages
                            ? l.quranGoalPages('${g.read}', '${g.target}')
                            : l.quranGoal('${g.read}', '${g.target}')),
                  style: WaqtType.sans(16, weight: 600, color: c.ink),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    WaqtIcon(WaqtIcons.flame, size: 15, color: g.streak > 0 ? c.brass : c.muted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(l.quranStreak(g.streak), style: WaqtType.sans(13, color: c.muted)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          WaqtIcon(WaqtIcons.chevronRight, size: 18, color: c.muted),
        ],
      ),
    );
  }
}

class _QuickTiles extends ConsumerWidget {
  const _QuickTiles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final k = ref.watch(khatmProgressProvider);
    final due = ref.watch(hifzDueProvider).length;
    return Row(
      children: [
        Expanded(
          child: _Tile(
            icon: WaqtIcons.target,
            title: l.khatmTitle,
            subtitle: k == null ? l.khatmTileIdle : '${(k.fraction * 100).floor()}% · ${l.khatmDaysLeft(k.daysLeft)}',
            onTap: () => context.push(Routes.khatm),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Tile(
            icon: WaqtIcons.repeat,
            title: l.hifzTitle,
            subtitle: due > 0 ? l.hifzDueCount(due) : l.hifzTileIdle,
            highlight: due > 0,
            onTap: () => context.push(Routes.hifz),
            iconColor: due > 0 ? c.brassText : null,
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
    this.iconColor,
  });

  final WaqtIconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return WaqtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: icon, small: true, background: highlight ? c.brassSoft : c.mint, color: iconColor ?? c.onMint),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: WaqtType.sans(15.5, weight: 600, color: c.ink),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: WaqtType.sans(13, color: highlight ? c.brassText : c.muted),
          ),
        ],
      ),
    );
  }
}
