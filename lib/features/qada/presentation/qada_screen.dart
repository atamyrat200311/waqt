import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/fast_repository.dart';
import '../../../data/repositories/prayer_repository.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/dashed_border.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/segmented.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../today/application/today_providers.dart';

enum QadaTab { prayers, fasts }

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

class QadaScreen extends ConsumerStatefulWidget {
  const QadaScreen({super.key, this.initialTab = QadaTab.prayers});

  final QadaTab initialTab;

  @override
  ConsumerState<QadaScreen> createState() => _QadaScreenState();
}

class _QadaScreenState extends ConsumerState<QadaScreen> {
  late QadaTab _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final cupertino = Adaptive.isCupertino(context);

    // Prayer counts
    final countsAsync = ref.watch(qadaCountsProvider);
    final counts = countsAsync.value ?? {for (final p in Prayer.tracked) p: 0};
    final prayerTotal = counts.values.fold(0, (a, b) => a + b);
    final prayersMade = ref.watch(madeUpTotalProvider).value ?? 0;

    // Fasting counts
    final fastsOwed = ref.watch(fastsOwedProvider).value ?? 0;
    final fastsMade = ref.watch(qadaFastMadeUpTotalProvider).value ?? 0;
    final today = ref.watch(todayKeyProvider);
    final todayFast = ref.watch(todayFastProvider).value;
    final isFastedToday = todayFast?.type == FastType.qada && todayFast?.status == FastStatus.fasted;

