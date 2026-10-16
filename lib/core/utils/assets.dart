import 'dart:convert';
import 'dart:io' show gzip;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Loads a gzipped JSON asset and decodes it off the UI isolate.
Future<Object?> loadGzJson(String asset) async {
  final data = await rootBundle.load(asset);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  // Small files decode inline; big ones (hadith books) in a background isolate.
  if (bytes.length < 64 * 1024) return _decode(bytes);
  return compute(_decode, bytes);
}

Object? _decode(Uint8List bytes) => jsonDecode(utf8.decode(gzip.decode(bytes)));

/// Loads a gzipped JSON list of strings.
Future<List<String>> loadGzStrings(String asset) async =>
    ((await loadGzJson(asset))! as List).cast<String>();

/// Western digits → Arabic-Indic (١٢٣) for ayah markers.
String arabicDigits(int n) {
  const digits = '٠١٢٣٤٥٦٧٨٩';
  return n.toString().split('').map((d) => digits[int.parse(d)]).join();
}
