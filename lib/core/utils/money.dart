/// Money is always integer minor units (1/100). Never floats.
library;

/// Currencies offered in Settings. All have 2 minor digits.
const supportedCurrencies = <String, String>{
  'TMT': 'manat',
  'USD': 'dollar',
  'EUR': 'euro',
  'TRY': 'lira',
  'RUB': 'rubl',
  'UZS': 'soʻm',
  'KZT': 'teňge',
  'KGS': 'som',
  'TJS': 'somoni',
  'AZN': 'manat',
  'GBP': 'pound',
};

const _narrowNbsp = ' ';

/// Formats [minor] units as "4 860" / "45.50" — thousands grouped with a narrow
/// no-break space (as in the design), decimals only when non-zero.
String formatMinor(int minor, {bool alwaysDecimals = false}) {
  final negative = minor < 0;
  final abs = minor.abs();
  final whole = abs ~/ 100;
  final cents = abs % 100;
  final grouped = _group(whole.toString());
  final dec = (cents != 0 || alwaysDecimals) ? '.${cents.toString().padLeft(2, '0')}' : '';
  return '${negative ? '−' : ''}$grouped$dec';
}

String _group(String digits) {
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(_narrowNbsp);
    buf.write(digits[i]);
  }
  return buf.toString();
}

/// Keypad entry model for the expense sheet: digits with at most one '.' and
/// two decimals, max 7 integer digits. Pure so it can be unit tested.
class AmountInput {
  const AmountInput([this.text = '0']);

  final String text;

  static const maxIntegerDigits = 7;

  AmountInput press(String key) {
    var a = text;
    if (key == 'back') {
      a = a.length > 1 ? a.substring(0, a.length - 1) : '0';
    } else if (key == '.') {
      if (!a.contains('.')) a = '$a.';
    } else if (RegExp(r'^\d$').hasMatch(key)) {
      final parts = a.split('.');
      if (parts.length == 2) {
        if (parts[1].length < 2) a = '$a$key';
      } else if (a == '0') {
        a = key;
      } else if (parts[0].length < maxIntegerDigits) {
        a = '$a$key';
      }
    }
    return AmountInput(a);
  }

  /// Minor units (e.g. "45.5" → 4550).
  int get minor {
    final parts = text.split('.');
    final whole = int.tryParse(parts[0]) ?? 0;
    var cents = 0;
    if (parts.length == 2 && parts[1].isNotEmpty) {
      cents = int.parse(parts[1].padRight(2, '0'));
    }
    return whole * 100 + cents;
  }

  /// Display form with grouping; keeps a trailing '.' / partial decimals while typing.
  String get display {
    final parts = text.split('.');
    final grouped = _group(parts[0]);
    return parts.length == 2 ? '$grouped.${parts[1]}' : grouped;
  }

  bool get isZero => minor == 0;
}
