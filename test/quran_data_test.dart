import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/features/quran/domain/quran.dart';

List<String> _load(String name) =>
    (jsonDecode(utf8.decode(gzip.decode(File('assets/quran/$name.json.gz').readAsBytesSync()))) as List).cast<String>();

void main() {
  final ar = _load('ar');
  final simple = _load('ar_search');

  test('Uthmani text has no split tanween words or stray RLM marks', () {
    expect(ar, hasLength(totalAyahs));
    final orphan = RegExp('(^|\\s)[\\u0627\\u0649\\u064A][\\u0610-\\u061A\\u064B-\\u065F\\u0670\\u06D6-\\u06ED]*(?=\\s|\$)');
    final bad = [for (var i = 0; i < ar.length; i++) if (orphan.hasMatch(ar[i]) && ar[i].contains('\u08F0')) i];
    expect(bad, isEmpty);
    expect(ar.any((a) => a.contains('\u200F')), isFalse);
    expect(ar[const AyahRef(2, 2).index], contains('هُدࣰى'));
  });

  test('search text has no prefixed basmala except Al-Fatihah 1:1', () {
    expect(simple, hasLength(totalAyahs));
    expect(normalizeArabic(simple[0]), startsWith('بسم'));
    expect(normalizeArabic(simple[const AyahRef(2, 1).index]), 'الم');
    expect(normalizeArabic(simple[const AyahRef(114, 1).index]), startsWith('قل'));
  });

  test('common words are found with ordinary spelling', () {
    final index = [for (final s in simple) normalizeArabic(s)];
    for (final q in ['الصلاة', 'الكتاب', 'السماوات', 'ابراهيم', 'يؤمنون', 'هدى للمتقين', 'يا ايها الذين امنوا']) {
      expect(searchAyahs(query: q, arabicNormalized: index), isNotEmpty, reason: q);
    }
  });
}
