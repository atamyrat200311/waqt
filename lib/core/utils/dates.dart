/// Calendar-day helpers. A [DayKey] is a local calendar date stored as
/// `yyyy-MM-dd` text (sortable, range-queryable). See CLAUDE.md conflict #1.
library;

extension type const DayKey(String value) {
  factory DayKey.fromDate(DateTime d) => DayKey(
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}',
      );

  /// Midnight (local, date-only) of this key.
  DateTime get date {
    final p = value.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  DayKey addDays(int days) => DayKey.fromDate(addDaysTo(date, days));

  bool isBefore(DayKey other) => value.compareTo(other.value) < 0;
  bool isAfter(DayKey other) => value.compareTo(other.value) > 0;
}

/// Date-only (no time) for a [DateTime], keeping it local.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Adds calendar days safely across DST (uses the constructor, not Duration).
DateTime addDaysTo(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days, d.hour, d.minute, d.second);

/// Whole calendar days from [a] to [b] (date parts only).
int daysBetween(DateTime a, DateTime b) {
  final ua = DateTime.utc(a.year, a.month, a.day);
  final ub = DateTime.utc(b.year, b.month, b.day);
  return ub.difference(ua).inDays;
}

/// Monday of the week containing [d].
DateTime startOfWeek(DateTime d) => addDaysTo(dateOnly(d), -(d.weekday - 1));

DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month);

DateTime endOfMonthExclusive(DateTime d) => DateTime(d.year, d.month + 1);

/// `HH:mm` (24h — the design uses 24h everywhere).
String hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// Keys used by the l10n select messages.
const weekdayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
const monthKeys = [
  'jan', 'feb', 'mar', 'apr', 'may', 'jun', //
  'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
];

String weekdayKey(DateTime d) => weekdayKeys[d.weekday - 1];
String monthKey(DateTime d) => monthKeys[d.month - 1];
