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
import '../../../data/repositories/income_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import 'expense_sheet.dart';

final _monthExpensesProvider = StreamProvider.family<List<Expense>, DateTime>((ref, month) {
  final loc = ref.watch(prayerEngineProvider).config.location;
  return ref
      .watch(expenseRepositoryProvider)
      .watchBetween(tz.TZDateTime(loc, month.year, month.month), tz.TZDateTime(loc, month.year, month.month + 1));
});

final _monthIncomesProvider = StreamProvider.family<List<Income>, DateTime>((ref, month) {
  final loc = ref.watch(prayerEngineProvider).config.location;
  return ref
      .watch(incomeRepositoryProvider)
      .watchBetween(tz.TZDateTime(loc, month.year, month.month), tz.TZDateTime(loc, month.year, month.month + 1));
});

enum FinanceFilter { all, expenses, income }

sealed class _TransactionItem {
  DateTime get occurredAt;
  int get amountMinor;
  String get currency;
  String? get note;
}

class _ExpenseTxItem extends _TransactionItem {
  _ExpenseTxItem(this.expense);
  final Expense expense;

  @override
  DateTime get occurredAt => expense.occurredAt;
  @override
  int get amountMinor => expense.amountMinor;
  @override
  String get currency => expense.currency;
  @override
  String? get note => expense.note;
}

class _IncomeTxItem extends _TransactionItem {
  _IncomeTxItem(this.income);
  final Income income;

  @override
  DateTime get occurredAt => income.occurredAt;
  @override
  int get amountMinor => income.amountMinor;
  @override
  String get currency => income.currency;
  @override
  String? get note => income.note;
}

class ExpenseHistoryScreen extends ConsumerStatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  ConsumerState<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends ConsumerState<ExpenseHistoryScreen> {
  int _offset = 0;
  FinanceFilter _filter = FinanceFilter.all;

  Color _expenseColor(ExpenseCategory k, WaqtColors c) => switch (k) {
        ExpenseCategory.groceries => c.primary,
        ExpenseCategory.food => c.spendFood(),
        ExpenseCategory.bills => c.spendBills(),
        ExpenseCategory.transport => c.spendTransport(),
        ExpenseCategory.other => c.hairline,
        ExpenseCategory.sadaqa => c.brass,
      };

