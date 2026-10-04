import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/prayer_repository.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/dashed_border.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../today/application/today_providers.dart';

final madeUpTotalProvider = StreamProvider<int>(
  (ref) => ref.watch(prayerRepositoryProvider).watchMadeUpTotal(),
);

/// Made-up counts Monday…Sunday of the current week.
final madeUpWeekProvider = StreamProvider<List<int>>((ref) {
  final today = ref.watch(todayKeyProvider);
  final monday = DayKey.fromDate(startOfWeek(today.date));
  final from = monday.date;
  final to = monday.addDays(7).date;
  return ref.watch(prayerRepositoryProvider).watchMadeUpByDay(from, to).map(
        (m) => [for (var i = 0; i < 7; i++) m[monday.addDays(i)] ?? 0],
      );
});

class QadaScreen extends ConsumerWidget {
  const QadaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final cupertino = Adaptive.isCupertino(context);
    final counts = ref.watch(qadaCountsProvider).value ?? {for (final p in Prayer.values) p: 0};
    final total = counts.values.fold(0, (a, b) => a + b);
    final made = ref.watch(madeUpTotalProvider).value ?? 0;

    return SubScreen(
      title: l.qadaTitle,
      backLabel: l.tabToday,
      floatingActionButton: cupertino
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showAddOlderSheet(context),
              backgroundColor: c.mint,
              foregroundColor: c.onMint,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: WaqtIcon(WaqtIcons.plus, color: c.onMint),
              label: Text(l.qadaAddOlder, style: WaqtType.sans(15, weight: 600, color: c.onMint)),
            ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.title, 18, Gap.title, 0),
            child: Semantics(
              label: '$total ${l.qadaLeft.replaceAll('\n', ' ')}',
              excludeSemantics: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Bump(
                    value: total,
                    child: Text(
                      '$total',
                      style: WaqtType.serif(112, weight: 300, tracking: -0.05, height: 0.82, opsz: 144, color: c.ink),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(l.qadaLeft, style: WaqtType.sans(15, color: c.muted, height: 1.35)),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (made > 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.title, 18, Gap.title, 0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 9, 14, 9),
                  decoration: BoxDecoration(color: c.brassSoft, borderRadius: BorderRadius.circular(Radii.pill)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WaqtIcon(WaqtIcons.check, size: 16, color: c.brassText, strokeWidth: 2.6),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l.qadaMadeUpSince('$made'),
                          style: WaqtType.sans(14, weight: 600, color: c.brassText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.fromLTRB(Gap.screen, 22, Gap.screen, 0), child: _WeekCard()),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
            child: WaqtGroup(
              children: [
                for (final p in Prayer.values) _QadaRow(prayer: p, count: counts[p] ?? 0),
              ],
            ),
          ),
        ),
        if (cupertino)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
              child: DashedBorder(
                color: c.hairline,
                radius: Radii.card(context),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Radii.card(context)),
                    onTap: () => showAddOlderSheet(context),
                    child: SizedBox(
                      height: 54,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WaqtIcon(WaqtIcons.plus, size: 18, color: c.accent),
                          const SizedBox(width: 8),
                          Text(l.qadaAddOlder, style: WaqtType.sans(15, weight: 600, color: c.accent)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
            child: Text(
              total == 0 && made == 0 ? l.qadaEmpty : l.qadaTip,
              textAlign: TextAlign.center,
              style: WaqtType.sans(13, color: c.muted, height: 1.5),
            ),
          ),
        ),
        if (!cupertino) const SliverToBoxAdapter(child: SizedBox(height: 72)),
      ],
    );
  }
}

/// Scale bump (.3 s) whenever [value] changes.
class _Bump extends StatelessWidget {
  const _Bump({required this.value, required this.child});
  final int value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Adaptive.reduceMotion(context)) return child;
    return child
        .animate(key: ValueKey(value))
        .scaleXY(begin: 1, end: 0.92, duration: 120.ms, curve: Curves.easeOut)
        .then()
        .scaleXY(begin: 1, end: 1 / 0.92, duration: 180.ms, curve: Curves.easeOut);
  }
}

