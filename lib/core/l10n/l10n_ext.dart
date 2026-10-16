import 'package:flutter/widgets.dart';

import '../../data/db/enums.dart';
import '../../features/calendar/domain/hijri_service.dart';
import '../utils/dates.dart';
import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

/// Turkmen ordinal with the right vowel harmony: "-njy" after alty (6),
/// dokuz (9), on (10), otuz (30), kyrk (40), altmyş (60), togsan (90);
/// "-nji" otherwise (birinji, ikinji, ýigriminji, ýüzünji…).
String tkOrdinal(int n) {
  final units = n % 10;
  final tens = (n % 100) ~/ 10;
  final back = units != 0 ? (units == 6 || units == 9) : (tens != 0 && const {1, 3, 4, 6, 9}.contains(tens));
  return '$n-${back ? 'njy' : 'nji'}';
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Names for domain enums and formatted dates. Kept here so widgets never
/// switch over enums for strings.
extension L10nNames on AppLocalizations {
  String prayer(Prayer p) => switch (p) {
        Prayer.fajr => prayerFajr,
        Prayer.dhuhr => prayerDhuhr,
        Prayer.asr => prayerAsr,
        Prayer.maghrib => prayerMaghrib,
        Prayer.isha => prayerIsha,
      };

  String category(ExpenseCategory c) => switch (c) {
        ExpenseCategory.groceries => catGroceries,
        ExpenseCategory.transport => catTransport,
        ExpenseCategory.food => catFood,
        ExpenseCategory.bills => catBills,
        ExpenseCategory.sadaqa => catSadaqa,
        ExpenseCategory.other => catOther,
      };

  String window(TaskWindow w) => switch (w) {
        TaskWindow.beforeFajr => winBeforeFajr,
        TaskWindow.afterFajr => winAfterFajr,
        TaskWindow.beforeDhuhr => winBeforeDhuhr,
        TaskWindow.afterDhuhr => winAfterDhuhr,
        TaskWindow.afterAsr => winAfterAsr,
        TaskWindow.afterMaghrib => winAfterMaghrib,
        TaskWindow.afterIsha => winAfterIsha,
        TaskWindow.anytime => winAnytime,
      };

  String adhkarSet(AdhkarSet s) => s == AdhkarSet.morning ? adhkarMorning : adhkarEvening;

  String method(CalcMethod m) => switch (m) {
        CalcMethod.muslimWorldLeague => methodMwl,
        CalcMethod.egyptian => methodEgyptian,
        CalcMethod.karachi => methodKarachi,
        CalcMethod.ummAlQura => methodUmmAlQura,
        CalcMethod.dubai => methodDubai,
        CalcMethod.moonSightingCommittee => methodMoonSighting,
        CalcMethod.northAmerica => methodNorthAmerica,
        CalcMethod.kuwait => methodKuwait,
        CalcMethod.qatar => methodQatar,
        CalcMethod.singapore => methodSingapore,
        CalcMethod.turkey => methodTurkey,
        CalcMethod.tehran => methodTehran,
      };

  String madhabName(AsrMadhab m) => m == AsrMadhab.hanafi ? asrHanafi : asrStandard;

  String alert(AlertType t) => switch (t) {
        AlertType.adhan => alertAdhan,
        AlertType.silent => alertSilent,
        AlertType.off => alertOff,
      };

  String fastType(FastType t) => switch (t) {
        FastType.ramadan => fastTypeRamadan,
        FastType.monThu => fastTypeMonThu,
        FastType.whiteDays => fastTypeWhiteDays,
        FastType.other => fastTypeOther,
        FastType.qada => fastTypeQada,
      };

  String fastStatus(FastStatus s) => switch (s) {
        FastStatus.fasted => fastFasted,
        FastStatus.missed => fastMissed,
        FastStatus.excused => fastExcused,
      };

  String event(IslamicEvent e) => switch (e) {
        IslamicEvent.newYear => evNewYear,
        IslamicEvent.ashura => evAshura,
        IslamicEvent.mawlid => evMawlid,
        IslamicEvent.rajab => evRajab,
        IslamicEvent.miraj => evMiraj,
        IslamicEvent.baraah => evBaraah,
        IslamicEvent.ramadan => evRamadan,
        IslamicEvent.lastTen => evLastTen,
        IslamicEvent.qadr => evQadr,
        IslamicEvent.eidFitr => evEidFitr,
        IslamicEvent.arafah => evArafah,
        IslamicEvent.eidAdha => evEidAdha,
      };

  // ---- dates ----

  /// "Sunday, 4 October" (localized order). Sentence-cased (Russian weekday
  /// names are lower-case on their own).
  String longDate(DateTime d) =>
      _capitalize(dateLong(weekdayName(weekdayKey(d)), _dayOrdinal(d.day), monthName(monthKey(d))));

  /// "4 October".
  String dayMonth(DateTime d) => dateDayMonth(_dayOrdinal(d.day), monthName(monthKey(d)));

  /// Turkmen writes dates as ordinals ("4-nji", "6-njy"); others plain.
  String _dayOrdinal(int day) => localeName == 'tk' ? tkOrdinal(day) : '$day';

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// "Thu 10 Dec".
  String shortWeekdayDate(DateTime d) =>
      dateShortWeekday(weekdayShort(weekdayKey(d)), '${d.day}', monthShort(monthKey(d)));

  String hijriMonthName(int month, {bool long = false}) =>
      long ? hijriMonthLong('m$month') : hijriMonth('m$month');

  /// "22 Rabīʿ II".
  String dayMonthHijri(int day, int month) => dateDayMonth('$day', hijriMonth('m$month'));

  /// "22 Rabīʿ II 1448".
  String hijriFull(int day, int month, int year) =>
      hijriDate('$day', hijriMonth('m$month'), '$year');

  /// "1h 12m" / "12m" — for inline text (not the big hero).
  String duration(Duration d) {
    final totalMin = (d.inSeconds / 60).ceil();
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return h > 0 ? durationHM('$h', '$m') : durationM('$m');
  }

  /// Natural list: "Asr and Isha", "Fajr, Asr and Isha".
  String joinList(List<String> items) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first;
    return listAnd(items.sublist(0, items.length - 1).join(', '), items.last);
  }
}
