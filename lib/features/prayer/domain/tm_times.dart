import 'tm_times_data.dart';

/// The official Turkmenistan prayer-time table (static, bundled): five cities,
/// one row per calendar day, used instead of astronomical calculation for any
/// location in Turkmenistan.
class TmTable {
  const TmTable._();

  /// Cities in table order (the order of [tmTimesData]).
  static const cities = <(String, double, double)>[
    ('Ashgabat', 37.9601, 58.3261),
    ('Balkanabat', 39.5108, 54.3671),
    ('Daşoguz', 41.8363, 59.9666),
    ('Türkmenabat', 39.0733, 63.5786),
    ('Mary', 37.5936, 61.8303),
  ];

  static const _days = 366;
  static const _periods = 7;

  /// A place in Turkmenistan: its zone is Asia/Ashgabat and it lies inside the
  /// country's bounding box (35.1–42.8° N, 52.4–66.7° E, with a small margin).
  static bool covers({required double latitude, required double longitude, required String timezone}) =>
      timezone == 'Asia/Ashgabat' && latitude >= 34.8 && latitude <= 43.2 && longitude >= 52.0 && longitude <= 67.2;

  /// Index of the table city nearest to the coordinates.
  static int nearestCity(double latitude, double longitude) {
    var best = 0;
    var bestD = double.infinity;
    for (var i = 0; i < cities.length; i++) {
      final (_, lat, lng) = cities[i];
      // Longitude degrees are ~0.78 of latitude degrees at these latitudes.
      final dLat = lat - latitude;
      final dLng = (lng - longitude) * 0.78;
      final d = dLat * dLat + dLng * dLng;
      if (d < bestD) {
        bestD = d;
        best = i;
      }
    }
    return best;
  }

  /// Row of the table for a calendar date: the same day and month every year
  /// (rows follow a leap year, so 29 February has its own row).
  static int dayIndex(DateTime date) =>
      DateTime.utc(2024, date.month, date.day).difference(DateTime.utc(2024)).inDays;

  /// Minutes after local midnight: imsak, fajr, sunrise, dhuhr, asr, maghrib, isha.
  static List<int> minutes(int city, DateTime date) {
    final o = (city * _days + dayIndex(date)) * _periods;
    return tmTimesData.sublist(o, o + _periods);
  }
}
