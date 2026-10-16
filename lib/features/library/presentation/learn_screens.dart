import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../application/library_providers.dart';
import '../domain/library_content.dart';

/// List of step-by-step guides (Islam basics, wudu, salah…).
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final lang = l.localeName;
    final guides = ref.watch(guidesProvider).value ?? const <Guide>[];
    return SubScreen(
      title: l.libraryLearn,
      backLabel: l.tabLibrary,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
          sliver: SliverList.separated(
            itemCount: guides.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final g = guides[i];
              return WaqtCard(
                onTap: () => context.push(Routes.learnGuide(g.id)),
                child: Row(
                  children: [
                    IconTile(icon: WaqtIcons.byKey(g.icon), background: c.mint, color: c.onMint),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.title.of(lang), style: WaqtType.sans(16, weight: 600, color: c.ink)),
                          const SizedBox(height: 2),
                          Text(
                            g.subtitle.isEmpty ? l.learnSteps(g.steps.length) : g.subtitle.of(lang),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: WaqtType.sans(13, color: c.muted, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                    WaqtIcon(WaqtIcons.chevronRight, size: 18, color: c.muted),
                  ],
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
            child: Text(l.libraryContentReview, style: WaqtType.sans(12.5, color: c.muted, height: 1.4)),
          ),
        ),
      ],
    );
  }
}

/// One guide as a numbered timeline.
class GuideScreen extends ConsumerWidget {
  const GuideScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final lang = l.localeName;
    final g = (ref.watch(guidesProvider).value ?? const <Guide>[]).where((g) => g.id == id).firstOrNull;
    if (g == null) {
      return SubScreen(title: l.libraryLearn, backLabel: l.libraryLearn, slivers: const []);
    }
    return SubScreen(
      title: g.title.of(lang),
      backLabel: l.libraryLearn,
      slivers: [
        if (!g.intro.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gap.title, 10, Gap.title, 8),
            sliver: SliverToBoxAdapter(
              child: Text(g.intro.of(lang), style: WaqtType.serif(17, height: 1.55, color: c.ink)),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 10, Gap.screen, 0),
          sliver: SliverList.builder(
            itemCount: g.steps.length,
            itemBuilder: (context, i) => _Step(step: g.steps[i], n: i + 1, last: i == g.steps.length - 1),
          ),
        ),
        if (!g.note.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 8, Gap.screen, 0),
            sliver: SliverToBoxAdapter(
              child: WaqtCard(
                color: c.brassSoft,
                border: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WaqtIcon(WaqtIcons.info, size: 20, color: c.brassText),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(g.note.of(lang), style: WaqtType.sans(14, color: c.brassText, height: 1.45)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.step, required this.n, required this.last});
  final GuideStep step;
  final int n;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final lang = l.localeName;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
                  child: Text('$n', style: WaqtType.sans(13.5, weight: 700, color: c.onPrimary)),
                ),
                if (!last)
                  Expanded(
                    child: Container(width: 2, color: c.hairline, margin: const EdgeInsets.symmetric(vertical: 4)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(step.title.of(lang), style: WaqtType.sans(16.5, weight: 600, color: c.ink)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(step.text.of(lang), style: WaqtType.sans(15, color: c.muted, height: 1.5)),
                  if (step.arabic != null) ...[
                    const SizedBox(height: 10),
                    WaqtCard(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            step.arabic!,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: WaqtType.arabic(24, height: 1.8, color: c.ink),
                          ),
                          if (step.translit != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              step.translit!,
                              textAlign: TextAlign.center,
                              style: WaqtType.sans(14, color: c.muted, height: 1.45, style: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
