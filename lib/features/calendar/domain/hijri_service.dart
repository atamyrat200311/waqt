import 'package:hijri/hijri_calendar.dart';

/// A Hijri (Umm al-Qura) date.
class HijriDate {
  const HijriDate(this.year, this.month, this.day, this.monthLength);
  final int year;
  final int month;
  final int day;
  final int monthLength;

  bool get isWhiteDay => day >= 13 && day <= 15;
  bool get isRamadan => month == 9;

  @override
  bool operator ==(Object other) =>
      other is HijriDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$day/$month/$year';
}

/// Umm al-Qura conversions with the user's −2…+2 day adjustment.
///
/// Adjustment semantics: +1 means "the local Hijri date is one day ahead of
/// Umm al-Qura" (e.g. the month started a day earlier where you live).
class HijriService {
  const HijriService({this.adjustment = 0});

  final int adjustment;

  /// Supported range of the underlying table (1356–1500 AH).
  static final minGregorian = DateTime(1937, 3, 14);
  static final maxGregorian = DateTime(2077, 11, 16);

  HijriDate fromGregorian(DateTime date) {
    final d = DateTime(date.year, date.month, date.day + adjustment);
    final h = HijriCalendar.fromDate(d);
    return HijriDate(h.hYear, h.hMonth, h.hDay, h.lengthOfMonth);
  }

  /// Gregorian date (local, 00:00) for a Hijri date.
  DateTime toGregorian(int year, int month, int day) {
    final g = HijriCalendar().hijriToGregorian(year, month, day);
    return DateTime(g.year, g.month, g.day - adjustment);
  }

  int monthLength(int year, int month) {
    final first = toGregorian(year, month, 1);
    final next = month == 12 ? toGregorian(year + 1, 1, 1) : toGregorian(year, month + 1, 1);
    return DateTime.utc(next.year, next.month, next.day)
        .difference(DateTime.utc(first.year, first.month, first.day))
        .inDays;
  }

  /// Is the given Gregorian day in Ramadan (with adjustment)?
  bool isRamadan(DateTime date) => fromGregorian(date).isRamadan;
}

/// Important Islamic days, defined by Hijri date. Laylat events are the
/// *night before* the listed day (evening of the previous Gregorian day).
enum IslamicEvent {
  newYear(1, 1),
  ashura(1, 10),
  mawlid(3, 12),
  rajab(7, 1),
  miraj(7, 27, night: true),
  baraah(8, 15, night: true),
  ramadan(9, 1),
  lastTen(9, 21, night: true),
  qadr(9, 27, night: true),
  eidFitr(10, 1),
  arafah(12, 9),
  eidAdha(12, 10);

  const IslamicEvent(this.month, this.day, {this.night = false});
  final int month;
  final int day;

  /// Observed on the night before [day] (begins at Maghrib the previous evening).
  final bool night;
}

class UpcomingEvent {
  const UpcomingEvent(this.event, this.hijriYear, this.date, this.daysAway);
  final IslamicEvent event;
  final int hijriYear;

  /// Gregorian day of the event. For night events this is the day *after*
  /// the night; the evening is `date - 1`.
  final DateTime date;
  final int daysAway;

  /// The Gregorian evening when a night event begins.
  DateTime get evening => DateTime(date.year, date.month, date.day - 1);
}

/// Upcoming important days from [today], soonest first. [include] filters
/// which events appear (e.g. the calendar list vs. Home teaser).
List<UpcomingEvent> upcomingEvents(
  HijriService hijri,
  DateTime today, {
  Set<IslamicEvent>? include,
  int limit = 20,
}) {
  final t = DateTime(today.year, today.month, today.day);
  final h = hijri.fromGregorian(t);
  final out = <UpcomingEvent>[];
  for (final year in [h.year, h.year + 1]) {
    for (final e in IslamicEvent.values) {
      if (include != null && !include.contains(e)) continue;
      final g = hijri.toGregorian(year, e.month, e.day);
      // A night event is still "upcoming" on its evening.
      final relevant = e.night ? DateTime(g.year, g.month, g.day - 1) : g;
      final days = DateTime.utc(relevant.year, relevant.month, relevant.day)
          .difference(DateTime.utc(t.year, t.month, t.day))
          .inDays;
      if (days >= 0) out.add(UpcomingEvent(e, year, g, days));
    }
  }
  out.sort((a, b) => a.daysAway.compareTo(b.daysAway));
  return out.take(limit).toList();
}
