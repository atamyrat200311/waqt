import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';

/// Month of expenses grouped by day; swipe to delete.
final _monthListProvider = StreamProvider.family<List<Expense>, DateTime>((ref, month) {
  final loc = ref.watch(prayerEngineProvider).config.location;
  return ref
      .watch(expenseRepositoryProvider)
      .watchBetween(tz.TZDateTime(loc, month.year, month.month), tz.TZDateTime(loc, month.year, month.month + 1));
});

class ExpenseHistoryScreen extends ConsumerStatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  ConsumerState<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends ConsumerState<ExpenseHistoryScreen> {
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final today = ref.watch(todayKeyProvider).date;
    final month = DateTime(today.year, today.month + _offset);
    final items = ref.watch(_monthListProvider(month)).value ?? const <Expense>[];
    final currency = ref.watch(settingsProvider.select((s) => s.currency));
    final loc = ref.watch(prayerEngineProvider).config.location;
    final total = items.fold<int>(0, (a, e) => a + e.amountMinor);

    final byDay = <DayKey, List<Expense>>{};
    for (final e in items) {
      final d = DayKey.fromDate(tz.TZDateTime.from(e.occurredAt, loc));
      (byDay[d] ??= []).add(e);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.value.compareTo(a.value));

    return SubScreen(
      title: l.expensesTitle,
      backLabel: l.tabMe,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 8, Gap.screen, 12),
            child: Row(
              children: [
                CircleIconButton(
                  icon: WaqtIcons.chevronLeft,
                  semanticLabel: l.back,
                  onPressed: () => setState(() => _offset--),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('${l.monthName(monthKey(month))} ${month.year}', style: WaqtType.serif(20, weight: 500, color: c.ink)),
                      Text('${formatMinor(total)} $currency', style: WaqtType.sans(14, weight: 600, color: c.muted, tabular: true)),
                    ],
                  ),
                ),
                CircleIconButton(
                  icon: WaqtIcons.chevronRight,
                  semanticLabel: l.next,
                  onPressed: _offset >= 0 ? null : () => setState(() => _offset++),
                ),
              ],
            ),
          ),
        ),
        if (days.isEmpty)
          SliverToBoxAdapter(child: EmptyState(icon: WaqtIcons.wallet, text: l.expensesEmpty))
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
            sliver: SliverList.builder(
              itemCount: days.length,
              itemBuilder: (context, i) {
                final d = days[i];
                final list = byDay[d]!..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
                final dayTotal = list.fold<int>(0, (a, e) => a + e.amountMinor);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                        child: Row(
                          children: [
                            Expanded(child: Kicker(l.shortWeekdayDate(d.date))),
                            Text('${formatMinor(dayTotal)} $currency', style: WaqtType.sans(13, weight: 600, color: c.muted, tabular: true)),
                          ],
                        ),
                      ),
                      WaqtGroup(
                        children: [
                          for (final e in list)
                            Dismissible(
                              key: ValueKey('exp-${e.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: c.dangerSoft,
                                alignment: AlignmentDirectional.centerEnd,
                                padding: const EdgeInsets.only(right: 20),
                                child: WaqtIcon(WaqtIcons.trash, color: c.danger),
                              ),
                              onDismissed: (_) {
                                Haptics.light();
                                ref.read(expenseRepositoryProvider).delete(e.id);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: e.category == ExpenseCategory.sadaqa ? c.brass : c.primary.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(l.category(e.category), style: WaqtType.sans(15.5, weight: 600, color: c.ink)),
                                          Text(
                                            [hhmm(tz.TZDateTime.from(e.occurredAt, loc)), ?e.note].join(' · '),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: WaqtType.sans(13, color: c.muted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${formatMinor(e.amountMinor)} ${e.currency}',
                                      style: WaqtType.sans(15.5, weight: 600, color: c.ink, tabular: true),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
