import 'dart:convert';
import 'dart:math' as math;

/// A bundled city (assets/data/cities.json). No geocoding API is used.
class City {
  const City({
    required this.name,
    required this.alt,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.countryCode,
  });

  final String name;

  /// Other spellings for search (local script, Russian, Turkish…).
  final String alt;
  final double latitude;
  final double longitude;
  final String timezone;
  final String countryCode;

  factory City.fromJson(Map<String, Object?> j) => City(
        name: j['name']! as String,
        alt: (j['alt'] as String?) ?? '',
        latitude: (j['lat']! as num).toDouble(),
        longitude: (j['lng']! as num).toDouble(),
        timezone: j['tz']! as String,
        countryCode: (j['cc'] as String?) ?? '',
      );
}

class CityCatalog {
  CityCatalog(this.cities);

  final List<City> cities;

  factory CityCatalog.fromJsonString(String json) {
    final list = (jsonDecode(json) as List).cast<Map<String, Object?>>();
    return CityCatalog(list.map(City.fromJson).toList());
  }

  /// Case- and accent-insensitive prefix/substring search over name + alt names.
  List<City> search(String query, {int limit = 30}) {
    final q = fold(query.trim());
    if (q.isEmpty) return cities.take(limit).toList();
    final starts = <City>[];
    final contains = <City>[];
    for (final c in cities) {
      final hay = fold('${c.name} ${c.alt}');
      final words = hay.split(RegExp(r'\s+'));
      if (words.any((w) => w.startsWith(q))) {
        starts.add(c);
      } else if (hay.contains(q)) {
        contains.add(c);
      }
    }
    return [...starts, ...contains].take(limit).toList();
  }

  /// Nearest bundled city and its distance in km.
  (City, double)? nearest(double lat, double lng) {
    City? best;
    var bestKm = double.infinity;
    for (final c in cities) {
      final d = haversineKm(lat, lng, c.latitude, c.longitude);
      if (d < bestKm) {
        bestKm = d;
        best = c;
      }
    }
    return best == null ? null : (best, bestKm);
  }

  static String fold(String s) {
    const map = {
      'ä': 'a', 'á': 'a', 'â': 'a', 'à': 'a', 'ç': 'c', 'é': 'e', 'è': 'e', 'ê': 'e',
      'ğ': 'g', 'ı': 'i', 'İ': 'i', 'í': 'i', 'î': 'i', 'ň': 'n', 'ñ': 'n', 'ö': 'o',
      'ó': 'o', 'ş': 's', 'ü': 'u', 'ú': 'u', 'û': 'u', 'ý': 'y', 'ž': 'z', 'ə': 'e',
      'ʿ': '', 'ʾ': '', "'": '', '-': ' ',
    };
    final lower = s.toLowerCase();
    final b = StringBuffer();
    for (final ch in lower.split('')) {
      b.write(map[ch] ?? ch);
    }
    return b.toString();
  }
}

/// Great-circle distance in kilometres.
double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLon / 2), 2);
  return 2 * r * math.asin(math.sqrt(a));
}
