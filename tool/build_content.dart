// Builds the offline Quran and Hadith content bundled with the app.
//
//   dart run tool/build_content.dart
//
// Downloads from the fawazahmed0 quran-api / hadith-api datasets on GitHub
// (Unlicense; texts originally from Tanzil, the King Fahd Complex, quranenc
// and sunnah.com) and writes:
//
//   assets/quran/ar.json.gz           6236 Uthmani (Hafs) ayahs, Mushaf order
//   assets/quran/ar_search.json.gz    6236 simple-spelling (imlaʾi) ayahs for search
//   assets/quran/translit.json.gz     6236 transliterations
//   assets/quran/<id>.json.gz         6236 ayahs per translation (see _translations)
//   assets/hadith/<book>_<lang>.json.gz
//   lib/features/quran/domain/quran_index_data.dart  (surah/juz/page/hizb/sajda index)
//
// The app never touches the network: run this once when the data should be
// refreshed and commit the results.
// ignore_for_file: avoid_print, strict_raw_type, prefer_collection_literals
import 'dart:convert';
import 'dart:io';

const _quranBase = 'https://raw.githubusercontent.com/fawazahmed0/quran-api/1';
const _hadithBase = 'https://raw.githubusercontent.com/fawazahmed0/hadith-api/1';

/// Translation id → source edition. Ids are stable (stored in settings).
const _translations = {
  'en_sahih': 'eng-ummmuhammad', // Saheeh International
  'ru_kuliev': 'rus-elmirkuliev',
  'tr_diyanet': 'tur-diyanetisleri',
  'uz_mansour': 'uzb-alauddinmansour',
  'kk_altai': 'kaz-khalifahaltai',
  'ky_hakimov': 'kir-shamsaldinhakim',
  'tg_arifi': 'tgk-wwwislamhouseco',
  'az_musayev': 'aze-alikhanmusayev',
};

/// Hadith book → languages bundled.
const _hadith = {
  'nawawi': ['ara', 'eng', 'tur'],
  'qudsi': ['ara', 'eng'],
  'bukhari': ['ara', 'eng', 'rus', 'tur'],
  'muslim': ['ara', 'eng', 'rus', 'tur'],
};

final _client = HttpClient()..findProxy = HttpClient.findProxyFromEnvironment;

Future<Object?> _getJson(String url) async {
  for (var attempt = 1;; attempt++) {
    try {
      final req = await _client.getUrl(Uri.parse(url));
      final res = await req.close();
      if (res.statusCode != 200) throw HttpException('${res.statusCode} for $url');
      return jsonDecode(await res.transform(utf8.decoder).join());
    } on Object catch (e) {
      if (attempt >= 4) rethrow;
      print('  retry $attempt: $e');
      await Future<void>.delayed(Duration(seconds: 2 << attempt));
    }
  }
}

void _writeGz(String path, Object data) {
  final bytes = gzip.encode(utf8.encode(jsonEncode(data)));
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
  print('  wrote $path (${(bytes.length / 1024).round()} KB)');
}

String _clean(String s) => s
    .replaceAll(r'\n', '\n')
    .replaceAll('\r', '')
    .replaceAll(RegExp(r'[ \t]+\n'), '\n')
    .replaceAll(RegExp(r'\n{3,}'), '\n\n')
    .trim();

Future<List<String>> _quranEdition(String edition) async {
  final j = await _getJson('$_quranBase/editions/$edition.min.json') as Map;
  final verses = (j['quran'] as List).cast<Map>();
  if (verses.length != 6236) throw StateError('$edition has ${verses.length} ayahs');
  return [for (final v in verses) _clean(v['text'] as String)];
}

/// The KFGQPC text separates an open tanween from a following alif / alif
/// maqsura with a space (needed by their font), which breaks letter joining
/// and search in standard fonts. Also drops stray RLM marks.
final _tanweenSplit = RegExp('([\u08F0-\u08F2]) ([\u0627\u0649\u064A][\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]*)(?=\\s|\$)');

String _fixUthmani(String s) =>
    s.replaceAllMapped(_tanweenSplit, (m) => '${m[1]}${m[2]}').replaceAll('\u200F', '').trim();

