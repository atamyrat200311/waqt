// Builds assets/quran/ar_tajweed.json.gz: the 6236 ayahs of the Quran with
// tajweed rule markup (`<tajweed class=ghunnah>…</tajweed>`), in Mushaf order.
//
//   dart run tool/build_tajweed.dart
//
// Source: quran.com API v4 (`uthmani_tajweed`). The app never touches the
// network: run this once and commit the result.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient();
  final out = <String>[];
  for (var ch = 1; ch <= 114; ch++) {
    final url = 'https://api.quran.com/api/v4/quran/verses/uthmani_tajweed?chapter_number=$ch';
    Map<String, Object?>? json;
    for (var attempt = 1; json == null; attempt++) {
      try {
        final res = await (await client.getUrl(Uri.parse(url))).close();
        if (res.statusCode != 200) throw HttpException('${res.statusCode}');
        json = jsonDecode(await res.transform(utf8.decoder).join()) as Map<String, Object?>;
      } on Object catch (e) {
        if (attempt >= 4) rethrow;
        print('  retry $ch: $e');
        await Future<void>.delayed(Duration(seconds: 2 * attempt));
      }
    }
    for (final v in (json['verses']! as List).cast<Map<String, Object?>>()) {
      var t = v['text_uthmani_tajweed']! as String;
      // Drop the verse-number marker; the app draws its own.
      t = t.replaceAll(RegExp(r'<span class=end>.*?</span>'), '').trim();
      out.add(t);
    }
    print('surah $ch ok (${out.length})');
  }
  if (out.length != 6236) throw StateError('expected 6236 ayahs, got ${out.length}');
  File('assets/quran/ar_tajweed.json.gz').writeAsBytesSync(gzip.encode(utf8.encode(jsonEncode(out))));
  print('wrote assets/quran/ar_tajweed.json.gz');
}
