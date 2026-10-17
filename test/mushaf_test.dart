import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/features/quran/domain/mushaf.dart';

void main() {
  test('isAllahWord recognises the name with and without a prefix', () {
    for (final w in ['ٱللَّهُ', 'ٱللَّهِ', 'بِٱللَّهِ', 'وَٱللَّهُ', 'لِلَّهِ', 'فَٱللَّهُ', 'ٱللَّهَ ۖ']) {
      expect(isAllahWord(w), isTrue, reason: w);
    }
    for (final w in ['ٱللَّهُمَّ', 'إِلَـٰهَ', 'ٱلرَّحْمَـٰنِ', 'رَبِّ', 'ٱلْحَمْدُ']) {
      expect(isAllahWord(w), isFalse, reason: w);
    }
  });

  test('parseMushaf reads words and ayah-end markers', () {
    final pages = parseMushaf([
      [
        {
          'n': 2,
          'w': [
            ['بِسْمِ', 0],
            ['١', 0, 1],
          ],
        },
      ],
    ]);
    expect(pages.single.single.number, 2);
    expect(pages.single.single.words.first.text, 'بِسْمِ');
    expect(pages.single.single.words.last.isEnd, isTrue);
  });
}
