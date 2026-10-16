import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/core/utils/money.dart';
import 'package:waqt/data/db/enums.dart';
import 'package:waqt/data/repositories/fast_repository.dart';
import 'package:waqt/features/zakat/domain/zakat.dart';

void main() {
  test('parseMinor accepts comma/dot decimals and spaces', () {
    expect(parseMinor('1 234,5'), 123450);
    expect(parseMinor('1234.50'), 123450);
    expect(parseMinor('7'), 700);
    expect(parseMinor(''), isNull);
    expect(parseMinor('1.234'), isNull);
    expect(parseMinor('abc'), isNull);
  });

  test('no nisab without a metal price', () {
    final r = computeZakat(const ZakatInput(cash: 10000000));
    expect(r.nisab, isNull);
    expect(r.due, 0);
    expect(r.wealth, 10000000);
  });

  test('2.5% is due above the silver nisab', () {
    // Silver 10.00 / g → nisab 5 950.00; wealth 10 000.00 → zakat 250.00.
    final r = computeZakat(const ZakatInput(cash: 1000000, silverPrice: 1000));
    expect(r.nisab, 595000);
    expect(r.aboveNisab, isTrue);
    expect(r.due, 25000);
  });

  test('debts are subtracted and metals valued by weight', () {
    final r = computeZakat(const ZakatInput(
      goldGrams: 100,
      goldPrice: 100000, // 1 000.00 / g
      debts: 2000000,
      basis: NisabBasis.gold,
    ));
    expect(r.wealth, 10000000 - 2000000);
    expect(r.nisab, 8500000);
    expect(r.aboveNisab, isFalse);
    expect(r.due, 0);
  });

  test('input round-trips through the settings map', () {
    const i = ZakatInput(cash: 5, goldGrams: 2.5, silverPrice: 9, basis: NisabBasis.gold);
    final back = ZakatInput.fromMap(i.toMap());
    expect(back.cash, 5);
    expect(back.goldGrams, 2.5);
    expect(back.silverPrice, 9);
    expect(back.basis, NisabBasis.gold);
  });

  test('fasts owed = missed/excused Ramadan days minus make-up fasts', () {
    const d = DayKey('2026-03-01');
    final logs = [
      const FastLog(d, FastType.ramadan, FastStatus.fasted),
      const FastLog(d, FastType.ramadan, FastStatus.missed),
      const FastLog(d, FastType.ramadan, FastStatus.excused),
      const FastLog(d, FastType.ramadan, FastStatus.excused),
      const FastLog(d, FastType.qada, FastStatus.fasted),
      const FastLog(d, FastType.monThu, FastStatus.missed),
    ];
    expect(fastsOwed(logs), 2);
    expect(fastsOwed([...logs, ...List.filled(5, const FastLog(d, FastType.qada, FastStatus.fasted))]), 0);
  });
}