class _WeekCard extends ConsumerWidget {
  const _WeekCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final week = ref.watch(madeUpWeekProvider).value ?? List.filled(7, 0);
    final todayIdx = ref.watch(todayKeyProvider).date.weekday - 1;
    final sum = week.fold(0, (a, b) => a + b);
    return WaqtCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(l.qadaThisWeek, style: WaqtType.sans(15, weight: 600, color: c.ink))),
              Text(l.qadaWeekMadeUp('$sum'), style: WaqtType.sans(13, color: c.muted)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 84,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Semantics(
                      label: '${l.weekdayName(weekdayKeys[i])}: ${week[i]}',
                      excludeSemantics: true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: Adaptive.motion(context, 300),
                            curve: const Cubic(0.3, 1.4, 0.5, 1),
                            constraints: const BoxConstraints(maxWidth: 26),
                            height: (week[i] * 16).clamp(6, 60).toDouble(),
                            decoration: BoxDecoration(
                              color: (i == todayIdx ? c.brass : c.accent).withValues(alpha: week[i] > 0 ? 1 : 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l.weekdayInitial(weekdayKeys[i]),
                            style: WaqtType.sans(
                              12,
                              weight: i == todayIdx ? 700 : 500,
                              color: i == todayIdx ? c.brassText : c.muted,
                            ),
                          ),
                        ],
                      ),
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

class _QadaRow extends ConsumerWidget {
  const _QadaRow({required this.prayer, required this.count});
  final Prayer prayer;
  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final zero = count == 0;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 8, 12, 8),
        child: Row(
          children: [
            Expanded(child: Text(l.prayer(prayer), style: WaqtType.sans(16, weight: 600, color: c.ink))),
            SizedBox(
              width: 44,
              child: _Bump(
                value: count,
                child: Text(
                  '$count',
                  textAlign: TextAlign.right,
                  style: WaqtType.serif(26, color: zero ? c.muted : c.ink),
                ),
              ),
            ),
            const SizedBox(width: 12),
            PillButton(
              label: zero ? l.qadaAllDone : l.qadaMadeUp,
              style: zero ? PillStyle.outline : PillStyle.mint,
              minWidth: 100,
              fontSize: 14,
              semanticLabel: zero ? '${l.prayer(prayer)}: ${l.qadaAllDone}' : '${l.qadaMadeUp}: ${l.prayer(prayer)}',
              onPressed: zero
                  ? null
                  : () {
                      Haptics.success();
                      ref.read(prayerRepositoryProvider).makeUp(prayer);
                    },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAddOlderSheet(BuildContext context) =>
    Adaptive.showSheet<void>(context, builder: (_) => const _AddOlderSheet());

class _AddOlderSheet extends ConsumerStatefulWidget {
  const _AddOlderSheet();

  @override
  ConsumerState<_AddOlderSheet> createState() => _AddOlderSheetState();
}

class _AddOlderSheetState extends ConsumerState<_AddOlderSheet> {
  final Map<Prayer, int> _counts = {for (final p in Prayer.values) p: 0};
  final Map<Prayer, TextEditingController> _ctl = {
    for (final p in Prayer.values) p: TextEditingController(text: '0'),
  };

  static const _max = 99999;

  @override
  void dispose() {
    for (final c in _ctl.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _set(Prayer p, int v, {bool updateField = true}) {
    final n = v.clamp(0, _max);
    setState(() => _counts[p] = n);
    if (updateField) _ctl[p]!.text = '$n';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final total = _counts.values.fold(0, (a, b) => a + b);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.qadaAddOlderTitle, style: WaqtType.serif(28, tracking: -0.015, color: c.ink)),
          const SizedBox(height: 6),
          Text(l.qadaAddOlderBody, style: WaqtType.sans(14, color: c.muted, height: 1.45)),
          const SizedBox(height: 16),
          for (final p in Prayer.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(l.prayer(p), style: WaqtType.sans(16, weight: 600, color: c.ink))),
                  CircleIconButton(
                    icon: WaqtIcons.minus,
                    iconSize: 18,
                    size: 40,
                    background: c.fill,
                    foreground: c.ink,
                    semanticLabel: '${l.prayer(p)} −1',
                    onPressed: _counts[p]! > 0 ? () => _set(p, _counts[p]! - 1) : null,
                  ),
                  SizedBox(
                    width: 72,
                    child: TextField(
                      controller: _ctl[p],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: WaqtType.serif(24, color: c.ink),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                      onChanged: (s) => _set(p, int.tryParse(s) ?? 0, updateField: false),
                    ),
                  ),
                  CircleIconButton(
                    icon: WaqtIcons.plus,
                    iconSize: 18,
                    size: 40,
                    background: c.fill,
                    foreground: c.ink,
                    semanticLabel: '${l.prayer(p)} +1',
                    onPressed: () => _set(p, _counts[p]! + 1),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          BigButton(
            label: l.qadaAddCount(total),
            style: PillStyle.brass,
            onPressed: total == 0
                ? null
                : () async {
                    await ref.read(prayerRepositoryProvider).addOlder(Map.of(_counts));
                    if (context.mounted) unawaited(Navigator.of(context).maybePop());
                  },
          ),
        ],
      ),
    );
  }
}
