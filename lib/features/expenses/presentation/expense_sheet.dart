import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/income_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../today/application/today_providers.dart';

enum FinanceEntryType { expense, income }

Future<void> showExpenseSheet(BuildContext context, {ExpenseCategory? category}) =>
    Adaptive.showSheet<void>(
      context,
      expand: true,
      builder: (_) => ExpenseSheet(initialCategory: category, initialType: FinanceEntryType.expense),
    );

Future<void> showIncomeSheet(BuildContext context, {IncomeCategory? category}) =>
    Adaptive.showSheet<void>(
      context,
      expand: true,
      builder: (_) => ExpenseSheet(initialIncomeCategory: category, initialType: FinanceEntryType.income),
    );

class ExpenseSheet extends ConsumerStatefulWidget {
  const ExpenseSheet({
    super.key,
    this.initialCategory,
    this.initialIncomeCategory,
    this.initialType = FinanceEntryType.expense,
  });

  final ExpenseCategory? initialCategory;
  final IncomeCategory? initialIncomeCategory;
  final FinanceEntryType initialType;

  @override
  ConsumerState<ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends ConsumerState<ExpenseSheet> {
  AmountInput _amount = const AmountInput();
  late FinanceEntryType _type = widget.initialType;
  late ExpenseCategory _category = widget.initialCategory ?? ExpenseCategory.groceries;
  late IncomeCategory _incomeCategory = widget.initialIncomeCategory ?? IncomeCategory.salary;
  String? _customCategory;
  DayKey? _day;
  final _note = TextEditingController();
  bool _editingNote = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _press(String key) {
    Haptics.tap();
    setState(() => _amount = _amount.press(key));
  }

  Future<void> _pickDate() async {
    final today = ref.read(todayKeyProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: (_day ?? today).date,
      firstDate: today.date.subtract(const Duration(days: 365 * 3)),
      lastDate: today.date,
    );
    if (picked != null) setState(() => _day = DayKey.fromDate(picked));
  }

  Future<void> _save() async {
    if (_amount.isZero) return;
    final l = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final today = ref.read(todayKeyProvider);
    final day = _day ?? today;
    final loc = ref.read(prayerEngineProvider).config.location;
    final now = ref.read(clockProvider)();
    final local = tz.TZDateTime.from(now, loc);
    final occurredAt = day == today
        ? now
        : tz.TZDateTime(loc, day.date.year, day.date.month, day.date.day, local.hour, local.minute);
    final currency = ref.read(settingsProvider).currency;

    if (_type == FinanceEntryType.expense) {
      final repo = ref.read(expenseRepositoryProvider);
      final id = await repo.add(
        amountMinor: _amount.minor,
        currency: currency,
        category: _category,
        customCategory: _customCategory,
        occurredAt: occurredAt,
        note: _note.text,
      );
      Haptics.success();
      if (!mounted) return;
      unawaited(Navigator.of(context).maybePop());
      messenger?.showSnackBar(
        SnackBar(
          content: Text(l.expenseSaved),
          action: SnackBarAction(label: l.undo, onPressed: () => repo.delete(id)),
        ),
      );
    } else {
      final repo = ref.read(incomeRepositoryProvider);
      final id = await repo.add(
        amountMinor: _amount.minor,
        currency: currency,
        category: _incomeCategory,
        customCategory: _customCategory,
        occurredAt: occurredAt,
        note: _note.text,
      );
      Haptics.success();
      if (!mounted) return;
      unawaited(Navigator.of(context).maybePop());
      messenger?.showSnackBar(
        SnackBar(
          content: Text(l.incomeSaved),
          action: SnackBarAction(label: l.undo, onPressed: () => repo.delete(id)),
        ),
      );
    }
  }

  String _dayLabel(AppLocalizations l) {
    final today = ref.watch(todayKeyProvider);
    final d = _day ?? today;
    if (d == today) return l.today;
    if (d == today.addDays(-1)) return l.yesterday;
    return l.shortWeekdayDate(d.date);
  }

  Future<void> _addCategory() async {
    final l = context.l10n;
    final name = await showDialog<String>(context: context, builder: (_) => const _CategoryNameDialog());
    if (!mounted || name == null) return;
    final settings = ref.read(settingsProvider);

    if (_type == FinanceEntryType.expense) {
      final existing = settings.expenseCategories.where((e) => e.toLowerCase() == name.toLowerCase()).firstOrNull;
      final builtIn = ExpenseCategory.values.any((e) => l.category(e).toLowerCase() == name.toLowerCase());
      if (builtIn) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.expenseCategoryExists)));
        return;
      }
      if (existing == null) await ref.read(settingsProvider.notifier).addExpenseCategory(name);
      if (!mounted) return;
      setState(() {
        _category = ExpenseCategory.other;
        _customCategory = existing ?? name;
      });
    } else {
      final existing = settings.incomeCategories.where((e) => e.toLowerCase() == name.toLowerCase()).firstOrNull;
      final builtIn = IncomeCategory.values.any((e) => l.incomeCategory(e).toLowerCase() == name.toLowerCase());
      if (builtIn) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.expenseCategoryExists)));
        return;
      }
      if (existing == null) await ref.read(settingsProvider.notifier).addIncomeCategory(name);
      if (!mounted) return;
      setState(() {
        _incomeCategory = IncomeCategory.other;
        _customCategory = existing ?? name;
      });
    }
  }

  Future<void> _confirmDeleteCategory(String name) async {
    final l = context.l10n;
    final c = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.categoryDelete),
        content: Text(l.categoryDeleteConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: c.danger,
              foregroundColor: Colors.white,
            ),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    if (_type == FinanceEntryType.expense) {
      await ref.read(settingsProvider.notifier).removeExpenseCategory(name);
      if (_customCategory == name) {
        setState(() {
          _customCategory = null;
          _category = ExpenseCategory.food;
        });
      }
    } else {
      await ref.read(settingsProvider.notifier).removeIncomeCategory(name);
      if (_customCategory == name) {
        setState(() {
          _customCategory = null;
          _incomeCategory = IncomeCategory.salary;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final currency = ref.watch(settingsProvider.select((s) => s.currency));
    final customCategories = _type == FinanceEntryType.expense
        ? ref.watch(settingsProvider.select((s) => s.expenseCategories))
        : ref.watch(settingsProvider.select((s) => s.incomeCategories));
    final hasToday = (ref.watch(todayExpensesProvider).value ?? const []).isNotEmpty ||
        (ref.watch(todayIncomesProvider).value ?? const []).isNotEmpty;
    final sadaqa = _type == FinanceEntryType.expense && _customCategory == null && _category == ExpenseCategory.sadaqa;
    final shown = _amount.display;
    final bottom = MediaQuery.paddingOf(context).bottom;

    final saveLabel = _amount.isZero
        ? l.expenseEnterAmount
        : _type == FinanceEntryType.expense
        ? (sadaqa ? l.expenseSaveSadaqa(shown, currency) : l.expenseSave(shown, currency))
        : l.incomeSave(shown, currency);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                CircleIconButton(
                  icon: WaqtIcons.close,
                  iconSize: 20,
                  foreground: c.muted,
                  semanticLabel: l.close,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: c.fill,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _TypeTogglePill(
                              label: l.transactionExpense,
                              selected: _type == FinanceEntryType.expense,
                              onTap: () => setState(() {
                                _type = FinanceEntryType.expense;
                                _customCategory = null;
                              }),
                            ),
                            _TypeTogglePill(
                              label: l.transactionIncome,
                              selected: _type == FinanceEntryType.income,
                              onTap: () => setState(() {
                                _type = FinanceEntryType.income;
                                _customCategory = null;
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasToday)
                  CircleIconButton(
                    icon: WaqtIcons.listCheck,
                    iconSize: 20,
                    size: 36,
                    foreground: c.muted,
                    semanticLabel: l.expenseTodayList,
                    onPressed: () => Adaptive.showSheet<void>(context, builder: (_) => const TodayExpensesSheet()),
                  ),
                _DateChip(label: _dayLabel(l), onTap: _pickDate),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  label: '$shown $currency',
                  liveRegion: true,
                  excludeSemantics: true,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          shown,
                          style: WaqtType.serif(80, weight: 350, tracking: -0.04, height: 1, opsz: 144, color: c.ink),
                        ),
                        const SizedBox(width: 10),
                        const _Caret(),
                        const SizedBox(width: 10),
                        Text(currency, style: WaqtType.sans(18, weight: 600, color: c.muted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_editingNote)
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: _note,
                      autofocus: true,
                      maxLength: 120,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.sentences,
                      style: WaqtType.sans(15, color: c.ink),
                      decoration: InputDecoration(
                        hintText: l.expenseNoteHint,
                        counterText: '',
                        isDense: true,
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => setState(() => _editingNote = false),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => setState(() => _editingNote = true),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _note.text.isEmpty ? l.expenseAddNote : _note.text,
                      style: WaqtType.sans(14, color: _note.text.isEmpty ? c.muted : c.ink),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_type == FinanceEntryType.expense)
                  for (final cat in ExpenseCategory.values)
                    _CategoryChip(
                      label: l.category(cat),
                      sadaqa: cat == ExpenseCategory.sadaqa,
                      selected: _customCategory == null && cat == _category,
                      onTap: () => setState(() {
                        _category = cat;
                        _customCategory = null;
                      }),
                    )
                else
                  for (final cat in IncomeCategory.values)
                    _CategoryChip(
                      label: l.incomeCategory(cat),
                      selected: _customCategory == null && cat == _incomeCategory,
                      onTap: () => setState(() {
                        _incomeCategory = cat;
                        _customCategory = null;
                      }),
                    ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _AddCategoryChip(onTap: _addCategory),
                for (final name in customCategories) ...[
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: name,
                    selected: name == _customCategory,
                    onTap: () => setState(() {
                      if (_type == FinanceEntryType.expense) {
                        _category = ExpenseCategory.other;
                      } else {
                        _incomeCategory = IncomeCategory.other;
                      }
                      _customCategory = name;
                    }),
                    onDelete: () => _confirmDeleteCategory(name),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Keypad(onKey: _press),
          const SizedBox(height: 12),
          BigButton(
            label: saveLabel,
            onPressed: _amount.isZero ? null : _save,
            style: sadaqa
                ? PillStyle.brass
                : _type == FinanceEntryType.income
                ? PillStyle.mint
                : PillStyle.primary,
          ),
        ],
      ),
    );
  }
}

class _TypeTogglePill extends StatelessWidget {
  const _TypeTogglePill({required this.label, required this.selected, required this.onTap});
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
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? c.card : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: WaqtType.sans(13.5, weight: selected ? 600 : 500, color: selected ? c.ink : c.muted),
        ),
      ),
    );
  }
}

