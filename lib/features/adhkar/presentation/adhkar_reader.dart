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
import '../../../data/repositories/adhkar_repository.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../application/adhkar_providers.dart';
import '../domain/adhkar.dart';

/// Full-screen morning/evening adhkar reader with a tap counter.
class AdhkarReader extends ConsumerStatefulWidget {
  const AdhkarReader({super.key, required this.set});

  final AdhkarSet set;

  @override
  ConsumerState<AdhkarReader> createState() => _AdhkarReaderState();
}

class _AdhkarReaderState extends ConsumerState<AdhkarReader> {
  int? _index;

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.today);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final progress = ref.watch(adhkarTodayProvider(widget.set));
    final items = progress.items;
    final lang = Localizations.localeOf(context).languageCode;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    if (items.isEmpty) {
      return Scaffold(backgroundColor: c.bg, body: const Center(child: CircularProgressIndicator()));
    }

    final index = (_index ??= progress.resumeIndex).clamp(0, items.length - 1);
    final item = items[index];
    final count = progress.countOf(item);
    final done = count >= item.count;
    final last = index == items.length - 1;
    final barValue = (index + (count / item.count).clamp(0, 1)) / items.length;

    Future<void> tap() async {
      if (done) return;
      final next = count + 1;
      if (next >= item.count) {
        Haptics.success();
      } else {
        Haptics.tap();
      }
      await ref
          .read(adhkarRepositoryProvider)
          .setCount(ref.read(todayKeyProvider), widget.set, item.id, next);
    }

    void next() {
      if (last) {
        if (progress.isComplete || (done && progress.doneItems == items.length - 1)) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.adhkarSetDone)));
        }
        _close();
      } else {
        setState(() => _index = index + 1);
      }
    }

    return Scaffold(
      backgroundColor: c.bg,
      body: Padding(
        padding: EdgeInsets.only(top: top),
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  Semantics(
                    button: true,
                    label: l.back,
                    excludeSemantics: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _close,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          children: [
                            WaqtIcon(WaqtIcons.chevronLeft, size: 26, color: c.accent, strokeWidth: 2.4),
                            Text(l.tabToday, style: WaqtType.sans(17, weight: 500, color: c.accent)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l.adhkarPosOf('${index + 1}', '${items.length}'),
                    style: WaqtType.sans(14, weight: 600, color: c.muted),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: barValue),
                  duration: Adaptive.motion(context, 300),
                  builder: (_, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 4,
                    color: c.brass,
                    backgroundColor: c.hairline,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (d) {
                  final v = d.primaryVelocity ?? 0;
                  if (v < -300 && !last) setState(() => _index = index + 1);
                  if (v > 300 && index > 0) setState(() => _index = index - 1);
                },
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(Gap.screen, 18, Gap.screen, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
                              child: Semantics(
                                header: true,
                                child: Text(
                                  l.adhkarSet(widget.set),
                                  style: WaqtType.serif(28, tracking: -0.015, color: c.ink),
                                ),
                              ),
                            ),
                            _DhikrCard(item: item, lang: lang),
                          ],
                        ),
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: _Counter(
                            count: count,
                            target: item.count,
                            onTap: tap,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: l.adhkarPrev,
                    excludeSemantics: true,
                    child: Material(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Radii.bigButton),
                        side: BorderSide(color: c.hairline),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: index > 0 ? () => setState(() => _index = index - 1) : null,
                        child: SizedBox.square(
                          dimension: 56,
                          child: Center(
                            child: WaqtIcon(
                              WaqtIcons.chevronLeft,
                              color: index > 0 ? c.ink : c.hairline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PillButton(
                      label: last ? l.adhkarFinish : done ? l.adhkarNextDhikr : l.adhkarNext,
                      style: done ? PillStyle.primary : PillStyle.mint,
                      height: 56,
                      radius: Radii.bigButton,
                      fontSize: 16,
                      expand: true,
                      onPressed: next,
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

class _DhikrCard extends StatelessWidget {
  const _DhikrCard({required this.item, required this.lang});
  final AdhkarItem item;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: c.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            locale: const Locale('ar'),
            style: WaqtType.arabic(item.isLong ? 28 : 42, height: item.isLong ? 1.9 : 1.5, color: c.ink),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 14),
            child: Divider(height: 1, color: c.hairline),
          ),
          if (item.transliteration.isNotEmpty)
            Text(
              item.transliteration,
              style: WaqtType.sans(15, height: 1.5, color: c.muted, style: FontStyle.italic),
            ),
          const SizedBox(height: 8),
          Text(item.translation(lang), style: WaqtType.sans(15, height: 1.5, color: c.ink)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: c.brassSoft, borderRadius: BorderRadius.circular(Radii.pill)),
                alignment: Alignment.center,
                child: Text(l.adhkarRecite('${item.count}'), style: WaqtType.sans(13, weight: 700, color: c.brassText)),
              ),
              const Spacer(),
              Flexible(
                flex: 3,
                child: Text(
                  item.source,
                  textAlign: TextAlign.end,
                  style: WaqtType.sans(12, color: c.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.count, required this.target, required this.onTap});
  final int count;
  final int target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final done = count >= target;
    return Semantics(
      button: true,
      label: '${l.adhkarTapToCount}. $count / $target',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox.square(
          dimension: 184,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: c.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.hairline),
                ),
              ),
              ProgressRing(
                value: count / target,
                color: done ? c.brass : c.accent,
                track: Colors.transparent,
                size: 184,
              ),
              TapRipple(trigger: count, color: c.brass),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$count', style: WaqtType.serif(60, tracking: -0.03, height: 1, color: c.ink)),
                  const SizedBox(height: 4),
                  Text(
                    done ? l.adhkarComplete : l.adhkarOf('$target'),
                    style: WaqtType.sans(14, color: c.muted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