Future<void> _buildQuran() async {
  print('Quran text');
  final uthmani = [for (final a in await _quranEdition('ara-quranuthmanihaf')) _fixUthmani(a)];
  _writeGz('assets/quran/ar.json.gz', uthmani);

  // Simple spelling for search; Tanzil prefixes the basmala to each surah's
  // first ayah, which is not part of the ayah (except Al-Fatihah 1:1).
  final simple = await _quranEdition('ara-quransimple');
  final basmala = simple.first;
  final info0 = await _getJson('$_quranBase/info.json') as Map;
  var at = 0;
  for (final c in (info0['chapters'] as List).cast<Map>()) {
    final n = c['chapter'] as int;
    if (n != 1 && simple[at].startsWith('$basmala ')) simple[at] = simple[at].substring(basmala.length + 1);
    at += (c['verses'] as List).length;
  }
  _writeGz('assets/quran/ar_search.json.gz', simple);
  _writeGz('assets/quran/translit.json.gz', await _quranEdition('ara-quran-la1'));
  for (final e in _translations.entries) {
    _writeGz('assets/quran/${e.key}.json.gz', await _quranEdition(e.value));
  }

  print('Quran index');
  final info = await _getJson('$_quranBase/info.json') as Map;
  final chapters = (info['chapters'] as List).cast<Map>();
  final counts = [for (final c in chapters) (c['verses'] as List).length];
  final starts = <int>[];
  var acc = 0;
  for (final n in counts) {
    starts.add(acc);
    acc += n;
  }
  int index(Map ref) => starts[(ref['chapter'] as int) - 1] + (ref['verse'] as int) - 1;
  List<int> startsOf(String key) => [
        for (final r in ((info[key] as Map)['references'] as List).cast<Map>()) index(r['start'] as Map),
      ];

  final arabicNames = [
    for (final c in chapters)
      (c['arabicname'] as String).replaceFirst(RegExp(r'^سُوْرَةُ\s*'), '').trim(),
  ];
  final medinan = [for (final c in chapters) c['revelation'] != 'Mecca'];
  final sajdas = [
    for (final r in ((info['sajdas'] as Map)['references'] as List).cast<Map>()) index(r),
  ];

  final out = StringBuffer()
    ..writeln('// GENERATED by tool/build_content.dart from fawazahmed0/quran-api info.json.')
    ..writeln('// Do not edit by hand. Ayah positions are global indexes 0…6235 in Mushaf order.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln()
    ..writeln('/// Number of ayahs in each surah (index 0 = Al-Fatihah).')
    ..writeln('const surahAyahCounts = <int>${jsonEncode(counts)};')
    ..writeln()
    ..writeln('/// Global index of each surah\'s first ayah.')
    ..writeln('const surahStarts = <int>${jsonEncode(starts)};')
    ..writeln()
    ..writeln('/// True for Medinan surahs.')
    ..writeln('const surahMedinan = <bool>${jsonEncode(medinan)};')
    ..writeln()
    ..writeln('/// Arabic surah names (without the word سورة).')
    ..writeln('const surahArabicNames = <String>${jsonEncode(arabicNames)};')
    ..writeln()
    ..writeln('/// First ayah of each of the 30 juz.')
    ..writeln('const juzStarts = <int>${jsonEncode(startsOf('juzs'))};')
    ..writeln()
    ..writeln('/// First ayah of each of the 604 Madani Mushaf pages.')
    ..writeln('const pageStarts = <int>${jsonEncode(startsOf('pages'))};')
    ..writeln()
    ..writeln('/// First ayah of each of the 240 hizb quarters (rubʿ al-hizb).')
    ..writeln('const rubStarts = <int>${jsonEncode(startsOf('maqras'))};')
    ..writeln()
    ..writeln('/// Ayahs with a prostration of recitation (sajdah).')
    ..writeln('const sajdaAyahs = <int>${jsonEncode(sajdas)};');
  File('lib/features/quran/domain/quran_index_data.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync(out.toString());
  print('  wrote quran_index_data.dart');
}

Future<void> _buildHadith() async {
  for (final book in _hadith.entries) {
    for (final lang in book.value) {
      print('Hadith ${book.key} ($lang)');
      final j = await _getJson('$_hadithBase/editions/$lang-${book.key}.min.json') as Map;
      final meta = j['metadata'] as Map;
      final names = (meta['sections'] as Map).cast<String, Object?>();
      final details = (meta['section_details'] as Map).cast<String, Object?>();
      final sections = <List<Object>>[];
      for (final id in names.keys) {
        final name = (names[id] as String?)?.trim() ?? '';
        final d = details[id] as Map?;
        if (name.isEmpty || d == null) continue;
        sections.add([int.parse(id), name, d['hadithnumber_first'] as num, d['hadithnumber_last'] as num]);
      }
      final hadiths = <List<Object>>[];
      for (final h in (j['hadiths'] as List).cast<Map>()) {
        final text = _clean(h['text'] as String? ?? '');
        if (text.isEmpty) continue;
        final grades = [
          for (final g in (h['grades'] as List? ?? const []).cast<Map>())
            if ((g['grade'] as String?)?.trim().isNotEmpty ?? false) '${g['grade']}'.trim(),
        ].toSet().join(' · ');
        final ref = h['reference'] as Map?;
        hadiths.add([h['hadithnumber'] as num, text, grades, (ref?['book'] as num?) ?? 0]);
      }
      _writeGz('assets/hadith/${book.key}_$lang.json.gz', {'s': sections, 'h': hadiths});
    }
  }
}

Future<void> main(List<String> args) async {
  final only = args.toSet();
  if (only.isEmpty || only.contains('quran')) await _buildQuran();
  if (only.isEmpty || only.contains('hadith')) await _buildHadith();
  _client.close();
}
