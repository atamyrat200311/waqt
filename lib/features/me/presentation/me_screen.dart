import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/income_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/share_card.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../quran/application/quran_providers.dart';
import '../../today/application/today_providers.dart';
import '../application/me_providers.dart';
import '../domain/stats.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(Gap.title, top + 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: CircleIconButton(
                      icon: WaqtIcons.sliders,
                      semanticLabel: l.meSettingsA11y,
                      background: c.card,
                      foreground: c.ink,
                      border: true,
                      onPressed: () => context.push(Routes.settings),
                    ),
                  ),
                  Semantics(
                    header: true,
                    child: Text(l.meTitle, style: WaqtType.title(color: c.ink)),
                  ),
                ],
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: Gap.screen),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                _StreakCard(),
                SizedBox(height: 10),
                _OnTimeAndAdhkar(),
                SizedBox(height: 10),
                _QuranStats(),
                SizedBox(height: 10),
                _ConsistencyCard(),
                SizedBox(height: 10),
                _FastsAndSadaqa(),
                SizedBox(height: 10),
                _SpendingCard(),
                SizedBox(height: 10),
                _SettingsRow(),
                BottomSpace(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final s =
        ref.watch(streakProvider) ??
        const StreakStats(
          current: 0,
          best: 0,
          lastDays: [
            StreakDay.broken, StreakDay.broken, StreakDay.broken, StreakDay.broken, StreakDay.broken, //
            StreakDay.broken, StreakDay.broken, StreakDay.broken, StreakDay.broken, StreakDay.broken,
            StreakDay.broken, StreakDay.broken, StreakDay.broken, StreakDay.pending,
          ],
        );
    final n = s.lastDays.length;
    // Day one (or after a break): show today's progress instead of a big 0.
    final todayMarks = ref.watch(todayMarksProvider).value ?? const <Prayer, PrayerStatus>{};
    final prayedToday = Prayer.obligatory.where((p) => todayMarks[p]?.isPrayed == true).length;
    final fresh = s.current == 0;
    return Semantics(
      label: fresh
          ? '${l.meAll5}: $prayedToday/5 ${l.mePrayedToday}. ${l.meBest('${s.best}')}'
          : '${l.meAll5}: ${s.current} ${l.meDaysInRow(s.current)}. ${l.meBest('${s.best}')}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(Radii.heroCard(context))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l.meAll5.toUpperCase(), style: WaqtType.kicker(color: c.onHeroMuted)),
                ),
                if (s.current >= 3)
                  Semantics(
                    button: true,
                    label: l.share,
                    excludeSemantics: true,
                    child: InkResponse(
                      radius: 22,
                      onTap: () => showShareCardSheet(
                        context,
                        ShareCardData(
                          kicker: l.meAll5,
                          big: '${s.current}',
                          text: l.meDaysInRow(s.current),
                          reference: l.meStreakShare,
                        ),
                      ),
                      child: SizedBox.square(
                        dimension: 44,
                        child: Center(child: WaqtIcon(WaqtIcons.share, size: 19, color: c.onHero)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  fresh ? '$prayedToday' : '${s.current}',
                  style: WaqtType.serif(72, weight: 350, tracking: -0.04, height: 1, color: c.onHero),
                ),
                if (fresh) Text('/5', style: WaqtType.serif(34, weight: 350, height: 1, color: c.onHeroMuted)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    fresh ? l.mePrayedToday : l.meDaysInRow(s.current),
                    style: WaqtType.sans(18, color: c.onHeroMuted),
                  ),
                ),
              ],
            ),
            if (fresh) ...[
              const SizedBox(height: 6),
              Text(l.meStartStreak, style: WaqtType.sans(14, color: c.onHeroAccent, weight: 600)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                for (var i = 0; i < n; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: switch (s.lastDays[i]) {
                          StreakDay.kept => c.brass.withValues(alpha: 0.55 + (i / n) * 0.45),
                          StreakDay.skipped => c.brass.withValues(alpha: 0.25),
                          StreakDay.broken || StreakDay.pending => Colors.white.withValues(alpha: 0.14),
                        },
                        border: s.lastDays[i] == StreakDay.pending
                            ? Border.all(color: c.onHeroMuted.withValues(alpha: 0.5))
                            : null,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(l.me2WeeksAgo, style: WaqtType.sans(12, color: c.onHeroMuted)),
                ),
                if (s.best > 0) Text(l.meBest('${s.best}'), style: WaqtType.sans(12, color: c.onHeroMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.caption, this.labelIcon});
  final String label;
  final Widget value;
  final String caption;
  final Widget? labelIcon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: WaqtCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (labelIcon != null) ...[labelIcon!, const SizedBox(width: 6)],
                Flexible(
                  child: Text(label, style: WaqtType.sans(13, weight: 500, color: c.muted)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            value,
            const SizedBox(height: 2),
            Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: WaqtType.sans(12, color: c.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnTimeAndAdhkar extends ConsumerWidget {
  const _OnTimeAndAdhkar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final onTime = ref.watch(monthPrayerStatsProvider)?.onTime;
    final adhkar = ref.watch(adhkarStreakProvider).value ?? 0;
    final big = WaqtType.serif(34, tracking: -0.02, height: 1, color: c.ink);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatTile(
            label: l.meOnTime,
            caption: l.meThisMonth,
            value: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: onTime == null ? '–' : '${(onTime * 100).round()}', style: big),
                  if (onTime != null) TextSpan(text: '%', style: big.copyWith(fontSize: 20)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _StatTile(
            label: l.meAdhkarStreak,
            caption: l.meMorningEvening,
            value: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$adhkar ', style: big),
                  TextSpan(
                    text: l.meDays,
                    style: WaqtType.sans(16, weight: 500, color: c.muted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuranStats extends ConsumerWidget {
  const _QuranStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final streak = ref.watch(quranStreakProvider);
    final month = ref.watch(quranMonthAyahsProvider).value ?? 0;
    final khatm = ref.watch(khatmProgressProvider);
    final big = WaqtType.serif(34, tracking: -0.02, height: 1, color: c.ink);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatTile(
            label: l.meQuranStreak,
            caption: l.meQuranDaily,
            value: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$streak ', style: big),
                  TextSpan(
                    text: l.meDays,
                    style: WaqtType.sans(16, weight: 500, color: c.muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _StatTile(
            label: khatm == null ? l.meAyahsRead : l.khatmShort,
            caption: khatm == null ? l.meThisMonth : l.khatmDayOf('${khatm.dayShown}', '${khatm.plan.days}'),
            value: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: khatm == null ? '$month' : '${(khatm.fraction * 100).floor()}', style: big),
                  if (khatm != null) TextSpan(text: '%', style: big.copyWith(fontSize: 20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsistencyCard extends ConsumerWidget {
  const _ConsistencyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final stats = ref.watch(monthPrayerStatsProvider);
    final today = ref.watch(todayKeyProvider).date;
    final cons = stats?.consistency ?? const {};
    final hasData = cons.values.any((v) => v != null);
    final weak = weakestPrayer(cons);
    final allStrong = cons.values.every((v) => v == null || v >= 0.95);

    final (tipTitle, tipBody) = switch (weak) {
      Prayer.fajr => (l.tipFajrTitle, l.tipFajrBody),
      Prayer.dhuhr => (l.tipDhuhrTitle, l.tipDhuhrBody),
      Prayer.asr => (l.tipAsrTitle, l.tipAsrBody),
      Prayer.maghrib => (l.tipMaghribTitle, l.tipMaghribBody),
      Prayer.isha => (l.tipIshaTitle, l.tipIshaBody),
      Prayer.witr => ('', ''),
      null => ('', ''),
    };

    return WaqtCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(l.meConsistency, style: WaqtType.sans(15, weight: 600, color: c.ink)),
              ),
              Text(l.monthStandalone(monthKey(today)), style: WaqtType.sans(13, color: c.muted)),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasData)
            Text(l.meNoPrayerData, style: WaqtType.sans(14, color: c.muted, height: 1.45))
          else ...[
            for (final p in Prayer.obligatory) ...[
              _ConsistencyBar(name: l.prayer(p), value: cons[p], weak: p == weak && !allStrong),
              if (p != Prayer.isha) const SizedBox(height: 12),
            ],
            if (weak != null && !allStrong) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: c.brassSoft, borderRadius: BorderRadius.circular(16)),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$tipTitle ',
                        style: WaqtType.sans(13, weight: 700, color: c.brassText, height: 1.5),
                      ),
                      TextSpan(
                        text: tipBody,
                        style: WaqtType.sans(13, color: c.brassText, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ConsistencyBar extends StatelessWidget {
  const _ConsistencyBar({required this.name, required this.value, required this.weak});
  final String name;
  final double? value;
  final bool weak;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pct = value == null ? null : (value! * 100).round();
    return Semantics(
      label: '$name ${pct ?? '–'}%',
      excludeSemantics: true,
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                name,
                softWrap: false,
                style: WaqtType.sans(14, weight: 600, color: weak ? c.brassText : c.ink),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 8,
                color: c.fill,
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: (value ?? 0).clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(color: weak ? c.brass : c.accent, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                pct == null ? '–' : '$pct%',
                softWrap: false,
                style: WaqtType.sans(13, weight: 600, color: weak ? c.brassText : c.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FastsAndSadaqa extends ConsumerWidget {
  const _FastsAndSadaqa();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final fasts = (ref.watch(monthFastsProvider).value ?? const {}).values.where((f) => f.status == FastStatus.fasted);
    final byType = <FastType, int>{};
    for (final f in fasts) {
      byType[f.type] = (byType[f.type] ?? 0) + 1;
    }
    final parts = [
      if (byType[FastType.ramadan] != null) l.meFastRamadan('${byType[FastType.ramadan]}'),
      if (byType[FastType.monThu] != null) l.meFastMonThu('${byType[FastType.monThu]}'),
      if (byType[FastType.whiteDays] != null) l.meFastWhite('${byType[FastType.whiteDays]}'),
      if (byType[FastType.other] != null) l.meFastOther('${byType[FastType.other]}'),
    ];
    final sum = ref.watch(monthExpensesProvider).value ?? ExpenseSummary.empty;
    final currency = ref.watch(settingsProvider.select((s) => s.currency));
    final big = WaqtType.serif(34, tracking: -0.02, height: 1, color: c.ink);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatTile(
            label: l.meFasts,
            caption: parts.isEmpty ? l.meFastsNone : parts.join(', '),
            value: Text('${fasts.length}', style: big),
          ),
          const SizedBox(width: 10),
          _StatTile(
            label: l.meSadaqa,
            labelIcon: WaqtIcon(WaqtIcons.heart, size: 14, color: c.brass),
            caption: l.meThisMonth,
            value: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${formatMinor(sum.sadaqaMinor)} ', style: big),
                  TextSpan(
                    text: currency,
                    style: WaqtType.sans(13, weight: 600, color: c.muted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingCard extends ConsumerWidget {
  const _SpendingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final sum = ref.watch(monthExpensesProvider).value ?? ExpenseSummary.empty;
    final incSum = ref.watch(monthIncomesProvider).value ?? IncomeSummary.empty;
    final currency = ref.watch(settingsProvider.select((s) => s.currency));
    final today = ref.watch(todayKeyProvider).date;
    final hasIncome = incSum.totalMinor > 0;
    final netBalance = incSum.totalMinor - sum.totalMinor;
    Color color(ExpenseCategory k) => switch (k) {
      ExpenseCategory.groceries => c.primary,
      ExpenseCategory.food => c.spendFood(),
      ExpenseCategory.bills => c.spendBills(),
      ExpenseCategory.transport => c.spendTransport(),
      ExpenseCategory.other => c.hairline,
      ExpenseCategory.sadaqa => c.brass,
    };
    final cats = <({String label, int value, Color color})>[
      for (final e in sum.byCategory.entries)
        if (e.key != ExpenseCategory.sadaqa) (label: l.category(e.key), value: e.value, color: color(e.key)),
      for (final e in sum.byCustomCategory.entries) (label: e.key, value: e.value, color: c.accent),
    ]..sort((a, b) => b.value.compareTo(a.value));
    if (sum.sadaqaMinor > 0) {
      cats.add((label: l.category(ExpenseCategory.sadaqa), value: sum.sadaqaMinor, color: c.brass));
    }

    return WaqtCard(
      onTap: () => context.push(Routes.expenses),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(hasIncome ? l.financeTitle : l.meSpending, style: WaqtType.sans(15, weight: 600, color: c.ink)),
              ),
              Text(l.monthStandalone(monthKey(today)), style: WaqtType.sans(13, color: c.muted)),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: hasIncome
                      ? '${netBalance >= 0 ? '+' : ''}${formatMinor(netBalance)} '
                      : '${formatMinor(sum.totalMinor)} ',
                  style: WaqtType.serif(40, tracking: -0.03, color: (hasIncome && netBalance < 0) ? c.danger : c.ink),
                ),
                TextSpan(
                  text: currency,
                  style: WaqtType.sans(14, weight: 600, color: c.muted),
                ),
              ],
            ),
          ),
          if (hasIncome) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '+${formatMinor(incSum.totalMinor)} ${l.totalIncome}',
                  style: WaqtType.sans(12.5, weight: 600, color: c.primary),
                ),
                Text('  ·  ', style: WaqtType.sans(12.5, color: c.muted)),
                Text(
                  '-${formatMinor(sum.totalMinor)} ${l.totalExpense}',
                  style: WaqtType.sans(12.5, weight: 600, color: c.muted),
                ),
              ],
            ),
          ],
          if (cats.isEmpty && !hasIncome) ...[
            const SizedBox(height: 6),
            Text(l.meNoSpending, style: WaqtType.sans(14, color: c.muted)),
          ] else ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    for (var i = 0; i < cats.length; i++) ...[
                      if (i > 0) const SizedBox(width: 3),
                      Expanded(
                        flex: (cats[i].value * 1000 / sum.totalMinor).round().clamp(8, 1000),
                        child: Container(
                          decoration: BoxDecoration(color: cats[i].color, borderRadius: BorderRadius.circular(3)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, box) => Wrap(
                runSpacing: 10,
                spacing: 16,
                children: [
                  for (final e in cats)
                    SizedBox(
                      width: (box.maxWidth - 16) / 2,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: e.color, borderRadius: BorderRadius.circular(2)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(e.label, style: WaqtType.sans(13, color: c.muted)),
                          ),
                          Text(formatMinor(e.value), style: WaqtType.sans(13, weight: 600, color: c.ink)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Labelled way into Settings (the round icon at the top is easy to miss).
class _SettingsRow extends StatelessWidget {
  const _SettingsRow();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return WaqtCard(
      onTap: () => context.push(Routes.settings),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          IconTile(icon: WaqtIcons.sliders, small: true),
          const SizedBox(width: 14),
          Expanded(
            child: Text(l.meSettingsRow, style: WaqtType.item(color: c.ink)),
          ),
          WaqtIcon(WaqtIcons.chevronRight, size: 18, color: c.muted),
        ],
      ),
    );
  }
}
