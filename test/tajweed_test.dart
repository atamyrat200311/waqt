import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/features/quran/domain/tajweed.dart';

void main() {
  test('parseTajweed splits marked and plain runs', () {
    final runs = parseTajweed('ab<tajweed class=ghunnah>cd</tajweed>ef');
    expect(runs, [
      (text: 'ab', rule: null),
      (text: 'cd', rule: 'ghunnah'),
      (text: 'ef', rule: null),
    ]);
    expect(runs.map((r) => r.text).join(), 'abcdef');
  });

  test('plain text stays one run', () {
    expect(parseTajweed('abc'), [(text: 'abc', rule: null)]);
    expect(parseTajweed(''), isEmpty);
  });
}