class _CategoryNameDialog extends StatefulWidget {
  const _CategoryNameDialog();

  @override
  State<_CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<_CategoryNameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.expenseAddCategory),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 30,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: l.expenseCategoryName),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.cancel)),
        FilledButton(onPressed: _submit, child: Text(l.add)),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: '${context.l10n.pickDate}: $label',
      excludeSemantics: true,
      child: Material(
        color: c.fill,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 32,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: WaqtType.sans(13, weight: 600, color: c.ink)),
                  const SizedBox(width: 4),
                  WaqtIcon(WaqtIcons.chevronDown, size: 14, color: c.ink),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Caret extends StatefulWidget {
  const _Caret();

  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Adaptive.reduceMotion(context)) {
      _c.stop();
      _c.value = 0;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colors.accent;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Opacity(
        opacity: _c.value < 0.5 ? 1 : 0,
        child: Container(width: 2, height: 58, color: color),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.sadaqa = false,
    this.onDelete,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool sadaqa;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sq = sadaqa;
    final bg = selected ? (sq ? c.brassText : c.primary) : (sq ? c.brassSoft : c.card);
    final fg = selected ? (sq ? c.onBrassText : c.onPrimary) : (sq ? c.brassText : c.ink);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: bg,
        shape: StadiumBorder(side: BorderSide(color: selected || sq ? Colors.transparent : c.hairline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onDelete,
          child: Padding(
            padding: EdgeInsets.only(
              left: 14,
              right: onDelete != null ? 8 : 14,
            ),
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (sq) ...[
                    WaqtIcon(WaqtIcons.heart, size: 14, color: selected ? fg : c.brass),
                    const SizedBox(width: 6),
                  ],
                  Text(label, style: WaqtType.sans(14, weight: 600, color: fg)),
                  if (onDelete != null) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onDelete,
                      child: Semantics(
                        button: true,
                        label: '${context.l10n.delete} $label',
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: WaqtIcon(
                            WaqtIcons.close,
                            size: 13,
                            color: selected ? fg.withValues(alpha: 0.8) : c.muted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddCategoryChip extends StatelessWidget {
  const _AddCategoryChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    return Semantics(
      button: true,
      label: l.expenseAddCategory,
      excludeSemantics: true,
      child: Material(
        color: c.fill,
        shape: StadiumBorder(side: BorderSide(color: c.hairline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WaqtIcon(WaqtIcons.plus, size: 15, color: c.accent),
                  const SizedBox(width: 6),
                  Text(l.expenseAddCategory, style: WaqtType.sans(14, weight: 600, color: c.accent)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});
  final ValueChanged<String> onKey;

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'back'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        for (var row = 0; row < 4; row++) ...[
          if (row > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var col = 0; col < 3; col++) ...[
                if (col > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Key(
                    label: _keys[row * 3 + col],
                    isBack: _keys[row * 3 + col] == 'back',
                    color: c.fill,
                    onTap: () => onKey(_keys[row * 3 + col]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.isBack, required this.color, required this.onTap});
  final String label;
  final bool isBack;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: isBack ? MaterialLocalizations.of(context).deleteButtonTooltip : label,
      excludeSemantics: true,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(Radii.bigButton),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Center(
              child: isBack
                  ? WaqtIcon(WaqtIcons.backspace, size: 24, color: c.ink)
                  : Text(label, style: WaqtType.serif(28, color: c.ink)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Today's entries with delete + undo.
class TodayExpensesSheet extends ConsumerWidget {
  const TodayExpensesSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l = context.l10n;
    final expenses = ref.watch(todayExpensesProvider).value ?? const <Expense>[];
    final incomes = ref.watch(todayIncomesProvider).value ?? const <Income>[];
    final loc = ref.watch(prayerEngineProvider).config.location;

    final items = <({bool isIncome, int id, int amountMinor, String currency, String title, String? note, DateTime occurredAt, bool isSadaqa})>[
      for (final e in expenses)
        (
          isIncome: false,
          id: e.id,
          amountMinor: e.amountMinor,
          currency: e.currency,
          title: e.customCategory ?? l.category(e.category),
          note: e.note,
          occurredAt: e.occurredAt,
          isSadaqa: e.category == ExpenseCategory.sadaqa,
        ),
      for (final i in incomes)
        (
          isIncome: true,
          id: i.id,
          amountMinor: i.amountMinor,
          currency: i.currency,
          title: i.customCategory ?? l.incomeCategory(i.category),
          note: i.note,
          occurredAt: i.occurredAt,
          isSadaqa: false,
        ),
    ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: Text(l.expenseTodayList, style: WaqtType.serif(24, color: c.ink)),
          ),
          for (final item in items)
            Dismissible(
              key: ValueKey('${item.isIncome ? 'inc' : 'exp'}-${item.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                padding: const EdgeInsets.only(right: 20),
                color: c.dangerSoft,
                child: WaqtIcon(WaqtIcons.trash, color: c.danger),
              ),
              onDismissed: (_) {
                if (item.isIncome) {
                  final repo = ref.read(incomeRepositoryProvider);
                  repo.delete(item.id);
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(content: Text(l.incomeDeleted)),
                  );
                } else {
                  final repo = ref.read(expenseRepositoryProvider);
                  repo.delete(item.id);
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(content: Text(l.expenseDeleted)),
                  );
                }
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: WaqtIcon(
                  item.isIncome
                      ? WaqtIcons.arrowUpRight
                      : item.isSadaqa
                          ? WaqtIcons.heart
                          : WaqtIcons.wallet,
                  color: item.isIncome
                      ? c.primary
                      : item.isSadaqa
                          ? c.brass
                          : c.accent,
                ),
                title: Text(
                  item.title,
                  style: WaqtType.sans(16, weight: 600, color: c.ink),
                ),
                subtitle: Text(
                  [hhmm(tz.TZDateTime.from(item.occurredAt, loc)), if (item.note != null) item.note!].join(' · '),
                  style: WaqtType.sans(13, color: c.muted),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${item.isIncome ? '+' : '-'}${formatMinor(item.amountMinor)} ${item.currency}',
                      style: WaqtType.sans(15, weight: 600, color: item.isIncome ? c.primary : c.ink, tabular: true),
                    ),
                    IconButton(
                      tooltip: l.delete,
                      icon: WaqtIcon(WaqtIcons.trash, size: 20, color: c.muted),
                      onPressed: () {
                        if (item.isIncome) {
                          ref.read(incomeRepositoryProvider).delete(item.id);
                          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                            SnackBar(content: Text(l.incomeDeleted)),
                          );
                        } else {
                          ref.read(expenseRepositoryProvider).delete(item.id);
                          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                            SnackBar(content: Text(l.expenseDeleted)),
                          );
                        }
                      },
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
