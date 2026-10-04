import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/utils/money.dart';

void main() {
  const nnbsp = ' ';

  group('formatMinor', () {
    test('drops zero decimals and groups thousands with a narrow space', () {
      expect(formatMinor(4500), '45');
      expect(formatMinor(486000), '4${nnbsp}860');
      expect(formatMinor(123456789), '1${nnbsp}234${nnbsp}567.89');
    });

    test('keeps two decimals when needed', () {
      expect(formatMinor(4550), '45.50');
      expect(formatMinor(5), '0.05');
      expect(formatMinor(4500, alwaysDecimals: true), '45.00');
    });

    test('zero and negatives', () {
      expect(formatMinor(0), '0');
      expect(formatMinor(-2000), '−20');
    });
  });

  group('AmountInput keypad', () {
    AmountInput type(String keys) =>
        keys.split('').fold(const AmountInput(), (a, k) => a.press(k == '<' ? 'back' : k));

    test('builds minor units without floats', () {
      expect(type('45').minor, 4500);
      expect(type('45.5').minor, 4550);
      expect(type('45.05').minor, 4505);
      expect(type('0.1').minor, 10);
    });

    test('max two decimals, one dot, leading zero replaced', () {
      expect(type('1.234').text, '1.23');
      expect(type('1..2').text, '1.2');
      expect(type('007').text, '7');
    });

    test('backspace and length limit', () {
      expect(type('12<').text, '1');
      expect(type('1<<').text, '0');
      expect(type('123456789').text, '1234567');
    });

    test('display groups thousands while typing', () {
      expect(type('12345.').display, '12${nnbsp}345.');
    });
  });
}
