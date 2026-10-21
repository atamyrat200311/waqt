import '../../../data/db/enums.dart';
import 'hijri_service.dart';

/// The fast type that best fits [day] (Ramadan > white days > Mon/Thu).
FastType fastTypeFor(HijriService hijri, DateTime day, {required bool ramadan}) {
  final h = hijri.fromGregorian(day);
  if (ramadan || h.isRamadan) return FastType.ramadan;
  if (h.isWhiteDay) return FastType.whiteDays;
  if (day.weekday == DateTime.monday || day.weekday == DateTime.thursday) return FastType.monThu;
  return FastType.other;
}
