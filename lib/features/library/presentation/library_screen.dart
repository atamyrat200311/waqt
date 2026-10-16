import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../data/db/enums.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/ornaments.dart';
import '../../../shared/widgets/share_card.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../adhkar/application/adhkar_providers.dart';
import '../../hadith/application/hadith_providers.dart';
import '../../hadith/domain/hadith.dart';
import '../../hadith/presentation/hadith_book_screen.dart';
import '../../hadith/presentation/hadith_widgets.dart';

/// Library tab: hadith of the day, hadith collections, duas, Names, guides.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TabHeader(
              title: l.tabLibrary,
              actions: [
                CircleIconButton(
                  icon: WaqtIcons.bookmark,
                  semanticLabel: l.librarySaved,
                  background: c.card,
                  border: true,
                  onPressed: () => context.push(Routes.libraryBookmarks),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
            sliver: SliverList.list(
              children: [
                const HadithOfDayCard(),
                const SizedBox(height: 12),
                _BigTile(
                  icon: WaqtIcons.handHeart,
                  title: l.libraryDuas,
                  subtitle: l.libraryDuasSub,
                  onTap: () => context.push(Routes.duas),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SmallTile(
                        icon: WaqtIcons.star,
                        title: l.libraryNames,
                        subtitle: l.libraryNamesSub,
                        brass: true,
                        onTap: () => context.push(Routes.names),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SmallTile(
                        icon: WaqtIcons.learn,
                        title: l.libraryLearn,
                        subtitle: l.libraryLearnSub,
                        onTap: () => context.push(Routes.learn),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Expanded(child: _AdhkarTile(set: AdhkarSet.morning)),
                    SizedBox(width: 10),
                    Expanded(child: _AdhkarTile(set: AdhkarSet.evening)),
                  ],
                ),
                SectionTitle(l.libraryHadith, padding: const EdgeInsets.fromLTRB(6, 26, 6, 12)),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.08,
                  padding: EdgeInsets.zero,
                  children: [for (final b in HadithBooks.all) HadithBookTile(book: b)],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                  child: Text(l.libraryContentReview, style: WaqtType.sans(12.5, color: c.muted, height: 1.4)),
                ),
                const BottomSpace(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Emerald card with today's hadith from the 40-hadith collections.
class HadithOfDayCard extends ConsumerWidget {
  const HadithOfDayCard({super.key, this.maxLines = 7});
  final int maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final d = ref.watch(hadithOfDayProvider).value;
    return Material(
      color: c.hero,
      borderRadius: BorderRadius.circular(Radii.heroCard(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: d == null ? null : () => context.push(Routes.hadithBook(d.book.id)),
        child: Stack(
          children: [
            const Positioned(right: -80, top: -90, child: StarPattern()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: d == null
                  ? const SizedBox(height: 120)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Kicker(l.hadithOfDay, color: c.onHeroMuted, size: 12, tracking: 0.09)),
                            Semantics(
                              button: true,
                              label: l.share,
                              excludeSemantics: true,
                              child: InkResponse(
                                radius: 22,
                                onTap: () => showShareCardSheet(
                                  context,
                                  hadithShareData(l, d.book.id, d.hadith, arabic: d.arabic, kicker: l.hadithOfDay),
                                ),
                                child: SizedBox.square(
                                  dimension: 40,
                                  child: Center(child: WaqtIcon(WaqtIcons.share, size: 19, color: c.onHero)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            d.hadith.text,
                            maxLines: maxLines,
                            overflow: TextOverflow.ellipsis,
                            style: WaqtType.serif(16.5, height: 1.55, color: c.onHero),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${hadithBookName(l, d.book.id)} · ${d.hadith.label}',
                          style: WaqtType.sans(13, weight: 600, color: c.brass),
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

/// Morning / evening adhkar with today's progress.
class _AdhkarTile extends ConsumerWidget {
  const _AdhkarTile({required this.set});
  final AdhkarSet set;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = ref.watch(adhkarTodayProvider(set));
    return _SmallTile(
      icon: set == AdhkarSet.morning ? WaqtIcons.sun : WaqtIcons.moon,
      title: l.adhkarSet(set),
      subtitle: p.isComplete ? l.toolsAdhkarDone : l.adhkarPosOf('${p.doneItems}', '${p.items.length}'),
      brass: p.isComplete,
      onTap: () => context.push(Routes.adhkar(set.name)),
    );
  }
}

class _BigTile extends StatelessWidget {
  const _BigTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final WaqtIconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return WaqtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconTile(icon: icon, background: c.mint, color: c.onMint),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: WaqtType.item(color: c.ink)),
                const SizedBox(height: 2),
                Text(subtitle, style: WaqtType.sans(13.5, color: c.muted)),
              ],
            ),
          ),
          WaqtIcon(WaqtIcons.chevronRight, size: 18, color: c.muted),
        ],
      ),
    );
  }
}

class _SmallTile extends StatelessWidget {
  const _SmallTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.brass = false,
  });

  final WaqtIconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool brass;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return WaqtCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: icon, small: true, background: brass ? c.brassSoft : c.mint, color: brass ? c.brassText : c.onMint),
          const SizedBox(height: 12),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: WaqtType.sans(15.5, weight: 600, color: c.ink)),
          const SizedBox(height: 2),
          Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: WaqtType.sans(12.5, color: c.muted, height: 1.3)),
        ],
      ),
    );
  }
}
