// Builds assets/quran/mushaf_lines.json.gz: the Madani Mushaf layout (604
// pages, 15 lines each) as lists of words per line.
//
//   dart run tool/build_mushaf.dart
//
// Source: quran.com API v4 `verses/by_page` with word line numbers
// (mushaf=5, KFGQPC Hafs, 604 pages). Format:
//   [ page → [ line → { "n": lineNumber, "w": [ token… ] } ] ]
// token = [text, ayahIndex]            a word
//       | [number, ayahIndex, 1]       the ayah-end number
// Ayah indexes are global 0…6235 (Mushaf order). Waqf signs, which the API
// lists as words of their own, are appended to the preceding word.
// The app never touches the network: run once and commit the result.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient();
  final index = <String, int>{}; // verse_key → global index, by first sight
  final pages = <List<Object?>>[];
  final waqf = RegExp('^[ۖ-ۜ۟-۪ۨ-ۭ ]+\$');
  for (var page = 1; page <= 604; page++) {
    final url = 'https://api.quran.com/api/v4/verses/by_page/$page'
        '?words=true&word_fields=line_number,text_uthmani&per_page=50&mushaf=5';
    Map<String, Object?>? json;
    for (var attempt = 1; json == null; attempt++) {
      try {
        final res = await (await client.getUrl(Uri.parse(url))).close();
        if (res.statusCode != 200) throw HttpException('${res.statusCode}');
        json = jsonDecode(await res.transform(utf8.decoder).join()) as Map<String, Object?>;
      } on Object catch (e) {
        if (attempt >= 5) rethrow;
        print('  retry $page: $e');
        await Future<void>.delayed(Duration(seconds: 2 * attempt));
      }
    }
    final lines = <int, List<List<Object?>>>{};
    for (final v in (json['verses']! as List).cast<Map<String, Object?>>()) {
      final idx = index.putIfAbsent(v['verse_key']! as String, () => index.length);
      for (final w in (v['words']! as List).cast<Map<String, Object?>>()) {
        final n = w['line_number']! as int;
        final text = (w['text_uthmani']! as String);
        final line = lines.putIfAbsent(n, () => []);
        if (w['char_type_name'] == 'end') {
          line.add([text, idx, 1]);
        } else if (waqf.hasMatch(text) && line.isNotEmpty && line.last.length == 2) {
          line.last[0] = '${line.last[0]}$text';
        } else {
          line.add([text, idx]);
        }
      }
    }
    final keys = lines.keys.toList()..sort();
    pages.add([for (final k in keys) {'n': k, 'w': lines[k]}]);
    if (page % 50 == 0) print('page $page ok');
  }
  if (index.length != 6236) throw StateError('expected 6236 ayahs, got ${index.length}');
  File('assets/quran/mushaf_lines.json.gz').writeAsBytesSync(gzip.encode(utf8.encode(jsonEncode(pages))));
  print('wrote assets/quran/mushaf_lines.json.gz');
}
