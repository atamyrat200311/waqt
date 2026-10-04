import 'dart:math' as math;

import 'package:adhan/adhan.dart' as adhan;
import 'package:timezone/timezone.dart' as tz;

import '../../../data/db/enums.dart';

/// Inputs for a prayer-time calculation. Pure value object.
class PrayerConfig {
  const PrayerConfig({
    required this.latitude,
    required this.longitude,
    required this.location,
    this.method = CalcMethod.muslimWorldLeague,
    this.madhab = AsrMadhab.hanafi,
    this.offsets = const {},
  });

  final double latitude;
  final double longitude;

  /// IANA zone of the place (times are shown in this zone).
  final tz.Location location;
  final CalcMethod method;
  final AsrMadhab madhab;
  final Map<Prayer, int> offsets;
}

/// The five prayers plus sunrise for one local date at the location.
class PrayerDay {
  const PrayerDay({required this.date, required this.times, required this.sunrise});

  /// Local calendar date at the location (time part 00:00).
  final DateTime date;
  final Map<Prayer, tz.TZDateTime> times;
  final tz.TZDateTime sunrise;

  tz.TZDateTime operator [](Prayer p) => times[p]!;
  tz.TZDateTime get fajr => times[Prayer.fajr]!;
  tz.TZDateTime get isha => times[Prayer.isha]!;
}

class NextPrayer {
  const NextPrayer(this.prayer, this.time, {required this.tomorrow});
  final Prayer prayer;
  final tz.TZDateTime time;

  /// True after Isha, when the next prayer is tomorrow's Fajr.
  final bool tomorrow;
}

/// A prayer window that is currently open: Fajr→sunrise, Dhuhr→Asr,
/// Asr→Maghrib, Maghrib→Isha, Isha→next Fajr.
class PrayerWindow {
  const PrayerWindow(this.prayer, this.start, this.end, this.day);
  final Prayer prayer;
  final tz.TZDateTime start;
  final tz.TZDateTime end;

  /// Local date the window belongs to (Isha after midnight belongs to yesterday).
  final DateTime day;

  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);
}

/// Pure prayer-time engine on top of `adhan`. Everything is computed in UTC
/// and converted into the location's zone, so a manually chosen city in a
/// different zone shows that city's wall-clock times.
class PrayerEngine {
  PrayerEngine(this.config);

  final PrayerConfig config;

  final Map<DateTime, PrayerDay> _cache = {};

  adhan.Coordinates get _coords => adhan.Coordinates(config.latitude, config.longitude);

  /// adhan parameters for the configured method/madhab/offsets.
  adhan.CalculationParameters parameters() {
    final p = _method(config.method).getParameters();
    p.madhab = config.madhab == AsrMadhab.hanafi ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
    p.highLatitudeRule = highLatitudeRuleFor(config.latitude);
    p.adjustments = adhan.PrayerAdjustments(
      fajr: config.offsets[Prayer.fajr] ?? 0,
      dhuhr: config.offsets[Prayer.dhuhr] ?? 0,
      asr: config.offsets[Prayer.asr] ?? 0,
      maghrib: config.offsets[Prayer.maghrib] ?? 0,
      isha: config.offsets[Prayer.isha] ?? 0,
    );
    return p;
  }

  /// Same rule as adhan's `HighLatitudeRule.recommended`: above 48° use the
  /// seventh of the night, otherwise middle of the night.
  static adhan.HighLatitudeRule highLatitudeRuleFor(double latitude) => latitude.abs() > 48
      ? adhan.HighLatitudeRule.seventh_of_the_night
      : adhan.HighLatitudeRule.middle_of_the_night;

  /// Times for a local calendar date at the location.
  PrayerDay day(DateTime localDate) {
    final key = DateTime(localDate.year, localDate.month, localDate.day);
    return _cache.putIfAbsent(key, () {
      final pt = adhan.PrayerTimes.utc(
        _coords,
        adhan.DateComponents(key.year, key.month, key.day),
        parameters(),
      );
      tz.TZDateTime z(DateTime utc) => tz.TZDateTime.from(utc, config.location);
      return PrayerDay(
        date: key,
        sunrise: z(pt.sunrise),
        times: {
          Prayer.fajr: z(pt.fajr),
          Prayer.dhuhr: z(pt.dhuhr),
          Prayer.asr: z(pt.asr),
          Prayer.maghrib: z(pt.maghrib),
          Prayer.isha: z(pt.isha),
        },
      );
    });
  }