    return SubScreen(
      title: l.qadaTitle,
      backLabel: l.tabToday,
      trailing: CircleIconButton(
        icon: WaqtIcons.edit,
        semanticLabel: _tab == QadaTab.prayers ? l.qadaEditBalances : l.qadaEditFastBalancesTitle,
        background: c.fill,
        foreground: c.ink,
        onPressed: _tab == QadaTab.prayers
            ? (countsAsync.value == null ? null : () => showEditQadaSheet(context, counts))
            : () => showEditQadaFastSheet(context, fastsOwed),
      ),
      floatingActionButton: cupertino
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _tab == QadaTab.prayers
                  ? showAddOlderSheet(context)
                  : showAddOlderFastSheet(context),
              backgroundColor: c.mint,
              foregroundColor: c.onMint,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              icon: WaqtIcon(WaqtIcons.plus, color: c.onMint),
              label: Text(
                _tab == QadaTab.prayers ? l.qadaAddOlder : l.qadaAddOlderFasts,
                style: WaqtType.sans(15, weight: 600, color: c.onMint),
              ),
            ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 4),
            child: Segmented<QadaTab>(
              value: _tab,
              options: [
                (QadaTab.prayers, l.qadaTabPrayers),
                (QadaTab.fasts, l.qadaTabFasts),
              ],
              onChanged: (tab) {
                Haptics.tap();
                setState(() => _tab = tab);
              },
            ),
          ),
        ),

        if (_tab == QadaTab.prayers) ...[
          // Prayer big count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.title, 14, Gap.title, 0),
              child: Semantics(
                label: '$prayerTotal ${l.qadaLeft}',
                excludeSemantics: true,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Bump(
                        value: prayerTotal,
                        child: Text(
                          '$prayerTotal',
                          maxLines: 1,
                          softWrap: false,
                          style: WaqtType.serif(96, weight: 300, tracking: -0.05, height: 0.82, opsz: 120, color: c.ink),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          l.qadaLeft,
                          maxLines: 1,
                          softWrap: false,
                          style: WaqtType.sans(15, color: c.muted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (prayersMade > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Gap.title, 14, Gap.title, 0),
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
                            l.qadaMadeUpSince('$prayersMade'),
                            style: WaqtType.sans(14, weight: 600, color: c.brassText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Last prayer activity / motivational card
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(Gap.screen, 16, Gap.screen, 0),
              child: _PrayerLastActivityCard(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(padding: EdgeInsets.fromLTRB(Gap.screen, 16, Gap.screen, 0), child: _WeekCard()),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
              child: WaqtGroup(
                children: [
                  for (final p in Prayer.tracked) _QadaRow(prayer: p, count: counts[p] ?? 0),
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
                prayerTotal == 0 && prayersMade == 0 ? l.qadaEmpty : l.qadaTip,
                textAlign: TextAlign.center,
                style: WaqtType.sans(13, color: c.muted, height: 1.5),
              ),
            ),
          ),
        ] else ...[
          // Fasting big count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.title, 14, Gap.title, 0),
              child: Semantics(
                label: '$fastsOwed ${l.qadaFastsLeft}',
                excludeSemantics: true,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Bump(
                        value: fastsOwed,
                        child: Text(
                          '$fastsOwed',
                          maxLines: 1,
                          softWrap: false,
                          style: WaqtType.serif(96, weight: 300, tracking: -0.05, height: 0.82, opsz: 120, color: c.ink),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          l.qadaFastsLeft,
                          maxLines: 1,
                          softWrap: false,
                          style: WaqtType.sans(15, color: c.muted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (fastsMade > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Gap.title, 14, Gap.title, 0),
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
                            l.qadaFastsMadeUpSince('$fastsMade'),
                            style: WaqtType.sans(14, weight: 600, color: c.brassText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Last fasting activity / motivational card
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(Gap.screen, 16, Gap.screen, 0),
              child: _FastLastActivityCard(),
            ),
          ),
          // Fasting actions card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
              child: WaqtCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        WaqtIcon(WaqtIcons.moon, size: 20, color: c.ink),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l.fastTypeQada,
                            style: WaqtType.sans(16, weight: 600, color: c.ink),
                          ),
                        ),
                        if (isFastedToday)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: c.brassSoft,
                              borderRadius: BorderRadius.circular(Radii.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                WaqtIcon(WaqtIcons.check, size: 14, color: c.brassText, strokeWidth: 2.4),
                                const SizedBox(width: 5),
                                Text(
                                  l.qadaFastLoggedToday,
                                  style: WaqtType.sans(12.5, weight: 600, color: c.brassText),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.fastsOwedSub,
                      style: WaqtType.sans(13, color: c.muted, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    PillButton(
                      label: isFastedToday ? l.qadaFastLoggedToday : l.fastsLogQada,
                      icon: isFastedToday ? WaqtIcons.check : null,
                      style: isFastedToday ? PillStyle.brass : PillStyle.mint,
                      height: 48,
                      fontSize: 14.5,
                      expand: true,
                      onPressed: () async {
                        Haptics.success();
                        final repo = ref.read(fastRepositoryProvider);
                        final messenger = ScaffoldMessenger.maybeOf(context);
                        if (isFastedToday) {
                          await repo.set(today, FastType.qada, null);
                          messenger?.hideCurrentSnackBar();
                          messenger?.showSnackBar(
                            SnackBar(content: Text(l.qadaFastUndoneSnack)),
                          );
                        } else {
                          await repo.set(today, FastType.qada, FastStatus.fasted);
                          messenger?.hideCurrentSnackBar();
                          messenger?.showSnackBar(
                            SnackBar(
                              content: Text(l.qadaFastMadeUpSnack),
                              action: SnackBarAction(
                                label: l.undo,
                                onPressed: () => repo.set(today, FastType.qada, null),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    if (isFastedToday) ...[
                      const SizedBox(height: 10),
                      PillButton(
                        label: l.qadaLogFastMadeUp,
                        style: PillStyle.outline,
                        height: 44,
                        fontSize: 14,
                        expand: true,
                        onPressed: fastsOwed <= 0
                            ? null
                            : () async {
                                Haptics.success();
                                final repo = ref.read(fastRepositoryProvider);
                                final messenger = ScaffoldMessenger.maybeOf(context);
                                await repo.setQadaRemaining(fastsOwed - 1);
                                messenger?.hideCurrentSnackBar();
                                messenger?.showSnackBar(
                                  SnackBar(
                                    content: Text(l.qadaFastMadeUpSnack),
                                    action: SnackBarAction(
                                      label: l.undo,
                                      onPressed: () => repo.setQadaRemaining(fastsOwed),
                                    ),
                                  ),
                                );
                              },
                      ),
                    ],
                  ],
                ),
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
                      onTap: () => showAddOlderFastSheet(context),
                      child: SizedBox(
                        height: 54,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WaqtIcon(WaqtIcons.plus, size: 18, color: c.accent),
                            const SizedBox(width: 8),
                            Text(l.qadaAddOlderFasts, style: WaqtType.sans(15, weight: 600, color: c.accent)),
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
                l.qadaFastTip,
                textAlign: TextAlign.center,
                style: WaqtType.sans(13, color: c.muted, height: 1.5),
              ),
            ),
          ),
        ],

        if (!cupertino) const SliverToBoxAdapter(child: SizedBox(height: 72)),
      ],
    );
  }
}

/// Last activity / motivation card for missed prayers.
class _PrayerLastActivityCard extends ConsumerWidget {
  const _PrayerLastActivityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final lastMadeUp = ref.watch(qadaLastMadeUpEventProvider).value;
    final lastActivity = ref.watch(qadaLastActivityEventProvider).value;
    final today = ref.watch(todayKeyProvider).date;

    if (lastMadeUp != null) {
      final days = daysBetween(lastMadeUp.createdAt, today);
      final isWarning = days >= 2;
      final timeStr = days == 0
          ? l.qadaTodayMadeUp
          : days == 1
              ? l.qadaYesterdayMadeUp
              : l.qadaTimeAgoDays(days);
      final dateStr = '${lastMadeUp.createdAt.day} ${l.monthShort(monthKey(lastMadeUp.createdAt))}';

      return WaqtCard(
        color: isWarning ? c.brassSoft : c.fill,
        border: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isWarning ? c.brass.withValues(alpha: 0.22) : c.card,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: WaqtIcon(
                days == 0 ? WaqtIcons.check : WaqtIcons.clock,
                size: 18,
                color: isWarning ? c.brassText : c.ink,
                strokeWidth: 2.2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isWarning ? l.qadaDaysAgoWarning(days) : timeStr,
                    style: WaqtType.sans(
                      15,
                      weight: 600,
                      color: isWarning ? c.brassText : c.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isWarning
                        ? '${l.qadaLastMadeUp('$timeStr ($dateStr)')} · ${l.qadaDaysAgoHint}'
                        : '${l.prayer(lastMadeUp.prayer)} · ${hhmm(lastMadeUp.createdAt.toLocal())}',
                    style: WaqtType.sans(13, color: isWarning ? c.brassText.withValues(alpha: 0.85) : c.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (lastActivity != null) {
      final days = daysBetween(lastActivity.createdAt, today);
      final isWarning = days >= 2;
      final timeStr = days == 0
          ? l.today
          : days == 1
              ? l.yesterday
              : l.qadaTimeAgoDays(days);
      final dateStr = '${lastActivity.createdAt.day} ${l.monthShort(monthKey(lastActivity.createdAt))}';

      return WaqtCard(
        color: isWarning ? c.brassSoft : c.fill,
        border: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isWarning ? c.brass.withValues(alpha: 0.22) : c.card,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: WaqtIcon(
                WaqtIcons.clock,
                size: 18,
                color: isWarning ? c.brassText : c.ink,
                strokeWidth: 2.2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isWarning ? l.qadaDaysAgoWarning(days) : l.qadaLastUpdated(timeStr),
                    style: WaqtType.sans(
                      15,
                      weight: 600,
                      color: isWarning ? c.brassText : c.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isWarning
                        ? '${l.qadaLastUpdated('$timeStr ($dateStr)')} · ${l.qadaDaysAgoHint}'
                        : l.qadaDaysAgoHint,
                    style: WaqtType.sans(13, color: isWarning ? c.brassText.withValues(alpha: 0.85) : c.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return WaqtCard(
      color: c.fill,
      border: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c.card,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: WaqtIcon(WaqtIcons.qada, size: 18, color: c.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.qadaNoActivityYet,
                  style: WaqtType.sans(15, weight: 600, color: c.ink),
                ),
                const SizedBox(height: 3),
                Text(
                  l.qadaTip,
                  style: WaqtType.sans(13, color: c.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Last activity / motivation card for missed fasts.
class _FastLastActivityCard extends ConsumerWidget {
  const _FastLastActivityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final lastFastDate = ref.watch(qadaFastLastMadeUpDateProvider).value;
    final lastModified = ref.watch(qadaFastLastModifiedProvider).value;
    final today = ref.watch(todayKeyProvider).date;

    if (lastFastDate != null) {
      final days = daysBetween(lastFastDate.date, today);
      final isWarning = days >= 2;
      final timeStr = days == 0
          ? l.qadaTodayMadeUp
          : days == 1
              ? l.qadaYesterdayMadeUp
              : l.qadaTimeAgoDays(days);
      final dateStr = '${lastFastDate.date.day} ${l.monthShort(monthKey(lastFastDate.date))}';

      return WaqtCard(
        color: isWarning ? c.brassSoft : c.fill,
        border: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isWarning ? c.brass.withValues(alpha: 0.22) : c.card,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: WaqtIcon(
                days == 0 ? WaqtIcons.check : WaqtIcons.moon,
                size: 18,
                color: isWarning ? c.brassText : c.ink,
                strokeWidth: 2.2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isWarning ? l.qadaFastDaysAgoWarning(days) : timeStr,
                    style: WaqtType.sans(
                      15,
                      weight: 600,
                      color: isWarning ? c.brassText : c.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isWarning
                        ? '${l.qadaLastMadeUp('$timeStr ($dateStr)')} · ${l.qadaFastDaysAgoHint}'
                        : '${l.fastTypeQada} · $dateStr',
                    style: WaqtType.sans(13, color: isWarning ? c.brassText.withValues(alpha: 0.85) : c.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (lastModified != null) {
      final days = daysBetween(lastModified, today);
      final isWarning = days >= 2;
      final timeStr = days == 0
          ? l.today
          : days == 1
              ? l.yesterday
              : l.qadaTimeAgoDays(days);
      final dateStr = '${lastModified.day} ${l.monthShort(monthKey(lastModified))}';

      return WaqtCard(
        color: isWarning ? c.brassSoft : c.fill,
        border: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isWarning ? c.brass.withValues(alpha: 0.22) : c.card,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: WaqtIcon(
                WaqtIcons.clock,
                size: 18,
                color: isWarning ? c.brassText : c.ink,
                strokeWidth: 2.2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isWarning ? l.qadaFastDaysAgoWarning(days) : l.qadaLastUpdated(timeStr),
                    style: WaqtType.sans(
                      15,
                      weight: 600,
                      color: isWarning ? c.brassText : c.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isWarning
                        ? '${l.qadaLastUpdated('$timeStr ($dateStr)')} · ${l.qadaFastDaysAgoHint}'
                        : l.qadaFastDaysAgoHint,
                    style: WaqtType.sans(13, color: isWarning ? c.brassText.withValues(alpha: 0.85) : c.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return WaqtCard(
      color: c.fill,
      border: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c.card,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: WaqtIcon(WaqtIcons.moon, size: 18, color: c.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.qadaNoActivityYet,
                  style: WaqtType.sans(15, weight: 600, color: c.ink),
                ),
                const SizedBox(height: 3),
                Text(
                  l.qadaFastTip,
                  style: WaqtType.sans(13, color: c.muted),
                ),
              ],
            ),
          ),
        ],
      ),
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
              width: 68,
              child: _Bump(
                value: count,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    '$count',
                    maxLines: 1,
                    softWrap: false,
                    style: WaqtType.serif(26, color: zero ? c.muted : c.ink),
                  ),
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
                  : () async {
                      Haptics.success();
                      final repo = ref.read(prayerRepositoryProvider);
                      final messenger = ScaffoldMessenger.maybeOf(context);
                      final ok = await repo.makeUp(prayer);
                      if (!ok || messenger == null) return;
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          content: Text(l.qadaMadeUpSnack(l.prayer(prayer))),
                          duration: const Duration(seconds: 5),
                          action: SnackBarAction(label: l.undo, onPressed: () => repo.undoMakeUp(prayer)),
                        ));
                    },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showEditQadaSheet(BuildContext context, Map<Prayer, int> counts) =>
    Adaptive.showSheet<void>(
      context,
      builder: (_) => _EditQadaSheet(initial: Map.of(counts)),
    );

class _EditQadaSheet extends ConsumerStatefulWidget {
  const _EditQadaSheet({required this.initial});

  final Map<Prayer, int> initial;

  @override
  ConsumerState<_EditQadaSheet> createState() => _EditQadaSheetState();
}

class _EditQadaSheetState extends ConsumerState<_EditQadaSheet> {
  static const _max = 99999;
  late final Map<Prayer, int> _counts = {
    for (final p in Prayer.tracked) p: widget.initial[p] ?? 0,
  };
  late final Map<Prayer, TextEditingController> _ctl = {
    for (final p in Prayer.tracked)
      p: TextEditingController(text: '${widget.initial[p] ?? 0}'),
  };

  @override
  void dispose() {
    for (final controller in _ctl.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _set(Prayer prayer, int value, {bool updateField = true}) {
    final count = value.clamp(0, _max);
    setState(() => _counts[prayer] = count);
    if (updateField) {
      _ctl[prayer]!
        ..text = '$count'
        ..selection = TextSelection.collapsed(offset: '$count'.length);
    }
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final savedMessage = context.l10n.qadaBalancesSaved;
    await ref.read(prayerRepositoryProvider).setQadaCounts(Map.of(_counts));
    Haptics.success();
    if (!mounted) return;
    await Navigator.of(context).maybePop();
    messenger?.showSnackBar(SnackBar(content: Text(savedMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
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
          Text(l.qadaEditBalancesTitle, style: WaqtType.serif(28, tracking: -0.015, color: c.ink)),
          const SizedBox(height: 6),
          Text(l.qadaEditBalancesBody, style: WaqtType.sans(14, color: c.muted, height: 1.45)),
          const SizedBox(height: 14),
          for (final prayer in Prayer.tracked)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l.prayer(prayer), style: WaqtType.sans(16, weight: 600, color: c.ink)),
                  ),
                  CircleIconButton(
                    icon: WaqtIcons.minus,
                    iconSize: 18,
                    size: 40,
                    background: c.fill,
                    foreground: c.ink,
                    semanticLabel: '${l.prayer(prayer)} −1',
                    onPressed: _counts[prayer]! > 0 ? () => _set(prayer, _counts[prayer]! - 1) : null,
                  ),
                  SizedBox(
                    width: 82,
                    child: TextField(
                      controller: _ctl[prayer],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: WaqtType.serif(24, color: c.ink),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, counterText: ''),
                      onTap: () => _ctl[prayer]!.selection = TextSelection(baseOffset: 0, extentOffset: _ctl[prayer]!.text.length),
                      onChanged: (value) => _set(prayer, int.tryParse(value) ?? 0, updateField: false),
                    ),
                  ),
                  CircleIconButton(
                    icon: WaqtIcons.plus,
                    iconSize: 18,
                    size: 40,
                    background: c.fill,
                    foreground: c.ink,
                    semanticLabel: '${l.prayer(prayer)} +1',
                    onPressed: () => _set(prayer, _counts[prayer]! + 1),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          BigButton(label: l.qadaSaveBalances, style: PillStyle.brass, onPressed: _save),
        ],
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
  final Map<Prayer, int> _counts = {for (final p in Prayer.tracked) p: 0};
  final Map<Prayer, TextEditingController> _ctl = {
    for (final p in Prayer.tracked) p: TextEditingController(text: '0'),
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
          const SizedBox(height: 12),
          Text(l.qadaYearsHelper, style: WaqtType.sans(13.5, weight: 600, color: c.ink)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (label, days) in [
                (l.qadaMonths(1), 30),
                (l.qadaMonths(6), 182),
                (l.qadaYears(1), 365),
                (l.qadaYears(3), 1095),
                (l.qadaYears(5), 1826),
                (l.qadaYears(10), 3652),
              ])
                ActionChip(
                  label: Text(label, maxLines: 1, softWrap: false),
                  onPressed: () {
                    Haptics.tap();
                    for (final p in Prayer.tracked) {
                      _set(p, days);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final p in Prayer.tracked)
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      maxLines: 1,
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

Future<void> showEditQadaFastSheet(BuildContext context, int initialCount) =>
    Adaptive.showSheet<void>(
      context,
      builder: (_) => _EditQadaFastSheet(initial: initialCount),
    );

class _EditQadaFastSheet extends ConsumerStatefulWidget {
  const _EditQadaFastSheet({required this.initial});
  final int initial;

  @override
  ConsumerState<_EditQadaFastSheet> createState() => _EditQadaFastSheetState();
}

class _EditQadaFastSheetState extends ConsumerState<_EditQadaFastSheet> {
  static const _max = 99999;
  late int _count = widget.initial;
  late final TextEditingController _ctl = TextEditingController(text: '${widget.initial}');

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _set(int value, {bool updateField = true}) {
    final v = value.clamp(0, _max);
    setState(() => _count = v);
    if (updateField) {
      _ctl.text = '$v';
      _ctl.selection = TextSelection.collapsed(offset: '$v'.length);
    }
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final savedMessage = context.l10n.qadaBalancesSaved;
    await ref.read(fastRepositoryProvider).setQadaRemaining(_count);
    Haptics.success();
    if (!mounted) return;
    await Navigator.of(context).maybePop();
    messenger?.showSnackBar(SnackBar(content: Text(savedMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
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
          Text(l.qadaEditFastBalancesTitle, style: WaqtType.serif(28, tracking: -0.015, color: c.ink)),
          const SizedBox(height: 6),
          Text(l.qadaEditFastBalancesBody, style: WaqtType.sans(14, color: c.muted, height: 1.45)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(l.fastTypeQada, style: WaqtType.sans(16, weight: 600, color: c.ink)),
              ),
              CircleIconButton(
                icon: WaqtIcons.minus,
                iconSize: 18,
                size: 44,
                background: c.fill,
                foreground: c.ink,
                semanticLabel: '−1',
                onPressed: _count > 0 ? () => _set(_count - 1) : null,
              ),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _ctl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: WaqtType.serif(28, color: c.ink),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  onChanged: (val) => _set(int.tryParse(val) ?? 0, updateField: false),
                ),
              ),
              CircleIconButton(
                icon: WaqtIcons.plus,
                iconSize: 18,
                size: 44,
                background: c.fill,
                foreground: c.ink,
                semanticLabel: '+1',
                onPressed: () => _set(_count + 1),
              ),
            ],
          ),
          const SizedBox(height: 24),
          BigButton(label: l.qadaSaveBalances, style: PillStyle.brass, onPressed: _save),
        ],
      ),
    );
  }
}

Future<void> showAddOlderFastSheet(BuildContext context) =>
    Adaptive.showSheet<void>(context, builder: (_) => const _AddOlderFastSheet());

class _AddOlderFastSheet extends ConsumerStatefulWidget {
  const _AddOlderFastSheet();

  @override
  ConsumerState<_AddOlderFastSheet> createState() => _AddOlderFastSheetState();
}

class _AddOlderFastSheetState extends ConsumerState<_AddOlderFastSheet> {
  static const _max = 99999;
  int _count = 0;
  final TextEditingController _ctl = TextEditingController(text: '0');

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _set(int value, {bool updateField = true}) {
    final v = value.clamp(0, _max);
    setState(() => _count = v);
    if (updateField) {
      _ctl.text = '$v';
      _ctl.selection = TextSelection.collapsed(offset: '$v'.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
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
          Text(l.qadaAddOlderFastsTitle, style: WaqtType.serif(28, tracking: -0.015, color: c.ink)),
          const SizedBox(height: 6),
          Text(l.qadaAddOlderFastsBody, style: WaqtType.sans(14, color: c.muted, height: 1.45)),
          const SizedBox(height: 14),
          Text(l.qadaYearsHelper, style: WaqtType.sans(13.5, weight: 600, color: c.ink)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (label, days) in [
                ('+1', 1),
                ('+3', 3),
                ('+7', 7),
                ('+10', 10),
                ('+15', 15),
                (l.qadaRamadanMonth, 30),
                (l.qadaRamadanTwoMonths, 60),
              ])
                ActionChip(
                  label: Text(label, maxLines: 1, softWrap: false),
                  onPressed: () {
                    Haptics.tap();
                    _set(_count + days);
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(l.fastTypeQada, style: WaqtType.sans(16, weight: 600, color: c.ink)),
              ),
              CircleIconButton(
                icon: WaqtIcons.minus,
                iconSize: 18,
                size: 44,
                background: c.fill,
                foreground: c.ink,
                semanticLabel: '−1',
                onPressed: _count > 0 ? () => _set(_count - 1) : null,
              ),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _ctl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: WaqtType.serif(28, color: c.ink),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  onChanged: (val) => _set(int.tryParse(val) ?? 0, updateField: false),
                ),
              ),
              CircleIconButton(
                icon: WaqtIcons.plus,
                iconSize: 18,
                size: 44,
                background: c.fill,
                foreground: c.ink,
                semanticLabel: '+1',
                onPressed: () => _set(_count + 1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          BigButton(
            label: l.qadaAddFastCount(_count),
            style: PillStyle.brass,
            onPressed: _count == 0
                ? null
                : () async {
                    await ref.read(fastRepositoryProvider).addOlder(_count);
                    if (context.mounted) unawaited(Navigator.of(context).maybePop());
                  },
          ),
        ],
      ),
    );
  }
}
