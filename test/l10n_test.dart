import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/l10n/l10n_ext.dart';

void main() {
  test('Turkmen ordinals follow vowel harmony', () {
    expect(tkOrdinal(1), '1-nji');
    expect(tkOrdinal(4), '4-nji');
    expect(tkOrdinal(6), '6-njy');
    expect(tkOrdinal(9), '9-njy');
    expect(tkOrdinal(10), '10-njy');
    expect(tkOrdinal(16), '16-njy');
    expect(tkOrdinal(20), '20-nji');
    expect(tkOrdinal(29), '29-njy');
    expect(tkOrdinal(30), '30-njy');
    expect(tkOrdinal(31), '31-nji');
  });

  test('dates: Turkmen ordinal, Russian sentence case', () async {
    final tk = await AppLocalizations.delegate.load(const Locale('tk'));
    expect(tk.longDate(DateTime(2026, 10, 6)), startsWith('6-njy oktýabr'));
    final ru = await AppLocalizations.delegate.load(const Locale('ru'));
    expect(ru.longDate(DateTime(2026, 10, 4)), startsWith('Воскресенье'));
  });
}
