import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/platform/adaptive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/utils/money.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/segmented.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../domain/zakat.dart';

/// Offline zakat calculator. Metal prices are typed by the user (no network).
class ZakatScreen extends ConsumerStatefulWidget {
  const ZakatScreen({super.key});

  @override
  ConsumerState<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends ConsumerState<ZakatScreen> {
  late ZakatInput _input = ZakatInput.fromMap(ref.read(settingsProvider).zakat);
  bool _recorded = false;

  void _update(ZakatInput Function(ZakatInput i) f) {
    setState(() {
      _input = f(_input);
      _recorded = false;
    });
    ref.read(settingsProvider.notifier).setZakat(_input.toMap());
  }

  ZakatInput _copy({
    int? cash,
    double? goldGrams,
    double? silverGrams,
    int? goldPrice,
    int? silverPrice,
    int? investments,
    int? business,
    int? receivables,
    int? debts,
    NisabBasis? basis,
  }) =>
      ZakatInput(
        cash: cash ?? _input.cash,
        goldGrams: goldGrams ?? _input.goldGrams,
        silverGrams: silverGrams ?? _input.silverGrams,
        goldPrice: goldPrice ?? _input.goldPrice,
        silverPrice: silverPrice ?? _input.silverPrice,
        investments: investments ?? _input.investments,
        business: business ?? _input.business,
        receivables: receivables ?? _input.receivables,
        debts: debts ?? _input.debts,
        basis: basis ?? _input.basis,
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final currency = ref.watch(settingsProvider.select((s) => s.currency));
    final r = computeZakat(_input);

    Widget money(String label, int value, ValueChanged<int> onChanged, {String? hint}) => _Field(
          label: label,
          suffix: currency,
          hint: hint,
          initial: value == 0 ? '' : formatMinor(value).replaceAll(' ', ''),
          onChanged: (t) => onChanged(parseMinor(t) ?? 0),
        );

    Widget grams(String label, double value, ValueChanged<double> onChanged) => _Field(
          label: label,
          suffix: l.zakatGrams,
          initial: value == 0 ? '' : _g(value),
          onChanged: (t) => onChanged(double.tryParse(t.replaceAll(',', '.').replaceAll(' ', '')) ?? 0),
        );

    return SubScreen(
      title: l.zakatTitle,
      backLabel: l.tabTools,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 12, Gap.screen, 0),
          sliver: SliverList.list(
            children: [
              _ResultCard(result: r, currency: currency, basis: _input.basis),
              const SizedBox(height: 10),
              if (r.due > 0)
                PillButton(
                  label: _recorded ? l.zakatRecorded : l.zakatRecord,
                  icon: _recorded ? WaqtIcons.check : WaqtIcons.heart,
                  style: PillStyle.brassSoft,
                  expand: true,
                  onPressed: _recorded
                      ? null
                      : () async {
                          await ref.read(expenseRepositoryProvider).add(
                                amountMinor: r.due,
                                currency: currency,
                                category: ExpenseCategory.sadaqa,
                                note: l.zakatTitle,
                                occurredAt: DateTime.now(),
                              );
                          Haptics.success();
                          setState(() => _recorded = true);
                        },
                ),
              SectionTitle(l.zakatNisabBasis, padding: const EdgeInsets.fromLTRB(6, 22, 6, 10)),
              Segmented<NisabBasis>(
                value: _input.basis,
                options: [(NisabBasis.silver, l.zakatNisabSilver), (NisabBasis.gold, l.zakatNisabGold)],
                onChanged: (b) => _update((_) => _copy(basis: b)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(l.zakatPriceHint, style: WaqtType.sans(13, color: c.muted, height: 1.4)),
              ),
              const SizedBox(height: 10),
              WaqtGroup(
                children: [
                  money(l.zakatGoldPrice, _input.goldPrice, (v) => _update((_) => _copy(goldPrice: v)), hint: l.zakatPerGram),
                  money(l.zakatSilverPrice, _input.silverPrice, (v) => _update((_) => _copy(silverPrice: v)), hint: l.zakatPerGram),
                ],
              ),
              SectionTitle(l.zakatAssets, padding: const EdgeInsets.fromLTRB(6, 22, 6, 10)),
              WaqtGroup(
                children: [
                  money(l.zakatCash, _input.cash, (v) => _update((_) => _copy(cash: v))),
                  grams(l.zakatGold, _input.goldGrams, (v) => _update((_) => _copy(goldGrams: v))),
                  grams(l.zakatSilver, _input.silverGrams, (v) => _update((_) => _copy(silverGrams: v))),
                  money(l.zakatInvestments, _input.investments, (v) => _update((_) => _copy(investments: v))),
                  money(l.zakatBusiness, _input.business, (v) => _update((_) => _copy(business: v))),
                  money(l.zakatReceivables, _input.receivables, (v) => _update((_) => _copy(receivables: v))),
                ],
              ),
              SectionTitle(l.zakatLiabilities, padding: const EdgeInsets.fromLTRB(6, 22, 6, 10)),
              WaqtGroup(
                children: [money(l.zakatDebts, _input.debts, (v) => _update((_) => _copy(debts: v)))],
              ),
              const SizedBox(height: 14),
              WaqtCard(
                color: c.brassSoft,
                border: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WaqtIcon(WaqtIcons.info, size: 20, color: c.brassText),
                    const SizedBox(width: 10),
                    Expanded(child: Text(l.zakatNote, style: WaqtType.sans(13.5, color: c.brassText, height: 1.45))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _g(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.currency, required this.basis});
  final ZakatResult result;
  final String currency;
  final NisabBasis basis;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final r = result;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(Radii.heroCard(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Kicker(l.zakatDue, color: c.onHeroMuted, size: 12, tracking: 0.09),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(formatMinor(r.due), style: WaqtType.serif(54, weight: 400, height: 1, color: c.onHero)),
                ),
              ),
              const SizedBox(width: 8),
              Text(currency, style: WaqtType.sans(18, weight: 600, color: c.onHeroMuted)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r.nisab == null
                ? l.zakatNeedPrice
                : r.aboveNisab
                    ? l.zakatAbove
                    : l.zakatBelow,
            style: WaqtType.sans(14, color: r.aboveNisab ? c.onHeroAccent : c.onHeroMuted, weight: 600, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _Stat(label: l.zakatWealth, value: '${formatMinor(r.wealth)} $currency')),
              Expanded(child: _Stat(label: l.zakatNisab, value: r.nisab == null ? '—' : '${formatMinor(r.nisab!)} $currency')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: WaqtType.sans(12, color: c.onHeroMuted)),
        const SizedBox(height: 2),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: WaqtType.sans(15, weight: 600, color: c.onHero)),
      ],
    );
  }
}

/// Labelled numeric field inside a group row.
class _Field extends StatefulWidget {
  const _Field({required this.label, required this.suffix, required this.initial, required this.onChanged, this.hint});
  final String label;
  final String suffix;
  final String? hint;
  final String initial;
  final ValueChanged<String> onChanged;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label, style: WaqtType.sans(15, weight: 600, color: c.ink)),
                if (widget.hint != null) Text(widget.hint!, style: WaqtType.sans(12, color: c.muted)),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.end,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]'))],
              onChanged: widget.onChanged,
              style: WaqtType.sans(16, weight: 600, color: c.ink),
              decoration: InputDecoration(
                isDense: true,
                hintText: '0',
                suffixText: widget.suffix,
                suffixStyle: WaqtType.sans(13, color: c.muted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
