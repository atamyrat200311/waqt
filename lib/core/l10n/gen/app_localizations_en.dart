// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Waqt';

  @override
  String get tabToday => 'Today';

  @override
  String get tabTools => 'Tools';

  @override
  String get tabMe => 'Me';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get continueLabel => 'Continue';

  @override
  String get notNow => 'Not now';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get undo => 'Undo';

  @override
  String get reset => 'Reset';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get pickDate => 'Pick a date';

  @override
  String listAnd(String a, String b) {
    return '$a and $b';
  }

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String weekdayName(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Monday',
      'tue': 'Tuesday',
      'wed': 'Wednesday',
      'thu': 'Thursday',
      'fri': 'Friday',
      'sat': 'Saturday',
      'other': 'Sunday',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'other': 'Sun',
    });
    return '$_temp0';
  }

  @override
  String weekdayInitial(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'M',
      'tue': 'T',
      'wed': 'W',
      'thu': 'T',
      'fri': 'F',
      'sat': 'S',
      'other': 'S',
    });
    return '$_temp0';
  }

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'January',
      'feb': 'February',
      'mar': 'March',
      'apr': 'April',
      'may': 'May',
      'jun': 'June',
      'jul': 'July',
      'aug': 'August',
      'sep': 'September',
      'oct': 'October',
      'nov': 'November',
      'other': 'December',
    });
    return '$_temp0';
  }

  @override
  String monthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'Jan',
      'feb': 'Feb',
      'mar': 'Mar',
      'apr': 'Apr',
      'may': 'May',
      'jun': 'Jun',
      'jul': 'Jul',
      'aug': 'Aug',
      'sep': 'Sep',
      'oct': 'Oct',
      'nov': 'Nov',
      'other': 'Dec',
    });
    return '$_temp0';
  }

  @override
  String monthStandalone(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'January',
      'feb': 'February',
      'mar': 'March',
      'apr': 'April',
      'may': 'May',
      'jun': 'June',
      'jul': 'July',
      'aug': 'August',
      'sep': 'September',
      'oct': 'October',
      'nov': 'November',
      'other': 'December',
    });
    return '$_temp0';
  }

  @override
  String dateLong(String weekday, String day, String month) {
    return '$weekday, $day $month';
  }

  @override
  String dateDayMonth(String day, String month) {
    return '$day $month';
  }

  @override
  String dateShortWeekday(String weekday, String day, String month) {
    return '$weekday $day $month';
  }

  @override
  String hijriMonth(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Muḥarram',
      'm2': 'Ṣafar',
      'm3': 'Rabīʿ I',
      'm4': 'Rabīʿ II',
      'm5': 'Jumādā I',
      'm6': 'Jumādā II',
      'm7': 'Rajab',
      'm8': 'Shaʿbān',
      'm9': 'Ramaḍān',
      'm10': 'Shawwāl',
      'm11': 'Dhū al-Qaʿdah',
      'other': 'Dhū al-Ḥijjah',
    });
    return '$_temp0';
  }

  @override
  String hijriMonthLong(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Muḥarram',
      'm2': 'Ṣafar',
      'm3': 'Rabīʿ al-Awwal',
      'm4': 'Rabīʿ al-Thānī',
      'm5': 'Jumādā al-Ūlā',
      'm6': 'Jumādā al-Ākhirah',
      'm7': 'Rajab',
      'm8': 'Shaʿbān',
      'm9': 'Ramaḍān',
      'm10': 'Shawwāl',
      'm11': 'Dhū al-Qaʿdah',
      'other': 'Dhū al-Ḥijjah',
    });
    return '$_temp0';
  }

  @override
  String hijriDate(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get unitH => 'h';

  @override
  String get unitM => 'm';

  @override
  String get unitS => 's';

  @override
  String durationHM(String h, String m) {
    return '${h}h ${m}m';
  }

  @override
  String durationM(String m) {
    return '${m}m';
  }

  @override
  String minutesShort(String m) {
    return '$m min';
  }

  @override
  String inDuration(String d) {
    return 'in $d';
  }

  @override
  String daysCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String daysUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String eventCountdown(int days, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'in $days days',
      one: 'tomorrow',
      zero: 'today',
    );
    return '$name $_temp0';
  }

  @override
  String get homeNextPrayer => 'Next prayer';

  @override
  String get homeIn => 'in';

  @override
  String get homeInAfter => '';

  @override
  String get homeRamadanKicker => 'Ramadan · Iftar';

  @override
  String get homeIftar => 'Iftar';

  @override
  String homeMaghribAt(String time) {
    return 'Maghrib $time';
  }

  @override
  String homeSuhoorLine(String time, String n, String total) {
    return 'Suhoor ends $time · Fast $n of $total';
  }

  @override
  String homeAfterIshaKicker(String time) {
    return 'After Isha · $time';
  }

  @override
  String get homeYourDay => 'Your day';

  @override
  String get homeUpNext => 'Up next';

  @override
  String get homeStart => 'Start';

  @override
  String get homeMarkDone => 'Done';

  @override
  String homeAdhkarAfter(String window, String min) {
    return '$window · $min min';
  }

  @override
  String get homeTaraweeh => 'Taraweeh';

  @override
  String homeTaraweehSub(String time) {
    return 'At the mosque · reminder $time';
  }

  @override
  String get homeSpentToday => 'Spent today';

  @override
  String homeInclSadaqa(String amount) {
    return 'incl. $amount sadaqa';
  }

  @override
  String get homeTasks => 'Tasks';

  @override
  String homeTasksOf(String total) {
    return 'of $total';
  }

  @override
  String homeQadaRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count qada remaining',
      one: '1 qada remaining',
    );
    return '$_temp0';
  }

  @override
  String get homeMakeUp => 'Make up';

  @override
  String homeUnmarkedTitle(String prayers) {
    return 'You didn\'t mark $prayers yesterday';
  }

  @override
  String get homeUnmarkedBody => 'Nothing is added to qada unless you choose.';

  @override
  String get homeUnmarkedAllPrayed => 'All prayed';

  @override
  String get homeAddExpense => 'Add expense';

  @override
  String get homeSetLocation => 'Set location';

  @override
  String get markClosedAtSunrise => 'closed at sunrise';

  @override
  String markClosedAt(String time) {
    return 'closed at $time';
  }

  @override
  String markLeft(String d) {
    return '$d left';
  }

  @override
  String markOpensAt(String time) {
    return 'opens at $time';
  }

  @override
  String get markOnTime => 'Prayed on time';

  @override
  String markOnTimeSub(String prayer) {
    return 'Within the $prayer window';
  }

  @override
  String get markCongregation => 'In congregation';

  @override
  String get markCongregationSub => 'With the jamāʿah, on time';

  @override
  String get markLate => 'Prayed late';

  @override
  String get markLateSub => 'After the window closed';

  @override
  String get markMissed => 'Missed, add to qada';

  @override
  String get markMissedSub => 'You confirm before anything is added';

  @override
  String get markExcused => 'Excused';

  @override
  String get markExcusedSub => 'Period mode is on — no qada, streak kept';

  @override
  String markConfirmTitle(String prayer) {
    return 'Add 1 $prayer to your qada?';
  }

  @override
  String get markConfirmBody =>
      'You can make it up at any time. Nothing is added until you confirm.';

  @override
  String get markAddToQada => 'Add to qada';

  @override
  String get markAdded => 'Added to qada. Make it up whenever you can.';

  @override
  String get markRemind => 'Remind me in 15 min';

  @override
  String markReminderSet(String time) {
    return 'Reminder set for $time';
  }

  @override
  String get markClear => 'Clear mark';

  @override
  String get markNotStarted => 'This prayer\'s time hasn\'t started yet.';

  @override
  String get qadaTitle => 'Qada';

  @override
  String get qadaLeft => 'prayers left\nto make up';

  @override
  String qadaMadeUpSince(String count) {
    return 'You\'ve made up $count since you started';
  }

  @override
  String get qadaThisWeek => 'This week';

  @override
  String qadaWeekMadeUp(String count) {
    return '$count made up';
  }

  @override
  String get qadaMadeUp => 'Made up';

  @override
  String get qadaAllDone => 'All done';

  @override
  String get qadaAddOlder => 'Add older missed prayers';

  @override
  String get qadaTip =>
      'One at a time is enough. Many people pair one qada with each daily prayer.';

  @override
  String get qadaAddOlderTitle => 'Older missed prayers';

  @override
  String get qadaAddOlderBody =>
      'Enter how many of each prayer you still owe. They are added to your current counts.';

  @override
  String qadaAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count to qada',
      zero: 'Add to qada',
    );
    return '$_temp0';
  }

  @override
  String get qadaEmpty =>
      'No qada recorded. If you have older missed prayers, add them here.';

  @override
  String get expenseAdd => 'Add expense';

  @override
  String get expenseAddNote => 'Add a note';

  @override
  String get expenseNoteHint => 'Note';

  @override
  String get catGroceries => 'Groceries';

  @override
  String get catTransport => 'Transport';

  @override
  String get catFood => 'Food';

  @override
  String get catBills => 'Bills';

  @override
  String get catSadaqa => 'Sadaqa';

  @override
  String get catOther => 'Other';

  @override
  String expenseSave(String amount, String currency) {
    return 'Save $amount $currency';
  }

  @override
  String expenseSaveSadaqa(String amount, String currency) {
    return 'Save $amount $currency as sadaqa';
  }

  @override
  String get expenseEnterAmount => 'Enter an amount';

  @override
  String get expenseSaved => 'Saved';

  @override
  String get expenseTodayList => 'Today\'s entries';

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String tasksDoneOf(String done, String total) {
    return '$done of $total done';
  }

  @override
  String get tasksAddHint => 'Add a task…';

  @override
  String get tasksAddA11y => 'Add task';

  @override
  String get winBeforeFajr => 'Before Fajr';

  @override
  String get winAfterFajr => 'After Fajr';

  @override
  String get winBeforeDhuhr => 'Before Dhuhr';

  @override
  String get winAfterDhuhr => 'After Dhuhr';

  @override
  String get winAfterAsr => 'After Asr';

  @override
  String get winAfterMaghrib => 'After Maghrib';

  @override
  String get winAfterIsha => 'After Isha';

  @override
  String get winAnytime => 'Anytime';

  @override
  String winUntil(String time) {
    return 'until $time';
  }

  @override
  String winFrom(String time) {
    return 'from $time';
  }

  @override
  String winRange(String a, String b) {
    return '$a – $b';
  }

  @override
  String tasksOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unfinished tasks from earlier',
      one: '1 unfinished task from earlier',
    );
    return '$_temp0';
  }

  @override
  String get tasksMoveToday => 'Move to today';

  @override
  String get tasksEmpty =>
      'Nothing planned yet. Add a task to a prayer window.';

  @override
  String get tasksDeleted => 'Task deleted';

  @override
  String get tasksAllDone => 'All done for today';

  @override
  String get adhkarMorning => 'Morning adhkar';

  @override
  String get adhkarEvening => 'Evening adhkar';

  @override
  String adhkarPosOf(String pos, String total) {
    return '$pos of $total';
  }

  @override
  String adhkarRecite(String n) {
    return 'Recite $n×';
  }

  @override
  String get adhkarComplete => 'Complete';

  @override
  String adhkarOf(String n) {
    return '/ $n';
  }

  @override
  String get adhkarNext => 'Next';

  @override
  String get adhkarNextDhikr => 'Next dhikr';

  @override
  String get adhkarFinish => 'Finish';

  @override
  String get adhkarPrev => 'Previous dhikr';

  @override
  String get adhkarTapToCount => 'Tap to count';

  @override
  String get adhkarSetDone => 'May Allah accept it from you.';

  @override
  String get adhkarTranslationNote => 'Translation is approximate.';

  @override
  String get calendarTitle => 'Hijri calendar';

  @override
  String calendarRange(String year, String start, String end) {
    return '$year · $start – $end';
  }

  @override
  String get calendarWhiteDays => 'White days 13–15';

  @override
  String get calendarMonThu => 'Mon & Thu fasts';

  @override
  String get calendarUpcoming => 'Upcoming';

  @override
  String get calendarMoonNote =>
      'Dates may shift by a day depending on the local moon sighting.';

  @override
  String get calendarPrevMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String calendarEveningOf(String date) {
    return 'evening of $date';
  }

  @override
  String get evRajab => 'Rajab begins';

  @override
  String get evMiraj => 'Laylat al-Miʿrāj';

  @override
  String get evBaraah => 'Laylat al-Barāʾah';

  @override
  String get evRamadan => 'Ramadan begins';

  @override
  String get evQadr => 'Laylat al-Qadr';

  @override
  String get evEidFitr => 'Eid al-Fitr';

  @override
  String get evArafah => 'Day of Arafah';

  @override
  String get evEidAdha => 'Eid al-Adha';

  @override
  String get evNewYear => 'Islamic New Year';

  @override
  String get evAshura => 'Ashura';

  @override
  String get evMawlid => 'Mawlid';

  @override
  String get evLastTen => 'Last ten nights begin';

  @override
  String fastLogTitle(String date) {
    return 'Fast · $date';
  }

  @override
  String get fastFasted => 'Fasted';

  @override
  String get fastMissed => 'Missed';

  @override
  String get fastExcused => 'Excused';

  @override
  String get fastClear => 'Clear';

  @override
  String get fastTypeRamadan => 'Ramadan fast';

  @override
  String get fastTypeMonThu => 'Monday/Thursday fast';

  @override
  String get fastTypeWhiteDays => 'White day fast';

  @override
  String get fastTypeOther => 'Voluntary fast';

  @override
  String get ramadanTitle => 'Ramadan';

  @override
  String get ramadanMode => 'Ramadan mode';

  @override
  String get ramadanAuto => 'Automatic';

  @override
  String get ramadanOn => 'On';

  @override
  String get ramadanOff => 'Off';

  @override
  String ramadanInDays(String days) {
    return 'in $days days';
  }

  @override
  String ramadanDayOf(String n, String total) {
    return 'Day $n of $total';
  }

  @override
  String get ramadanSuhoorReminder => 'Suhoor reminder';

  @override
  String ramadanSuhoorBefore(String min) {
    return '$min min before Fajr';
  }

  @override
  String get ramadanIftarReminder => 'Iftar at Maghrib';

  @override
  String get ramadanTaraweehReminder => 'Taraweeh reminder';

  @override
  String get ramadanFasts => 'Fasts this Ramadan';

  @override
  String get ramadanTodayFast => 'Today\'s fast';

  @override
  String get ramadanNotNow => 'Ramadan mode turns on by itself on 1 Ramaḍān.';

  @override
  String get toolsTitle => 'Tools';

  @override
  String get qibla => 'Qibla';

  @override
  String get qiblaTurn => 'Turn until the arrow points up';

  @override
  String get qiblaFacing => 'You\'re facing the Qibla';

  @override
  String get qiblaCalibrate =>
      'Compass needs calibration — move your phone in a figure 8.';

  @override
  String qiblaNoSensor(String deg) {
    return 'This device has no compass. The Qibla is $deg° clockwise from true north.';
  }

  @override
  String qiblaFromNorth(String deg) {
    return '$deg° from north';
  }

  @override
  String qiblaDistance(String km) {
    return '$km km to Makkah';
  }

  @override
  String get qiblaOpen => 'Open compass';

  @override
  String get tasbih => 'Tasbih';

  @override
  String tasbihOf(String n) {
    return 'of $n';
  }

  @override
  String tasbihComplete(String n) {
    return 'Complete · $n';
  }

  @override
  String get tasbihTapAgain => 'Tap to start again';

  @override
  String get tasbihCustom => 'Custom tasbih';

  @override
  String get tasbihPreset => 'After-prayer tasbih (33 · 33 · 34)';

  @override
  String get tasbihPhrase => 'Phrase';

  @override
  String get tasbihGoal => 'Goal';

  @override
  String get tasbihCount => 'Count';

  @override
  String get tasbihTapA11y => 'Count one';

  @override
  String get toolsAdhkar => 'Adhkar';

  @override
  String get toolsMorningDue => 'Morning due';

  @override
  String get toolsEveningDue => 'Evening due';

  @override
  String get toolsAdhkarDone => 'Done today';

  @override
  String get toolsCalendar => 'Hijri calendar';

  @override
  String get toolsRamadan => 'Ramadan';

  @override
  String toolsRamadanNow(String n) {
    return 'Day $n';
  }

  @override
  String get meTitle => 'Me';

  @override
  String get meAll5 => 'All 5 prayers';

  @override
  String meDaysInRow(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'days in a row',
      one: 'day in a row',
    );
    return '$_temp0';
  }

  @override
  String get me2WeeksAgo => '2 weeks ago';

  @override
  String meBest(String n) {
    return 'Best: $n days';
  }

  @override
  String get meOnTime => 'On time';

  @override
  String get meThisMonth => 'this month';

  @override
  String get meAdhkarStreak => 'Adhkar streak';

  @override
  String get meDays => 'days';

  @override
  String get meMorningEvening => 'morning & evening';

  @override
  String get meConsistency => 'Consistency';

  @override
  String get meFasts => 'Fasts this month';

  @override
  String get meFastsNone => 'None logged yet';

  @override
  String meFastMonThu(String n) {
    return '$n Mon/Thu';
  }

  @override
  String meFastWhite(String n) {
    return '$n white days';
  }

  @override
  String meFastRamadan(String n) {
    return '$n Ramadan';
  }

  @override
  String meFastOther(String n) {
    return '$n voluntary';
  }

  @override
  String get meSadaqa => 'Sadaqa';

  @override
  String get meSpending => 'Spending';

  @override
  String get meNoSpending => 'No expenses this month yet.';

  @override
  String get meNoPrayerData =>
      'Mark your prayers on Today to see your consistency here.';

  @override
  String get meSettingsA11y => 'Settings';

  @override
  String get tipFajrTitle => 'Fajr is the quietest.';

  @override
  String get tipFajrBody =>
      'An alarm ten minutes before adhan, with water by the bed, helps many people.';

  @override
  String get tipDhuhrTitle => 'Dhuhr slips at work.';

  @override
  String get tipDhuhrBody =>
      'Block ten minutes in your calendar right after the adhan.';

  @override
  String get tipAsrTitle => 'Asr is easy to miss.';

  @override
  String get tipAsrBody =>
      'Pray as soon as you hear it, before the afternoon errands.';

  @override
  String get tipMaghribTitle => 'Maghrib\'s window is short.';

  @override
  String get tipMaghribBody => 'Pray first, then set the table.';

  @override
  String get tipIshaTitle => 'Isha drifts late.';

  @override
  String get tipIshaBody => 'Pray it before tea and screens, then rest.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get secPrayerTimes => 'Prayer times';

  @override
  String get calcMethod => 'Calculation method';

  @override
  String get asr => 'Asr';

  @override
  String get asrStandard => 'Standard';

  @override
  String get asrHanafi => 'Hanafi';

  @override
  String get matchMosque => 'Match my mosque';

  @override
  String get matchMosqueSub => 'Shift all times to its timetable';

  @override
  String get perPrayerOffsets => 'Adjust each prayer';

  @override
  String offsetMinutes(String value) {
    return '$value min';
  }

  @override
  String get secAlerts => 'Alerts';

  @override
  String get alertAdhan => 'Adhan';

  @override
  String get alertSilent => 'Silent';

  @override
  String get alertOff => 'Off';

  @override
  String get secGeneral => 'General';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get currency => 'Currency';

  @override
  String get location => 'Location';

  @override
  String get periodMode => 'Period mode';

  @override
  String get periodModeSub => 'Pauses prayer alerts. Streaks stay intact.';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeAuto => 'Auto';

  @override
  String get widgets => 'Widgets';

  @override
  String get privacyNote =>
      'No account, no ads. Everything stays on this phone.';

  @override
  String versionLabel(String version) {
    return 'Waqt $version';
  }

  @override
  String get hijriAdjust => 'Hijri date';

  @override
  String get hijriAdjustSub => 'Match your local moon sighting';

  @override
  String get hijriAdjustNone => 'No adjustment';

  @override
  String get adhkarReminders => 'Adhkar reminders';

  @override
  String get adhkarRemindersSub => 'Morning after Fajr, evening after Asr';

  @override
  String get secRamadan => 'Ramadan';

  @override
  String get secNotifications => 'Notifications';

  @override
  String get notifPermissionOff =>
      'Notifications are off for Waqt. Turn them on in system settings.';

  @override
  String get exactAlarmOff =>
      'Exact alarms are off, so alerts may arrive a few minutes late.';

  @override
  String get allowExact => 'Allow exact alarms';

  @override
  String get methodMwl => 'Muslim World League';

  @override
  String get methodEgyptian => 'Egyptian General Authority';

  @override
  String get methodKarachi => 'University of Islamic Sciences, Karachi';

  @override
  String get methodUmmAlQura => 'Umm al-Qura, Makkah';

  @override
  String get methodDubai => 'Dubai';

  @override
  String get methodMoonSighting => 'Moonsighting Committee';

  @override
  String get methodNorthAmerica => 'ISNA (North America)';

  @override
  String get methodKuwait => 'Kuwait';

  @override
  String get methodQatar => 'Qatar';

  @override
  String get methodSingapore => 'Singapore';

  @override
  String get methodTurkey => 'Diyanet (Turkey)';

  @override
  String get methodTehran => 'Tehran';

  @override
  String get widgetsHelpTitle => 'Home-screen widgets';

  @override
  String get widgetsHelpIos =>
      'Touch and hold an empty area of the Home Screen, tap +, search for Waqt and choose the small, medium or lock-screen widget.';

  @override
  String get widgetsHelpAndroid =>
      'Touch and hold an empty area of the home screen, tap Widgets, find Waqt and drag the widget onto the screen. Its button marks the current prayer.';

  @override
  String get widgetsHelpData =>
      'Widgets show the next seven days of times even if you don\'t open the app.';

  @override
  String get widgetNext => 'Next';

  @override
  String widgetWindowOpen(String prayer) {
    return '$prayer · window open';
  }

  @override
  String get widgetMarkPrayed => 'Mark as prayed';

  @override
  String widgetMarked(String prayer) {
    return '$prayer marked';
  }

  @override
  String get locationTitle => 'Location';

  @override
  String get locationUseCurrent => 'Use my location';

  @override
  String get locationSearch => 'Search a city';

  @override
  String get locationCoordinates => 'Enter coordinates';

  @override
  String get locationLatitude => 'Latitude';

  @override
  String get locationLongitude => 'Longitude';

  @override
  String get locationName => 'Place name';

  @override
  String get locationLocating => 'Finding you…';

  @override
  String get locationDenied =>
      'Location permission was denied. Choose a city instead.';

  @override
  String get locationFailed =>
      'Couldn\'t get your location. Choose a city instead.';

  @override
  String locationNearby(String city) {
    return 'Near $city';
  }

  @override
  String get locationInvalid => 'Enter a valid latitude and longitude.';

  @override
  String get locationPrivacy =>
      'Your location is used only to calculate prayer times and the Qibla. It never leaves this phone.';

  @override
  String get obGreeting => 'As-salāmu ʿalaykum';

  @override
  String get obLanguageTitle => 'Choose your language';

  @override
  String get obLanguageSub => 'You can change it later in Settings.';

  @override
  String get obLocationTitle => 'Where do you pray?';

  @override
  String obMethodLine(String method, String madhab) {
    return '$method · $madhab Asr';
  }

  @override
  String get obAdvanced => 'Advanced';

  @override
  String get obNotifTitle => 'Never miss a prayer';

  @override
  String get obNotifBody =>
      'Get a gentle alert at each prayer time. Choose adhan, silent or off for each prayer later.';

  @override
  String get obAllowNotif => 'Allow notifications';

  @override
  String get obNotifAllowed => 'Notifications are on';

  @override
  String get obBatteryTitle => 'Keep alerts on time';

  @override
  String get obBatteryBody =>
      'Some Android phones pause apps to save battery. Set Waqt to \"Unrestricted\" in battery settings so the adhan is never late.';

  @override
  String get obOpenBattery => 'Open battery settings';

  @override
  String get obStart => 'Start';

  @override
  String get obPrivacy => 'No account. No ads. Everything stays on this phone.';

  @override
  String notifPrayerTitle(String prayer, String time) {
    return '$prayer · $time';
  }

  @override
  String notifPrayerBody(String prayer, String place) {
    return 'It\'s time for $prayer in $place.';
  }

  @override
  String notifRemindTitle(String prayer) {
    return 'Reminder · $prayer';
  }

  @override
  String notifRemindBody(String prayer) {
    return 'You asked to be reminded to pray $prayer.';
  }

  @override
  String get notifMorningBody =>
      'A few minutes of remembrance to start the day.';

  @override
  String get notifEveningBody => 'A few minutes of remembrance before evening.';

  @override
  String notifSuhoorTitle(String time) {
    return 'Suhoor ends at $time';
  }

  @override
  String notifSuhoorBody(String min) {
    return '$min minutes until Fajr.';
  }

  @override
  String get notifIftarTitle => 'Iftar time';

  @override
  String notifIftarBody(String place) {
    return 'Maghrib has come in $place. May Allah accept your fast.';
  }

  @override
  String get chanAdhan => 'Prayer times · adhan';

  @override
  String get chanStandard => 'Prayer times · standard sound';

  @override
  String get chanReminders => 'Reminders';
}