  Color _incomeColor(IncomeCategory k, WaqtColors c) => switch (k) {
        IncomeCategory.salary => c.primary,
        IncomeCategory.business => const Color(0xFF2E8B57),
        IncomeCategory.gift => c.brass,
        IncomeCategory.investment => const Color(0xFF3B7A57),
        IncomeCategory.other => c.muted,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final today = ref.watch(todayKeyProvider).date;
    final month = DateTime(today.year, today.month + _offset);
    final expenses = ref.watch(_monthExpensesProvider(month)).value ?? const <Expense>[];
    final incomes = ref.watch(_monthIncomesProvider(month)).value ?? const <Income>[];
    final currency = ref.watch(settingsProvider.select((s) => s.currency));
    final loc = ref.watch(prayerEngineProvider).config.location;

    final totalExpense = expenses.fold<int>(0, (a, e) => a + e.amountMinor);
    final totalIncome = incomes.fold<int>(0, (a, i) => a + i.amountMinor);
    final netBalance = totalIncome - totalExpense;

    final allItems = <_TransactionItem>[
      for (final e in expenses) _ExpenseTxItem(e),
      for (final i in incomes) _IncomeTxItem(i),
    ];

    final filteredItems = switch (_filter) {
      FinanceFilter.all => allItems,
      FinanceFilter.expenses => allItems.whereType<_ExpenseTxItem>().toList(),
      FinanceFilter.income => allItems.whereType<_IncomeTxItem>().toList(),
    };

    final byDay = <DayKey, List<_TransactionItem>>{};
    for (final item in filteredItems) {
      final d = DayKey.fromDate(tz.TZDateTime.from(item.occurredAt, loc));
      (byDay[d] ??= []).add(item);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Category breakdown for expenses
    final expSum = ExpenseSummary.of(expenses);
    final expCats = <({String label, int value, Color color})>[
      for (final e in expSum.byCategory.entries)
        if (e.key != ExpenseCategory.sadaqa) (label: l.category(e.key), value: e.value, color: _expenseColor(e.key, c)),
      for (final e in expSum.byCustomCategory.entries) (label: e.key, value: e.value, color: c.accent),
    ]..sort((a, b) => b.value.compareTo(a.value));
    if (expSum.sadaqaMinor > 0) {
      expCats.add((label: l.category(ExpenseCategory.sadaqa), value: expSum.sadaqaMinor, color: c.brass));
    }

    // Source breakdown for incomes
    final incSum = IncomeSummary.of(incomes);
    final incCats = <({String label, int value, Color color})>[
      for (final e in incSum.byCategory.entries)
        (label: l.incomeCategory(e.key), value: e.value, color: _incomeColor(e.key, c)),
      for (final e in incSum.byCustomCategory.entries) (label: e.key, value: e.value, color: c.accent),
    ]..sort((a, b) => b.value.compareTo(a.value));

    return SubScreen(
      title: l.financeTitle,
      backLabel: l.tabMe,
      slivers: [
        // Month navigation
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 4, Gap.screen, 12),
            child: Row(
              children: [
                CircleIconButton(
                  icon: WaqtIcons.chevronLeft,
                  semanticLabel: l.back,
                  onPressed: () => setState(() => _offset--),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${l.monthName(monthKey(month))} ${month.year}',
                      style: WaqtType.serif(20, weight: 500, color: c.ink),
                    ),
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

        // Financial Overview Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
            child: WaqtCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(l.netBalance, style: WaqtType.sans(13.5, weight: 600, color: c.muted)),
                      ),
                      Text(l.monthStandalone(monthKey(month)), style: WaqtType.sans(12.5, color: c.muted)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${netBalance >= 0 ? '+' : ''}${formatMinor(netBalance)} ',
                        style: WaqtType.serif(36, tracking: -0.03, color: netBalance < 0 ? c.danger : c.ink),
                      ),
                      Text(currency, style: WaqtType.sans(15, weight: 600, color: c.muted)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: c.hairline),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.mint,
                              ),
                              child: Center(child: WaqtIcon(WaqtIcons.arrowUpRight, size: 16, color: c.primary)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.totalIncome, style: WaqtType.sans(12, color: c.muted)),
                                  Text(
                                    '+${formatMinor(totalIncome)} $currency',
                                    style: WaqtType.sans(14, weight: 600, color: c.primary, tabular: true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 32, color: c.hairline),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.fill,
                              ),
                              child: Center(child: WaqtIcon(WaqtIcons.arrowDownLeft, size: 16, color: c.ink)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.totalExpense, style: WaqtType.sans(12, color: c.muted)),
                                  Text(
                                    '-${formatMinor(totalExpense)} $currency',
                                    style: WaqtType.sans(14, weight: 600, color: c.ink, tabular: true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Quick add buttons
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 12),
            child: Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: l.homeAddExpense,
                    icon: WaqtIcons.plus,
                    style: PillStyle.fill,
                    height: 40,
                    fontSize: 13.5,
                    onPressed: () => showExpenseSheet(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PillButton(
                    label: l.incomeAdd,
                    icon: WaqtIcons.arrowUpRight,
                    style: PillStyle.mint,
                    height: 40,
                    fontSize: 13.5,
                    onPressed: () => showIncomeSheet(context),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Filter Bar (All / Expenses / Income)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.screen, 0, Gap.screen, 12),
            child: Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: c.fill,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _FilterTab(
                      label: '${l.filterAll} (${allItems.length})',
                      selected: _filter == FinanceFilter.all,
                      onTap: () => setState(() => _filter = FinanceFilter.all),
                    ),
                  ),
                  Expanded(
                    child: _FilterTab(
                      label: '${l.filterExpenses} (${expenses.length})',
                      selected: _filter == FinanceFilter.expenses,
                      onTap: () => setState(() => _filter = FinanceFilter.expenses),
                    ),
                  ),
                  Expanded(
                    child: _FilterTab(
                      label: '${l.filterIncome} (${incomes.length})',
                      selected: _filter == FinanceFilter.income,
                      onTap: () => setState(() => _filter = FinanceFilter.income),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Category breakdown bar when on Expenses or Income tab
        if (_filter == FinanceFilter.expenses && expCats.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.screen, 0, Gap.screen, 14),
              child: _BreakdownBar(cats: expCats, totalMinor: totalExpense),
            ),
          )
        else if (_filter == FinanceFilter.income && incCats.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.screen, 0, Gap.screen, 14),
              child: _BreakdownBar(cats: incCats, totalMinor: totalIncome),
            ),
          ),

        // Transactions list or empty state
        if (days.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: WaqtIcons.wallet,
              text: _filter == FinanceFilter.income
                  ? l.incomeEmpty
                  : _filter == FinanceFilter.expenses
                      ? l.expensesEmpty
                      : l.noTransactions,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.screen),
            sliver: SliverList.builder(
              itemCount: days.length,
              itemBuilder: (context, i) {
                final d = days[i];
                final list = byDay[d]!..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
                final dayIncome = list.whereType<_IncomeTxItem>().fold<int>(0, (a, e) => a + e.amountMinor);
                final dayExpense = list.whereType<_ExpenseTxItem>().fold<int>(0, (a, e) => a + e.amountMinor);
                final dayNet = dayIncome - dayExpense;

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
                            if (_filter == FinanceFilter.all)
                              Text(
                                '${dayNet >= 0 ? '+' : ''}${formatMinor(dayNet)} $currency',
                                style: WaqtType.sans(13, weight: 600, color: dayNet < 0 ? c.muted : c.primary, tabular: true),
                              )
                            else if (_filter == FinanceFilter.expenses)
                              Text(
                                '-${formatMinor(dayExpense)} $currency',
                                style: WaqtType.sans(13, weight: 600, color: c.muted, tabular: true),
                              )
                            else
                              Text(
                                '+${formatMinor(dayIncome)} $currency',
                                style: WaqtType.sans(13, weight: 600, color: c.primary, tabular: true),
                              ),
                          ],
                        ),
                      ),
                      WaqtGroup(
                        children: [
                          for (final item in list)
                            if (item is _ExpenseTxItem)
                              Dismissible(
                                key: ValueKey('exp-${item.expense.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: c.dangerSoft,
                                  alignment: AlignmentDirectional.centerEnd,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: WaqtIcon(WaqtIcons.trash, color: c.danger),
                                ),
                                onDismissed: (_) {
                                  Haptics.light();
                                  final repo = ref.read(expenseRepositoryProvider);
                                  repo.delete(item.expense.id);
                                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                                    SnackBar(
                                      content: Text(l.expenseDeleted),
                                      action: SnackBarAction(label: l.undo, onPressed: () => repo.restore(item.expense)),
                                    ),
                                  );
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
                                          color: item.expense.category == ExpenseCategory.sadaqa
                                              ? c.brass
                                              : _expenseColor(item.expense.category, c),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.expense.customCategory ?? l.category(item.expense.category),
                                              style: WaqtType.sans(15.5, weight: 600, color: c.ink),
                                            ),
                                            Text(
                                              [hhmm(tz.TZDateTime.from(item.occurredAt, loc)), ?item.note].join(' · '),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: WaqtType.sans(13, color: c.muted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '-${formatMinor(item.amountMinor)} ${item.currency}',
                                        style: WaqtType.sans(15.5, weight: 600, color: c.ink, tabular: true),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else if (item is _IncomeTxItem)
                              Dismissible(
                                key: ValueKey('inc-${item.income.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: c.dangerSoft,
                                  alignment: AlignmentDirectional.centerEnd,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: WaqtIcon(WaqtIcons.trash, color: c.danger),
                                ),
                                onDismissed: (_) {
                                  Haptics.light();
                                  final repo = ref.read(incomeRepositoryProvider);
                                  repo.delete(item.income.id);
                                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                                    SnackBar(
                                      content: Text(l.incomeDeleted),
                                      action: SnackBarAction(label: l.undo, onPressed: () => repo.restore(item.income)),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: c.mint,
                                        ),
                                        child: Center(
                                          child: WaqtIcon(WaqtIcons.arrowUpRight, size: 12, color: c.primary),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.income.customCategory ?? l.incomeCategory(item.income.category),
                                              style: WaqtType.sans(15.5, weight: 600, color: c.ink),
                                            ),
                                            Text(
                                              [hhmm(tz.TZDateTime.from(item.occurredAt, loc)), ?item.note].join(' · '),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: WaqtType.sans(13, color: c.muted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '+${formatMinor(item.amountMinor)} ${item.currency}',
                                        style: WaqtType.sans(15.5, weight: 600, color: c.primary, tabular: true),
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

class _FilterTab extends StatelessWidget {
  const _FilterTab({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? c.card : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: WaqtType.sans(12.5, weight: selected ? 600 : 500, color: selected ? c.ink : c.muted),
        ),
      ),
    );
  }
}

class _BreakdownBar extends StatelessWidget {
  const _BreakdownBar({required this.cats, required this.totalMinor});
  final List<({String label, int value, Color color})> cats;
  final int totalMinor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (totalMinor <= 0) return const SizedBox.shrink();

    return WaqtCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  for (var i = 0; i < cats.length; i++) ...[
                    if (i > 0) const SizedBox(width: 3),
                    Expanded(
                      flex: (cats[i].value * 1000 / totalMinor).round().clamp(8, 1000),
                      child: Container(
                        decoration: BoxDecoration(color: cats[i].color, borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) => Wrap(
              runSpacing: 8,
              spacing: 12,
              children: [
                for (final e in cats)
                  SizedBox(
                    width: (box.maxWidth - 12) / 2,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: e.color, borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(e.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: WaqtType.sans(12, color: c.muted)),
                        ),
                        Text(formatMinor(e.value), style: WaqtType.sans(12, weight: 600, color: c.ink)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
