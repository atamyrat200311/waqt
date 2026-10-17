// Builds assets/hadith/daily_rus.json.gz: the "hadith of the day" pool for
// Russian (also used for Turkmen), where neither Nawawi 40 nor Qudsi 40 has a
// translation. Picks short Bukhari hadiths that quote the Prophet ﷺ directly,
// from the already bundled editions (run after tool/build_content.dart).
//
//   dart run tool/build_daily_hadith.dart
//
// Output: {h: [[number, section, russian, arabic], …]}.
import 'dart:convert';
import 'dart:io';

Map<num, List<Object?>> _load(String path) {
  final j = jsonDecode(utf8.decode(gzip.decode(File(path).readAsBytesSync()))) as Map<String, Object?>;
  return {for (final h in (j['h']! as List).cast<List<Object?>>()) h[0]! as num: h};
}

void main() {
  final rus = _load('assets/hadith/bukhari_rus.json.gz');
  final ara = _load('assets/hadith/bukhari_ara.json.gz');
  final opening = RegExp(r'^(Передают со слов|Сообщается со слов) [^«]{0,90}что (Посланник Аллаха|Пророк) ﷺ сказал: «');
  // Fragments ("similar to…"), cross-references, and topics that read harshly
  // out of context on a daily card.
  final skip = RegExp(r'похож|подобн|то же самое|\(см\.|\.\.\.|…|иуде|христиан|убив|убий|прокля|погуби|многобож|неверн|ад[ауе]? |огн|цыган');
  final out = <List<Object?>>[];
  final numbers = rus.keys.toList()..sort();
  for (final n in numbers) {
    final text = (rus[n]![1]! as String).replaceAll('­', '').trim();
    final a = ara[n];
    if (a == null || text.length <= 90 || text.length >= 340) continue;
    if (!opening.hasMatch(text) || skip.hasMatch(text)) continue;
    out.add([n, rus[n]![3], text, a[1]]);
  }
  File('assets/hadith/daily_rus.json.gz').writeAsBytesSync(gzip.encode(utf8.encode(jsonEncode({'h': out}))));
  stdout.writeln('wrote ${out.length} hadiths');
}
