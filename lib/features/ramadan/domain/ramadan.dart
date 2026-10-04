import '../../../data/db/enums.dart';
import '../../calendar/domain/hijri_service.dart';

/// Whether Ramadan mode is active on a local date.
/// `auto` follows the (adjusted) Umm al-Qura calendar.
bool isRamadanActive(RamadanMode mode, HijriService hijri, DateTime date) => switch (mode) {
      RamadanMode.on => true,
      RamadanMode.off => false,
      RamadanMode.auto => hijri.isRamadan(date),
    };

/// Day n of Ramadan and its length, or null outside Ramadan (by the calendar).
({int day, int total, DateTime first})? ramadanDay(HijriService hijri, DateTime date) {
  final h = hijri.fromGregorian(date);
  if (!h.isRamadan) return null;
  return (
    day: h.day,
    total: hijri.monthLength(h.year, 9),
    first: hijri.toGregorian(h.year, 9, 1),
  );
}

/// Days until the next 1 Ramadan (0 when today is 1 Ramadan).
int daysUntilRamadan(HijriService hijri, DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  final h = hijri.fromGregorian(d);
  final year = h.month < 9 ? h.year : h.year + 1;
  final start = h.isRamadan ? hijri.toGregorian(h.year, 9, 1) : hijri.toGregorian(year, 9, 1);
  return DateTime.utc(start.year, start.month, start.day)
      .difference(DateTime.utc(d.year, d.month, d.day))
      .inDays;
}