  /// Local date at the location for an absolute instant.
  DateTime localDate(DateTime now) {
    final l = tz.TZDateTime.from(now, config.location);
    return DateTime(l.year, l.month, l.day);
  }

  tz.TZDateTime localTime(DateTime now) => tz.TZDateTime.from(now, config.location);

  PrayerDay today(DateTime now) => day(localDate(now));

  /// Next prayer strictly after [now]. After Isha → tomorrow's Fajr.
  NextPrayer next(DateTime now) {
    final d = today(now);
    for (final p in Prayer.values) {
      if (d[p].isAfter(now)) return NextPrayer(p, d[p], tomorrow: false);
    }
    final t = day(_addDays(d.date, 1));
    return NextPrayer(Prayer.fajr, t.fajr, tomorrow: true);
  }

  /// The open window at [now], or null between sunrise and Dhuhr.
  PrayerWindow? currentWindow(DateTime now) {
    final d = today(now);
    if (now.isBefore(d.fajr)) {
      // After midnight but before Fajr: still yesterday's Isha window.
      final y = day(_addDays(d.date, -1));
      return PrayerWindow(Prayer.isha, y.isha, d.fajr, y.date);
    }
    final w = windowsFor(d);
    for (final win in w) {
      if (win.contains(now)) return win;
    }
    return null;
  }

  /// All five windows belonging to a day (Isha ends at next day's Fajr).
  List<PrayerWindow> windowsFor(PrayerDay d) {
    final nextFajr = day(_addDays(d.date, 1)).fajr;
    return [
      PrayerWindow(Prayer.fajr, d.fajr, d.sunrise, d.date),
      PrayerWindow(Prayer.dhuhr, d[Prayer.dhuhr], d[Prayer.asr], d.date),
      PrayerWindow(Prayer.asr, d[Prayer.asr], d[Prayer.maghrib], d.date),
      PrayerWindow(Prayer.maghrib, d[Prayer.maghrib], d.isha, d.date),
      PrayerWindow(Prayer.isha, d.isha, nextFajr, d.date),
    ];
  }

  PrayerWindow window(DateTime localDate, Prayer p) =>
      windowsFor(day(localDate)).firstWhere((w) => w.prayer == p);

  /// Position of "now" on the day arc between Fajr (0) and Isha (1).
  static double arcProgress(PrayerDay d, DateTime now) => _fraction(d.fajr, d.isha, now);

  /// Positions of the five prayers on the arc (Fajr 0 … Isha 1).
  static Map<Prayer, double> arcPoints(PrayerDay d) =>
      {for (final p in Prayer.values) p: _fraction(d.fajr, d.isha, d[p])};

  static double _fraction(DateTime a, DateTime b, DateTime t) {
    final total = b.difference(a).inSeconds;
    if (total <= 0) return 0;
    return (t.difference(a).inSeconds / total).clamp(0.0, 1.0);
  }

  /// Point on the design's arc for progress [t] in a [width]×[height] box:
  /// x from 8 to width−8, y = base − amp·sin(πt).
  static ({double x, double y}) arcPoint(double t, double width, double height) {
    const inset = 8.0;
    final base = height - 10;
    final amp = height - 22;
    return (
      x: inset + t * (width - 2 * inset),
      y: base - amp * math.sin(math.pi * t),
    );
  }

  static DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

  static adhan.CalculationMethod _method(CalcMethod m) => switch (m) {
        CalcMethod.muslimWorldLeague => adhan.CalculationMethod.muslim_world_league,
        CalcMethod.egyptian => adhan.CalculationMethod.egyptian,
        CalcMethod.karachi => adhan.CalculationMethod.karachi,
        CalcMethod.ummAlQura => adhan.CalculationMethod.umm_al_qura,
        CalcMethod.dubai => adhan.CalculationMethod.dubai,
        CalcMethod.moonSightingCommittee => adhan.CalculationMethod.moon_sighting_committee,
        CalcMethod.northAmerica => adhan.CalculationMethod.north_america,
        CalcMethod.kuwait => adhan.CalculationMethod.kuwait,
        CalcMethod.qatar => adhan.CalculationMethod.qatar,
        CalcMethod.singapore => adhan.CalculationMethod.singapore,
        CalcMethod.turkey => adhan.CalculationMethod.turkey,
        CalcMethod.tehran => adhan.CalculationMethod.tehran,
      };
}
