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
  String get tomorrow => 'Tomorrow';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

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
  String get homePrayerTimes => 'Prayer times';

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
  String get homeWorshipTitle => 'Today’s worship';

  @override
  String get homeWorshipHint => 'Tap the ones you completed';

  @override
  String get homePrayers => 'Prayers';

  @override
  String get homeUpNext => 'Up next';

  @override
  String get homeStart => 'Start';

  @override
  String get homeMarkDone => 'Done';

  @override
  String homeAdhkarAfter(String window, String min) {
    return '$window · ≈$min min read';
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
  String get expenseAddCategory => 'Add category';

  @override
  String get expenseCategoryName => 'Category name';

  @override
  String get expenseCategoryExists => 'This category already exists.';

  @override
  String get catGroceries => 'Groceries';

  @override
  String get catTransport => 'Transport';

  @override
  String get catFood => 'Eating out';

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
  String get calendarTrackerTitle => 'Prayer times & tracker';

  @override
  String get calendarOpenTracker => 'Open prayer tracker';

  @override
  String calendarTogglePrayer(String prayer) {
    return 'Mark $prayer as prayed';
  }

  @override
  String get calendarFast => 'Fast';

  @override
  String get calendarToggleFast => 'Mark the fast as kept';

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
  String get fastTypeQada => 'Make-up fast';

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
  String get toolsCalendar => 'Calendar';

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
  String get alertSilent => 'Sound';

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
      'Touch and hold an empty area of the Home Screen, tap +, search for Waqt and choose the small, medium, large or lock-screen widget.';

  @override
  String get widgetsHelpAndroid =>
      'Touch and hold an empty area of the home screen, tap Widgets, find Waqt and drag the widget onto the screen. Its button marks the current prayer.';

  @override
  String get widgetsHelpData =>
      'Widgets show the next seven days of times even if you don\'t open the app.';

  @override
  String get widgetNext => 'Next';

  @override
  String get widgetRemainingTime => 'Remaining time';

  @override
  String get widgetTodayRecord => 'Today\'s record';

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

  @override
  String get tabQuran => 'Quran';

  @override
  String get tabLibrary => 'Library';

  @override
  String get quranTitle => 'Quran';

  @override
  String get quranContinue => 'Continue reading';

  @override
  String get quranStart => 'Start reading';

  @override
  String get quranStartHint => 'Begin with Al-Fatihah, the Opening.';

  @override
  String quranAyahN(String n) {
    return 'Ayah $n';
  }

  @override
  String quranPageN(String n) {
    return 'Page $n';
  }

  @override
  String quranJuzN(String n) {
    return 'Juz $n';
  }

  @override
  String get quranSurahs => 'Surahs';

  @override
  String get quranJuzTab => 'Juz';

  @override
  String quranAyahCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ayahs',
      one: '$count ayah',
    );
    return '$_temp0';
  }

  @override
  String get quranMeccan => 'Meccan';

  @override
  String get quranMedinan => 'Medinan';

  @override
  String get quranSearch => 'Search the Quran';

  @override
  String get quranSearchHint => 'Surah, 2:255 or any words';

  @override
  String quranGoTo(String ref) {
    return 'Go to $ref';
  }

  @override
  String get quranNoResults => 'No matches. Try fewer words or Arabic.';

  @override
  String quranResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ayahs',
      one: '$count ayah',
    );
    return '$_temp0';
  }

  @override
  String quranSearchIn(String translation) {
    return 'Searching Arabic and $translation';
  }

  @override
  String get quranBookmarks => 'Bookmarks';

  @override
  String get quranNoBookmarks =>
      'No bookmarks yet. Long-press an ayah or tap ••• to save it here.';

  @override
  String get quranBookmark => 'Bookmark';

  @override
  String get quranRemoveBookmark => 'Remove bookmark';

  @override
  String get quranRemoveNoteConfirm => 'Remove this bookmark and its note?';

  @override
  String translationLabel(String name) {
    return 'Translation: $name';
  }

  @override
  String get quranBookmarked => 'Saved to bookmarks';

  @override
  String get moreActions => 'More';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get shareImage => 'Share as image';

  @override
  String get shareText => 'Share text';

  @override
  String get share => 'Share';

  @override
  String get quranAddNote => 'Add a note';

  @override
  String get quranNoteHint => 'What does this ayah mean to you?';

  @override
  String get quranSetLastRead => 'Mark as where I stopped';

  @override
  String get quranReadingSettings => 'Reading settings';

  @override
  String get quranArabicSize => 'Arabic size';

  @override
  String get quranTextSize => 'Translation size';

  @override
  String get quranShowTranslation => 'Show translation';

  @override
  String get quranShowTranslit => 'Show transliteration';

  @override
  String get quranTranslation => 'Translation';

  @override
  String get quranArabicFont => 'Arabic script';

  @override
  String get quranFontUthmani => 'Uthmani';

  @override
  String get quranFontNaskh => 'Naskh (plain)';

  @override
  String get quranSepia => 'Warm paper';

  @override
  String get quranKeepAwake => 'Keep screen on while reading';

  @override
  String get quranMemorize => 'Memorize mode';

  @override
  String get quranMemorizeHint =>
      'Arabic is hidden. Recite, then tap to check.';

  @override
  String get quranTapToReveal => 'Tap to reveal';

  @override
  String get quranModeList => 'Translation view';

  @override
  String get quranModePage => 'Mushaf pages';

  @override
  String get quranSajda => 'Sajdah';

  @override
  String get quranToday => 'Today';

  @override
  String quranGoal(String read, String goal) {
    return '$read of $goal ayahs';
  }

  @override
  String quranGoalPages(String read, String goal) {
    return '$read of $goal pages';
  }

  @override
  String get khatmLast14 => 'Last 14 days';

  @override
  String get quranGoalDone => 'Daily goal reached';

  @override
  String quranStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days in a row',
      one: '$count day in a row',
      zero: 'Start a streak today',
    );
    return '$_temp0';
  }

  @override
  String get quranDailyGoal => 'Daily goal';

  @override
  String quranDailyGoalValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ayahs a day',
      one: '$count ayah a day',
    );
    return '$_temp0';
  }

  @override
  String get quranReadTracking =>
      'Ayahs count as read after you spend a moment on them.';

  @override
  String get quranOfDay => 'Ayah of the day';

  @override
  String get quranOpenInReader => 'Open in Quran';

  @override
  String quranSurahInfo(String place, String ayahs) {
    return '$place · $ayahs';
  }

  @override
  String quranNextSurah(String name) {
    return 'Next: $name';
  }

  @override
  String get quranLoading => 'Opening the Quran…';

  @override
  String get quranReadSurah => 'Read';

  @override
  String get khatmTitle => 'Khatm plan';

  @override
  String get khatmShort => 'Khatm';

  @override
  String get khatmIntro =>
      'Read the whole Quran at your pace. Waqt spreads what’s left over the remaining days, so a missed day never ruins the plan.';

  @override
  String get khatmChoose => 'Finish in';

  @override
  String khatmDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String khatmPerDay(String pages) {
    return '≈ $pages pages a day';
  }

  @override
  String get khatmStart => 'Start plan';

  @override
  String khatmDayOf(String day, String total) {
    return 'Day $day of $total';
  }

  @override
  String khatmTodayTarget(String pages, String from) {
    return 'Today: $pages pages, from $from';
  }

  @override
  String get khatmTodayDone => 'Today’s portion is done. Barakallahu fik!';

  @override
  String get khatmBehind =>
      'A little behind — today’s portion is a bit bigger.';

  @override
  String get khatmOnTrack => 'On track';

  @override
  String get khatmEnd => 'End plan';

  @override
  String get khatmEndConfirm => 'End this plan? Your reading history stays.';

  @override
  String get khatmComplete => 'Khatm complete! May Allah accept it from you.';

  @override
  String khatmProgress(String read, String total) {
    return '$read of $total pages';
  }

  @override
  String khatmDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '$count day left',
      zero: 'Last day',
    );
    return '$_temp0';
  }

  @override
  String get khatmRamadan => 'Ramadan';

  @override
  String get khatmNewPlan => 'Start a new plan';

  @override
  String get khatmShareText =>
      'I completed a khatm of the Quran with Waqt. Alhamdulillah!';

  @override
  String get khatmReminder => 'Remind me after Isha';

  @override
  String get notifQuranTitle => 'Today’s Quran';

  @override
  String get notifQuranBody => 'A few minutes with the Quran before sleep.';

  @override
  String get hifzTitle => 'Memorize';

  @override
  String get hifzIntro =>
      'Add surahs you’re memorizing. Review each on a spaced schedule — 1, 3, 7, 14, 30 and 90 days — so it stays strong.';

  @override
  String get hifzAdd => 'Add surah';

  @override
  String get hifzDue => 'Due for review';

  @override
  String get hifzUpcoming => 'Coming up';

  @override
  String get hifzReview => 'Review';

  @override
  String get hifzHowWent => 'How did the review go?';

  @override
  String get hifzStrong => 'Strong';

  @override
  String get hifzWeak => 'Shaky';

  @override
  String hifzNext(String date) {
    return 'Next review $date';
  }

  @override
  String get hifzEmpty =>
      'Nothing on your list yet. Short surahs from Juz ʿAmma are a great start.';

  @override
  String get hifzRemove => 'Remove from list';

  @override
  String get hifzSuggested => 'Suggested';

  @override
  String get hifzAllSurahs => 'All surahs';

  @override
  String get hifzTileIdle => 'Spaced review';

  @override
  String hifzDueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count due today',
      one: '$count due today',
    );
    return '$_temp0';
  }

  @override
  String get khatmTileIdle => 'Finish on a schedule';

  @override
  String get hifzAgain => 'Again';

  @override
  String get quranJumpTo => 'Jump to surah, juz or page';

  @override
  String get quranPages => 'Pages';

  @override
  String get hifzMemorized => 'Memorized';

  @override
  String get libraryHadith => 'Hadith collections';

  @override
  String get libraryDuas => 'Duas';

  @override
  String get libraryDuasSub => 'For every moment of the day';

  @override
  String get libraryNames => '99 Names of Allah';

  @override
  String get libraryNamesSub => 'Asmaʾ al-Husna';

  @override
  String get libraryLearn => 'Learn';

  @override
  String get libraryLearnSub => 'Prayer, wudu, fasting and more';

  @override
  String get libraryAdhkar => 'Morning & evening adhkar';

  @override
  String get librarySaved => 'Saved';

  @override
  String get librarySavedEmpty =>
      'Bookmark a hadith, dua or Name and it will appear here.';

  @override
  String get libraryContentReview =>
      'Texts are compiled from classical sources. Please verify with a scholar when in doubt.';

  @override
  String get hadithTitle => 'Hadith';

  @override
  String get hadithOfDay => 'Hadith of the day';

  @override
  String get hadithBookNawawi => '40 Hadith of an-Nawawi';

  @override
  String get hadithBookQudsi => '40 Hadith Qudsi';

  @override
  String get hadithBookBukhari => 'Sahih al-Bukhari';

  @override
  String get hadithBookMuslim => 'Sahih Muslim';

  @override
  String hadithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hadith',
      one: '$count hadith',
    );
    return '$_temp0';
  }

  @override
  String hadithN(String n) {
    return 'Hadith $n';
  }

  @override
  String get hadithBooks => 'Books';

  @override
  String get hadithSearchHint => 'Search words or a number';

  @override
  String get hadithSearchAll => 'Search hadith';

  @override
  String get hadithSearchAllHint => 'Words in any collection';

  @override
  String get hadithShowArabic => 'Show Arabic text';

  @override
  String get hadithTranslation => 'Translation';

  @override
  String get quranMushafStyle => 'Mushaf style';

  @override
  String get quranMushafStyleSub =>
      'Parchment page, 15-line Madani layout (page view), pink “Allah”, gold verse markers';

  @override
  String get quranTajweed => 'Tajweed colors';

  @override
  String get quranTajweedSub =>
      'Colors the recitation rules (ghunna, madd, qalqala…)';

  @override
  String searchResultsFor(String query) {
    return 'Results for “$query”';
  }

  @override
  String searchNoneFor(String query) {
    return 'No results for “$query”';
  }

  @override
  String get hadithNoResults => 'No hadith found.';

  @override
  String get hadithFallback =>
      'Not available in your language — showing English.';

  @override
  String hadithRange(String from, String to) {
    return 'Hadith $from–$to';
  }

  @override
  String get hadithOpenBook => 'Read the collection';

  @override
  String get langEnglish => 'English';

  @override
  String get langRussian => 'Russian';

  @override
  String get langTurkish => 'Turkish';

  @override
  String get duaSearchHint => 'Search duas';

  @override
  String duaRepeat(String count) {
    return 'Repeat $count×';
  }

  @override
  String get duaAll => 'All';

  @override
  String get duaFavorites => 'Favorites';

  @override
  String get namesQuiz => 'Practice';

  @override
  String get namesQuizQuestion => 'What does this Name mean?';

  @override
  String namesQuizScore(String right, String total) {
    return '$right of $total correct';
  }

  @override
  String get namesQuizNext => 'Next';

  @override
  String get namesQuizAgain => 'Practice again';

  @override
  String namesLearned(String count) {
    return '$count of 99 learned';
  }

  @override
  String get namesHadith =>
      '“Allah has ninety-nine names; whoever learns them will enter Paradise.” — Bukhari & Muslim';

  @override
  String learnSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '$count step',
    );
    return '$_temp0';
  }

  @override
  String learnStepN(String n) {
    return 'Step $n';
  }

  @override
  String get meQuranStreak => 'Quran streak';

  @override
  String get meQuranDaily => 'reading every day';

  @override
  String get mePrayedToday => 'prayed today';

  @override
  String get meStartStreak => 'Pray all five today to start your streak';

  @override
  String get meStreakShare => 'Five prayers a day, with Waqt';

  @override
  String get meSettingsRow => 'Settings';

  @override
  String get habitsEmptyShort => 'Build a small daily habit';

  @override
  String get homeAddExpenseShort => 'Expense';

  @override
  String qadaMadeUpSnack(String prayer) {
    return '$prayer: one made up';
  }

  @override
  String get qadaYearsHelper => 'I missed about…';

  @override
  String qadaMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '$count month',
    );
    return '$_temp0';
  }

  @override
  String qadaYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '$count year',
    );
    return '$_temp0';
  }

  @override
  String get expensesTitle => 'Spending';

  @override
  String get expensesEmpty => 'No spending recorded this month.';

  @override
  String get incomeTitle => 'Income';

  @override
  String get incomeAdd => 'Add income';

  @override
  String get incomeSaved => 'Income saved';

  @override
  String get incomeDeleted => 'Income deleted';

  @override
  String incomeSave(String amount, String currency) {
    return 'Save $amount $currency';
  }

  @override
  String get incomeEmpty => 'No income recorded this month.';

  @override
  String get catSalary => 'Salary';

  @override
  String get catBusiness => 'Business';

  @override
  String get catGift => 'Gift';

  @override
  String get catInvestment => 'Investment';

  @override
  String get transactionExpense => 'Expense';

  @override
  String get transactionIncome => 'Income';

  @override
  String get financeTitle => 'Spending & Income';

  @override
  String get netBalance => 'Net balance';

  @override
  String get totalIncome => 'Income';

  @override
  String get totalExpense => 'Expenses';

  @override
  String get filterAll => 'All';

  @override
  String get filterExpenses => 'Expenses';

  @override
  String get filterIncome => 'Income';

  @override
  String get todayIncome => 'Income today';

  @override
  String get noTransactions => 'No transactions recorded this month.';

  @override
  String get categoryDelete => 'Delete category';

  @override
  String categoryDeleteConfirm(String name) {
    return 'Delete “$name”? Existing transactions will keep this name.';
  }

  @override
  String get meAyahsRead => 'Ayahs read';

  @override
  String get notifTestTitle => 'Send a test alert';

  @override
  String get notifTestSub =>
      'Arrives in 5 seconds — lock your phone to check sound and banner.';

  @override
  String get notifTestBody =>
      'If you can see and hear this, prayer alerts will work.';

  @override
  String get notifTestSent => 'Test alert on its way…';

  @override
  String get fastsOwedTitle => 'Fasts to make up';

  @override
  String fastsOwedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
      zero: 'All made up — alhamdulillah',
    );
    return '$_temp0';
  }

  @override
  String get fastsOwedSub =>
      'Missed or excused Ramadan days, minus make-up fasts you log.';

  @override
  String get fastsLogQada => 'I fasted a make-up day today';

  @override
  String get backupTitle => 'Backup & restore';

  @override
  String get backupRowSub => 'Move your data to a new phone';

  @override
  String get backupIntro =>
      'Waqt has no account and no cloud. Export a backup file and keep it safe (Files, Telegram “Saved messages”, email to yourself). Restore it on any phone.';

  @override
  String get backupExport => 'Export backup';

  @override
  String get backupImport => 'Restore from file';

  @override
  String get backupRestore => 'Restore';

  @override
  String get backupRestoreTitle => 'Replace all data?';

  @override
  String get backupRestoreBody =>
      'Everything on this phone will be replaced by the backup.';

  @override
  String get backupRestored => 'Restored. Welcome back!';

  @override
  String get backupNever => 'No backup yet';

  @override
  String backupLast(String date) {
    return 'Last backup: $date';
  }

  @override
  String get backupInvalid => 'This file isn’t a Waqt backup.';

  @override
  String get zakatTitle => 'Zakat calculator';

  @override
  String get zakatShort => 'Zakat';

  @override
  String get zakatDue => 'Zakat due';

  @override
  String get zakatAbove => 'Above nisab — 2.5% is due.';

  @override
  String get zakatBelow => 'Below nisab — no zakat is due.';

  @override
  String get zakatNeedPrice =>
      'Enter today’s gold or silver price to find the nisab.';

  @override
  String get zakatWealth => 'Zakatable wealth';

  @override
  String get zakatNisab => 'Nisab';

  @override
  String get zakatNisabBasis => 'Nisab based on';

  @override
  String get zakatNisabGold => 'Gold · 85 g';

  @override
  String get zakatNisabSilver => 'Silver · 595 g';

  @override
  String get zakatPriceHint =>
      'Waqt never goes online — type today’s local price per gram.';

  @override
  String get zakatGoldPrice => 'Gold price';

  @override
  String get zakatSilverPrice => 'Silver price';

  @override
  String get zakatPerGram => 'per gram';

  @override
  String get zakatGrams => 'g';

  @override
  String get zakatAssets => 'What you own';

  @override
  String get zakatLiabilities => 'What you owe now';

  @override
  String get zakatCash => 'Cash & bank';

  @override
  String get zakatGold => 'Gold';

  @override
  String get zakatSilver => 'Silver';

  @override
  String get zakatInvestments => 'Shares & savings';

  @override
  String get zakatBusiness => 'Business stock';

  @override
  String get zakatReceivables => 'Money owed to you';

  @override
  String get zakatDebts => 'Debts due now';

  @override
  String get zakatRecord => 'Record as sadaqa expense';

  @override
  String get zakatRecorded => 'Recorded in expenses';

  @override
  String get zakatNote =>
      'Zakat is 2.5% of wealth above the nisab held for one lunar year. Your home, car and personal items are not counted. Ask a scholar for your situation.';

  @override
  String get timetableTitle => 'Prayer timetable';

  @override
  String get timetableShort => 'Timetable';

  @override
  String get timetableNote =>
      'Times use your method, Asr setting and mosque offsets. Fridays are highlighted.';

  @override
  String get habitsTitle => 'Habits';

  @override
  String get habitsAdd => 'New habit';

  @override
  String get habitsNameHint => 'e.g. Read one page of Quran';

  @override
  String get habitsEmpty =>
      'Small daily habits add up. Add one you want to keep — prayer-related or not.';

  @override
  String habitsDoneToday(String done, String total) {
    return '$done of $total today';
  }

  @override
  String get habitsSuggestions => 'Ideas';

  @override
  String get habitSugQuran => 'Read one page of Quran';

  @override
  String get habitSugDhikr => '100× SubhanAllah';

  @override
  String get habitSugWater => 'Drink 8 glasses of water';

  @override
  String get habitSugWalk => '20-minute walk';

  @override
  String get habitSugSadaqa => 'Give a little sadaqa';

  @override
  String get habitSugParents => 'Call my parents';

  @override
  String get habitSugGratitude => 'Write 3 things I’m grateful for';

  @override
  String get habitSugRead => 'Read 10 pages of a book';

  @override
  String get habitSugSleep => 'Sleep before 23:00';

  @override
  String get ramadanChallenge => 'Ramadan challenge';

  @override
  String ramadanChallengeScore(String score) {
    return '$score of 5 today';
  }

  @override
  String ramadanCoreDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count full days so far',
      one: '$count full day so far',
      zero: 'Full days start with fast, prayers and Quran',
    );
    return '$_temp0';
  }

  @override
  String get ramadanItemFast => 'Fast';

  @override
  String get ramadanItemPrayers => '5 prayers';

  @override
  String get ramadanItemQuran => 'Quran';

  @override
  String get ramadanItemDhikr => 'Dhikr';

  @override
  String get ramadanItemSadaqa => 'Sadaqa';

  @override
  String get ramadanChallengeIntro =>
      'When Ramadan begins, Waqt tracks five daily goals — fast, prayers, Quran, dhikr and sadaqa — and lets you share your progress.';

  @override
  String get obGetStarted => 'Get started';

  @override
  String get obTagline => 'Your day, around the five prayers.';

  @override
  String get obValuePrayer => 'Prayer times that just work';

  @override
  String get obValuePrayerSub =>
      'Alerts, qibla, tracking and gentle qada help.';

  @override
  String get obValueQuran => 'Quran & hadith, offline';

  @override
  String get obValueQuranSub =>
      '8 translations, khatm planner, memorization, duas.';

  @override
  String get obValueDay => 'Plan your whole day';

  @override
  String get obValueDaySub =>
      'Tasks by prayer time, spending, habits and streaks.';

  @override
  String get obValuePrivate => 'Private by design';

  @override
  String get obValuePrivateSub =>
      'No account, no ads, no tracking. Works offline.';

  @override
  String get shareThemeEmerald => 'Emerald';

  @override
  String get shareThemePaper => 'Paper';

  @override
  String get shareThemeNight => 'Night';

  @override
  String get shareWithArabic => 'Arabic';

  @override
  String get shareWithTranslation => 'Translation';

  @override
  String get shareFooter => 'Waqt · your day around prayer';

  @override
  String get quranReminderAfterIsha => 'Quran reminder after Isha';

  @override
  String get khatmOverdue =>
      'The plan’s days are over — extend it to keep a gentle pace.';

  @override
  String khatmFarBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '$count page',
    );
    return 'Behind by $_temp0 — no pressure, any amount counts.';
  }

  @override
  String khatmExtend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return 'Extend by $_temp0';
  }

  @override
  String get expenseAddFirst => 'Tap + to note a purchase';

  @override
  String get tmOfficialTable => 'Official Turkmenistan timetable';

  @override
  String get chipDone => 'marked';

  @override
  String get chipNow => 'now';

  @override
  String get chipUnmarked => 'not marked yet';

  @override
  String get chipUpcoming => 'upcoming';

  @override
  String get chipMissed => 'missed, in qada';

  @override
  String get chipExcused => 'excused';

  @override
  String get tasksAddFirst => 'Plan something around a prayer';
}
