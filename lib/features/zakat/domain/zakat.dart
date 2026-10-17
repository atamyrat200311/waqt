import 'package:flutter/foundation.dart';

/// Nisab thresholds (grams) per the majority position.
const goldNisabGrams = 85.0;
const silverNisabGrams = 595.0;
const zakatRate = 0.025;

enum NisabBasis { gold, silver }

/// Everything the user enters. Money in minor units, metals in grams,
/// metal prices in minor units per gram.
@immutable
class ZakatInput {
  const ZakatInput({
    this.cash = 0,
    this.goldGrams = 0,
    this.silverGrams = 0,
    this.goldPrice = 0,
    this.silverPrice = 0,
    this.investments = 0,
    this.business = 0,
    this.receivables = 0,
    this.debts = 0,
    this.basis = NisabBasis.silver,
  });

  final int cash;
  final double goldGrams;
  final double silverGrams;
  final int goldPrice;
  final int silverPrice;
  final int investments;
  final int business;
  final int receivables;
  final int debts;
  final NisabBasis basis;

  factory ZakatInput.fromMap(Map<String, num> m) => ZakatInput(
        cash: (m['cash'] ?? 0).toInt(),
        goldGrams: (m['goldGrams'] ?? 0).toDouble(),
        silverGrams: (m['silverGrams'] ?? 0).toDouble(),
        goldPrice: (m['goldPrice'] ?? 0).toInt(),
        silverPrice: (m['silverPrice'] ?? 0).toInt(),
        investments: (m['investments'] ?? 0).toInt(),
        business: (m['business'] ?? 0).toInt(),
        receivables: (m['receivables'] ?? 0).toInt(),
        debts: (m['debts'] ?? 0).toInt(),
        basis: (m['basis'] ?? 1) == 0 ? NisabBasis.gold : NisabBasis.silver,
      );

  Map<String, num> toMap() => {
        'cash': cash,
        'goldGrams': goldGrams,
        'silverGrams': silverGrams,
        'goldPrice': goldPrice,
        'silverPrice': silverPrice,
        'investments': investments,
        'business': business,
        'receivables': receivables,
        'debts': debts,
        'basis': basis == NisabBasis.gold ? 0 : 1,
      };
}

@immutable
class ZakatResult {
  const ZakatResult({required this.wealth, required this.nisab, required this.due});

  /// Net zakatable wealth (minor units, never negative).
  final int wealth;

  /// Nisab threshold in money, or null when the metal price is unknown.
  final int? nisab;

  /// Zakat due (minor units); 0 below nisab.
  final int due;

  bool get aboveNisab => nisab != null && wealth >= nisab!;
}

ZakatResult computeZakat(ZakatInput i) {
  final metals = (i.goldGrams * i.goldPrice).round() + (i.silverGrams * i.silverPrice).round();
  final gross = i.cash + metals + i.investments + i.business + i.receivables;
  final wealth = (gross - i.debts).clamp(0, 1 << 52);
  final price = i.basis == NisabBasis.gold ? i.goldPrice : i.silverPrice;
  final grams = i.basis == NisabBasis.gold ? goldNisabGrams : silverNisabGrams;
  final nisab = price > 0 ? (grams * price).round() : null;
  final due = nisab != null && wealth >= nisab ? (wealth * zakatRate).round() : 0;
  return ZakatResult(wealth: wealth, nisab: nisab, due: due);
}
