import 'package:flutter/widgets.dart';

import '../../data/db/enums.dart';
import '../utils/dates.dart';
import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

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
      };

  String fastStatus(FastStatus s) => switch (s) {
        FastStatus.fasted => fastFasted,
        FastStatus.missed => fastMissed,
        FastStatus.excused => fastExcused,
      };

  // ---- dates ----

  /// "Sunday, 4 October" (localized order).
  String longDate(DateTime d) =>
      dateLong(weekdayName(weekdayKey(d)), '${d.day}', monthName(monthKey(d)));

  /// "4 October".
  String dayMonth(DateTime d) => dateDayMonth('${d.day}', monthName(monthKey(d)));

  /// "Thu 10 Dec".
  String shortWeekdayDate(DateTime d) =>
      dateShortWeekday(weekdayShort(weekdayKey(d)), '${d.day}', monthShort(monthKey(d)));

  String hijriMonthName(int month, {bool long = false}) =>
      long ? hijriMonthLong('m$month') : hijriMonth('m$month');

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
