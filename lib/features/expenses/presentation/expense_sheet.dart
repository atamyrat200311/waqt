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
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../today/application/today_providers.dart';

Future<void> showExpenseSheet(BuildContext context) =>
    Adaptive.showSheet<void>(context, expand: true, builder: (_) => const ExpenseSheet());

class ExpenseSheet extends ConsumerStatefulWidget {
  const ExpenseSheet({super.key});

  @override
  ConsumerState<ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends ConsumerState<ExpenseSheet> {
  AmountInput _amount = const AmountInput();
  ExpenseCategory _category = ExpenseCategory.groceries;
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
    final repo = ref.read(expenseRepositoryProvider);
    final id = await repo.add(
      amountMinor: _amount.minor,
      currency: ref.read(settingsProvider).currency,
      category: _category,
      occurredAt: occurredAt,
      note: _note.text,
    );
    Haptics.success();
    if (!mounted) return;
    unawaited(Navigator.of(context).maybePop());
    messenger?.showSnackBar(SnackBar(
      content: Text(l.expenseSaved),
      action: SnackBarAction(label: l.undo, onPressed: () => repo.delete(id)),
    ));
  }

  String _dayLabel(AppLocalizations l) {
    final today = ref.watch(todayKeyProvider);
    final d = _day ?? today;
    if (d == today) return l.today;
    if (d == today.addDays(-1)) return l.yesterday;
    return l.shortWeekdayDate(d.date);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final currency = ref.watch(settingsProvider.select((s) => s.currency));
    final hasToday = (ref.watch(todayExpensesProvider).value ?? const []).isNotEmpty;
    final sadaqa = _category == ExpenseCategory.sadaqa;
    final shown = _amount.display;
    final bottom = MediaQuery.paddingOf(context).bottom;

    final saveLabel = _amount.isZero
        ? l.expenseEnterAmount
        : sadaqa
            ? l.expenseSaveSadaqa(shown, currency)
            : l.expenseSave(shown, currency);

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
                    child: Semantics(
                      header: true,
                      child: Text(l.expenseAdd, style: WaqtType.sans(17, weight: 600, color: c.ink)),
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
                    child: Text(
                      _note.text.isEmpty ? l.expenseAddNote : _note.text,
                      style: WaqtType.sans(14, color: _note.text.isEmpty ? c.muted : c.ink),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cat in ExpenseCategory.values)
                  _CategoryChip(
                    category: cat,
                    selected: cat == _category,
                    onTap: () => setState(() => _category = cat),
                  ),
              ],
            ),
          ),
          _Keypad(onKey: _press),
          const SizedBox(height: 12),
          BigButton(
            label: saveLabel,
            onPressed: _amount.isZero ? null : _save,
            style: sadaqa ? PillStyle.brass : PillStyle.primary,
          ),
        ],
      ),
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
  const _CategoryChip({required this.category, required this.selected, required this.onTap});
  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sq = category == ExpenseCategory.sadaqa;
    final bg = selected ? (sq ? c.brassText : c.primary) : (sq ? c.brassSoft : c.card);
    final fg = selected ? (sq ? c.onBrassText : c.onPrimary) : (sq ? c.brassText : c.ink);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: bg,
        shape: StadiumBorder(
          side: BorderSide(color: selected || sq ? Colors.transparent : c.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (sq) ...[
                    WaqtIcon(WaqtIcons.heart, size: 14, color: selected ? fg : c.brass),
                    const SizedBox(width: 6),
                  ],
                  Text(context.l10n.category(category), style: WaqtType.sans(14, weight: 600, color: fg)),
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
    final items = ref.watch(todayExpensesProvider).value ?? const <Expense>[];
    final loc = ref.watch(prayerEngineProvider).config.location;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: Text(l.expenseTodayList, style: WaqtType.serif(24, color: c.ink)),
          ),
          for (final e in items)
            Dismissible(
              key: ValueKey(e.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                padding: const EdgeInsets.only(right: 20),
                color: c.brassSoft,
                child: WaqtIcon(WaqtIcons.trash, color: c.brassText),
              ),
              onDismissed: (_) {
                final repo = ref.read(expenseRepositoryProvider);
                repo.delete(e.id);
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
                  content: Text(l.expenseDeleted),
                  action: SnackBarAction(label: l.undo, onPressed: () => repo.restore(e)),
                ));
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: WaqtIcon(
                  e.category == ExpenseCategory.sadaqa ? WaqtIcons.heart : WaqtIcons.wallet,
                  color: e.category == ExpenseCategory.sadaqa ? c.brass : c.accent,
                ),
                title: Text(l.category(e.category), style: WaqtType.sans(16, weight: 600, color: c.ink)),
                subtitle: Text(
                  [hhmm(tz.TZDateTime.from(e.occurredAt, loc)), if (e.note != null) e.note!].join(' · '),
                  style: WaqtType.sans(13, color: c.muted),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${formatMinor(e.amountMinor)} ${e.currency}', style: WaqtType.sans(15, weight: 600, color: c.ink)),
                    IconButton(
                      tooltip: l.delete,
                      icon: WaqtIcon(WaqtIcons.trash, size: 20, color: c.muted),
                      onPressed: () {
                        final repo = ref.read(expenseRepositoryProvider);
                        repo.delete(e.id);
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
                          content: Text(l.expenseDeleted),
                          action: SnackBarAction(label: l.undo, onPressed: () => repo.restore(e)),
                        ));
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
