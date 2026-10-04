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
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
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
                  Semantics(header: true, child: Text(l.meTitle, style: WaqtType.title(color: c.ink))),
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
                _ConsistencyCard(),
                SizedBox(height: 10),
                _FastsAndSadaqa(),
                SizedBox(height: 10),
                _SpendingCard(),
                SizedBox(height: 32),
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
    final s = ref.watch(streakProvider) ??
        const StreakStats(current: 0, best: 0, lastDays: [
          StreakDay.broken, StreakDay.broken, StreakDay.broken, StreakDay.broken, StreakDay.broken, //
          StreakDay.broken, StreakDay.broken, StreakDay.broken, StreakDay.broken, StreakDay.broken,
          StreakDay.broken, StreakDay.broken, StreakDay.broken, StreakDay.pending,
        ]);
    final n = s.lastDays.length;
    return Semantics(
      label: '${l.meAll5}: ${s.current} ${l.meDaysInRow(s.current)}. ${l.meBest('${s.best}')}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(Radii.heroCard(context))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.meAll5.toUpperCase(), style: WaqtType.kicker(color: c.onHeroMuted)),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${s.current}',
                  style: WaqtType.serif(72, weight: 350, tracking: -0.04, height: 1, color: c.onHero),
                ),
                const SizedBox(width: 8),
                Flexible(child: Text(l.meDaysInRow(s.current), style: WaqtType.sans(18, color: c.onHeroMuted))),
              ],
            ),
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
                Expanded(child: Text(l.me2WeeksAgo, style: WaqtType.sans(12, color: c.onHeroMuted))),
                Text(l.meBest('${s.best}'), style: WaqtType.sans(12, color: c.onHeroMuted)),
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
                Flexible(child: Text(label, style: WaqtType.sans(13, weight: 500, color: c.muted))),
              ],
            ),
            const SizedBox(height: 10),
            value,
            const SizedBox(height: 2),
            Text(caption, maxLines: 2, overflow: TextOverflow.ellipsis, style: WaqtType.sans(12, color: c.muted)),
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
            value: Text.rich(TextSpan(children: [
              TextSpan(text: onTime == null ? '–' : '${(onTime * 100).round()}', style: big),
              if (onTime != null) TextSpan(text: '%', style: big.copyWith(fontSize: 20)),
            ])),
          ),
          const SizedBox(width: 10),
          _StatTile(
            label: l.meAdhkarStreak,
            caption: l.meMorningEvening,
            value: Text.rich(TextSpan(children: [
              TextSpan(text: '$adhkar ', style: big),
              TextSpan(text: l.meDays, style: WaqtType.sans(16, weight: 500, color: c.muted)),
            ])),
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
              Expanded(child: Text(l.meConsistency, style: WaqtType.sans(15, weight: 600, color: c.ink))),
              Text(l.monthStandalone(monthKey(today)), style: WaqtType.sans(13, color: c.muted)),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasData)
            Text(l.meNoPrayerData, style: WaqtType.sans(14, color: c.muted, height: 1.45))
          else ...[
            for (final p in Prayer.values) ...[
              _ConsistencyBar(
                name: l.prayer(p),
                value: cons[p],
                weak: p == weak && !allStrong,
              ),
              if (p != Prayer.isha) const SizedBox(height: 12),
            ],
            if (weak != null && !allStrong) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: c.brassSoft, borderRadius: BorderRadius.circular(16)),
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '$tipTitle ', style: WaqtType.sans(13, weight: 700, color: c.brassText, height: 1.5)),
                    TextSpan(text: tipBody, style: WaqtType.sans(13, color: c.brassText, height: 1.5)),
                  ]),
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
            child: Text(name, style: WaqtType.sans(14, weight: 600, color: weak ? c.brassText : c.ink)),
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
                    decoration: BoxDecoration(
                      color: weak ? c.brass : c.accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            child: Text(
              pct == null ? '–' : '$pct%',
              textAlign: TextAlign.right,
              style: WaqtType.sans(13, weight: 600, color: weak ? c.brassText : c.muted),
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
            value: Text.rich(TextSpan(children: [
              TextSpan(text: '${formatMinor(sum.sadaqaMinor)} ', style: big),
              TextSpan(text: currency, style: WaqtType.sans(13, weight: 600, color: c.muted)),
            ])),
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
    final currency = ref.watch(settingsProvider.select((s) => s.currency));
    final today = ref.watch(todayKeyProvider).date;
    Color color(ExpenseCategory k) => switch (k) {
          ExpenseCategory.groceries => c.primary,
          ExpenseCategory.food => c.spendFood(),
          ExpenseCategory.bills => c.spendBills(),
          ExpenseCategory.transport => c.spendTransport(),
          ExpenseCategory.other => c.hairline,
          ExpenseCategory.sadaqa => c.brass,
        };
    final cats = sum.byCategory.entries.where((e) => e.key != ExpenseCategory.sadaqa).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sum.sadaqaMinor > 0) cats.add(MapEntry(ExpenseCategory.sadaqa, sum.sadaqaMinor));

    return WaqtCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(l.meSpending, style: WaqtType.sans(15, weight: 600, color: c.ink))),
              Text(l.monthStandalone(monthKey(today)), style: WaqtType.sans(13, color: c.muted)),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(TextSpan(children: [
            TextSpan(text: '${formatMinor(sum.totalMinor)} ', style: WaqtType.serif(40, tracking: -0.03, color: c.ink)),
            TextSpan(text: currency, style: WaqtType.sans(14, weight: 600, color: c.muted)),
          ])),
          if (cats.isEmpty) ...[
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
                          decoration: BoxDecoration(color: color(cats[i].key), borderRadius: BorderRadius.circular(3)),
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
                            decoration: BoxDecoration(color: color(e.key), borderRadius: BorderRadius.circular(2)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(l.category(e.key), style: WaqtType.sans(13, color: c.muted)),
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

