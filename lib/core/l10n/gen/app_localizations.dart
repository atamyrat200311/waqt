import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tk.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('tk'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Waqt'**
  String get appName;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tabTools;

  /// No description provided for @tabMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get tabMe;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDate;

  /// No description provided for @listAnd.
  ///
  /// In en, this message translates to:
  /// **'{a} and {b}'**
  String listAnd(String a, String b);

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGeneric;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @weekdayName.
  ///
  /// In en, this message translates to:
  /// **'{day, select, mon{Monday} tue{Tuesday} wed{Wednesday} thu{Thursday} fri{Friday} sat{Saturday} other{Sunday}}'**
  String weekdayName(String day);

  /// No description provided for @weekdayShort.
  ///
  /// In en, this message translates to:
  /// **'{day, select, mon{Mon} tue{Tue} wed{Wed} thu{Thu} fri{Fri} sat{Sat} other{Sun}}'**
  String weekdayShort(String day);

  /// No description provided for @weekdayInitial.
  ///
  /// In en, this message translates to:
  /// **'{day, select, mon{M} tue{T} wed{W} thu{T} fri{F} sat{S} other{S}}'**
  String weekdayInitial(String day);

  /// No description provided for @monthName.
  ///
  /// In en, this message translates to:
  /// **'{month, select, jan{January} feb{February} mar{March} apr{April} may{May} jun{June} jul{July} aug{August} sep{September} oct{October} nov{November} other{December}}'**
  String monthName(String month);

  /// No description provided for @monthShort.
  ///
  /// In en, this message translates to:
  /// **'{month, select, jan{Jan} feb{Feb} mar{Mar} apr{Apr} may{May} jun{Jun} jul{Jul} aug{Aug} sep{Sep} oct{Oct} nov{Nov} other{Dec}}'**
  String monthShort(String month);

  /// No description provided for @monthStandalone.
  ///
  /// In en, this message translates to:
  /// **'{month, select, jan{January} feb{February} mar{March} apr{April} may{May} jun{June} jul{July} aug{August} sep{September} oct{October} nov{November} other{December}}'**
  String monthStandalone(String month);

  /// No description provided for @dateLong.
  ///
  /// In en, this message translates to:
  /// **'{weekday}, {day} {month}'**
  String dateLong(String weekday, String day, String month);

  /// No description provided for @dateDayMonth.
  ///
  /// In en, this message translates to:
  /// **'{day} {month}'**
  String dateDayMonth(String day, String month);

  /// No description provided for @dateShortWeekday.
  ///
  /// In en, this message translates to:
  /// **'{weekday} {day} {month}'**
  String dateShortWeekday(String weekday, String day, String month);

  /// No description provided for @hijriMonth.
  ///
  /// In en, this message translates to:
  /// **'{month, select, m1{Muḥarram} m2{Ṣafar} m3{Rabīʿ I} m4{Rabīʿ II} m5{Jumādā I} m6{Jumādā II} m7{Rajab} m8{Shaʿbān} m9{Ramaḍān} m10{Shawwāl} m11{Dhū al-Qaʿdah} other{Dhū al-Ḥijjah}}'**
  String hijriMonth(String month);

  /// No description provided for @hijriMonthLong.
  ///
  /// In en, this message translates to:
  /// **'{month, select, m1{Muḥarram} m2{Ṣafar} m3{Rabīʿ al-Awwal} m4{Rabīʿ al-Thānī} m5{Jumādā al-Ūlā} m6{Jumādā al-Ākhirah} m7{Rajab} m8{Shaʿbān} m9{Ramaḍān} m10{Shawwāl} m11{Dhū al-Qaʿdah} other{Dhū al-Ḥijjah}}'**
  String hijriMonthLong(String month);

  /// No description provided for @hijriDate.
  ///
  /// In en, this message translates to:
  /// **'{day} {month} {year}'**
  String hijriDate(String day, String month, String year);

  /// Hour unit shown next to the big hero countdown.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get unitH;

  /// Minute unit shown next to the big hero countdown.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get unitM;

  /// No description provided for @unitS.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get unitS;

  /// No description provided for @durationHM.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String durationHM(String h, String m);

  /// No description provided for @durationM.
  ///
  /// In en, this message translates to:
  /// **'{m}m'**
  String durationM(String m);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{m} min'**
  String minutesShort(String m);

  /// No description provided for @inDuration.
  ///
  /// In en, this message translates to:
  /// **'in {d}'**
  String inDuration(String d);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day} other{{n} days}}'**
  String daysCount(int n);

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{day} other{days}}'**
  String daysUnit(int n);

  /// No description provided for @eventCountdown.
  ///
  /// In en, this message translates to:
  /// **'{name} {days, plural, =0{today} =1{tomorrow} other{in {days} days}}'**
  String eventCountdown(int days, String name);

  /// No description provided for @homeNextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get homeNextPrayer;

  /// Word before the countdown on the hero card ("in 1h 12m"). Empty if the language puts it after.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get homeIn;

  /// Word after the countdown for languages that put it after the number ("1 sa 12 dk sonra").
  ///
  /// In en, this message translates to:
  /// **''**
  String get homeInAfter;

  /// No description provided for @homeRamadanKicker.
  ///
  /// In en, this message translates to:
  /// **'Ramadan · Iftar'**
  String get homeRamadanKicker;

  /// No description provided for @homeIftar.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get homeIftar;

  /// No description provided for @homeMaghribAt.
  ///
  /// In en, this message translates to:
  /// **'Maghrib {time}'**
  String homeMaghribAt(String time);

  /// No description provided for @homeSuhoorLine.
  ///
  /// In en, this message translates to:
  /// **'Suhoor ends {time} · Fast {n} of {total}'**
  String homeSuhoorLine(String time, String n, String total);

  /// No description provided for @homeAfterIshaKicker.
  ///
  /// In en, this message translates to:
  /// **'After Isha · {time}'**
  String homeAfterIshaKicker(String time);

  /// No description provided for @homeYourDay.
  ///
  /// In en, this message translates to:
  /// **'Your day'**
  String get homeYourDay;

  /// No description provided for @homeUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get homeUpNext;

  /// No description provided for @homeStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get homeStart;

  /// No description provided for @homeMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get homeMarkDone;

  /// No description provided for @homeAdhkarAfter.
  ///
  /// In en, this message translates to:
  /// **'{window} · {min} min'**
  String homeAdhkarAfter(String window, String min);

  /// No description provided for @homeTaraweeh.
  ///
  /// In en, this message translates to:
  /// **'Taraweeh'**
  String get homeTaraweeh;

  /// No description provided for @homeTaraweehSub.
  ///
  /// In en, this message translates to:
  /// **'At the mosque · reminder {time}'**
  String homeTaraweehSub(String time);

  /// No description provided for @homeSpentToday.
  ///
  /// In en, this message translates to:
  /// **'Spent today'**
  String get homeSpentToday;

  /// No description provided for @homeInclSadaqa.
  ///
  /// In en, this message translates to:
  /// **'incl. {amount} sadaqa'**
  String homeInclSadaqa(String amount);

  /// No description provided for @homeTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get homeTasks;

  /// No description provided for @homeTasksOf.
  ///
  /// In en, this message translates to:
  /// **'of {total}'**
  String homeTasksOf(String total);

  /// No description provided for @homeQadaRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 qada remaining} other{{count} qada remaining}}'**
  String homeQadaRemaining(int count);

  /// No description provided for @homeMakeUp.
  ///
  /// In en, this message translates to:
  /// **'Make up'**
  String get homeMakeUp;

  /// No description provided for @homeUnmarkedTitle.
  ///
  /// In en, this message translates to:
  /// **'You didn\'t mark {prayers} yesterday'**
  String homeUnmarkedTitle(String prayers);

  /// No description provided for @homeUnmarkedBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing is added to qada unless you choose.'**
  String get homeUnmarkedBody;

  /// No description provided for @homeUnmarkedAllPrayed.
  ///
  /// In en, this message translates to:
  /// **'All prayed'**
  String get homeUnmarkedAllPrayed;

  /// No description provided for @homeAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get homeAddExpense;

  /// No description provided for @homeSetLocation.
  ///
  /// In en, this message translates to:
  /// **'Set location'**
  String get homeSetLocation;

  /// No description provided for @markClosedAtSunrise.
  ///
  /// In en, this message translates to:
  /// **'closed at sunrise'**
  String get markClosedAtSunrise;

  /// No description provided for @markClosedAt.
  ///
  /// In en, this message translates to:
  /// **'closed at {time}'**
  String markClosedAt(String time);

  /// No description provided for @markLeft.
  ///
  /// In en, this message translates to:
  /// **'{d} left'**
  String markLeft(String d);

  /// No description provided for @markOpensAt.
  ///
  /// In en, this message translates to:
  /// **'opens at {time}'**
  String markOpensAt(String time);

  /// No description provided for @markOnTime.
  ///
  /// In en, this message translates to:
  /// **'Prayed on time'**
  String get markOnTime;

  /// No description provided for @markOnTimeSub.
  ///
  /// In en, this message translates to:
  /// **'Within the {prayer} window'**
  String markOnTimeSub(String prayer);

  /// No description provided for @markCongregation.
  ///
  /// In en, this message translates to:
  /// **'In congregation'**
  String get markCongregation;

  /// No description provided for @markCongregationSub.
  ///
  /// In en, this message translates to:
  /// **'With the jamāʿah, on time'**
  String get markCongregationSub;

  /// No description provided for @markLate.
  ///
  /// In en, this message translates to:
  /// **'Prayed late'**
  String get markLate;

  /// No description provided for @markLateSub.
  ///
  /// In en, this message translates to:
  /// **'After the window closed'**
  String get markLateSub;

  /// No description provided for @markMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed, add to qada'**
  String get markMissed;

  /// No description provided for @markMissedSub.
  ///
  /// In en, this message translates to:
  /// **'You confirm before anything is added'**
  String get markMissedSub;

  /// No description provided for @markExcused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get markExcused;

  /// No description provided for @markExcusedSub.
  ///
  /// In en, this message translates to:
  /// **'Period mode is on — no qada, streak kept'**
  String get markExcusedSub;

  /// No description provided for @markConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Add 1 {prayer} to your qada?'**
  String markConfirmTitle(String prayer);

  /// No description provided for @markConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You can make it up at any time. Nothing is added until you confirm.'**
  String get markConfirmBody;

  /// No description provided for @markAddToQada.
  ///
  /// In en, this message translates to:
  /// **'Add to qada'**
  String get markAddToQada;

  /// No description provided for @markAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to qada. Make it up whenever you can.'**
  String get markAdded;

  /// No description provided for @markRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind me in 15 min'**
  String get markRemind;

  /// No description provided for @markReminderSet.
  ///
  /// In en, this message translates to:
  /// **'Reminder set for {time}'**
  String markReminderSet(String time);

  /// No description provided for @markClear.
  ///
  /// In en, this message translates to:
  /// **'Clear mark'**
  String get markClear;

  /// No description provided for @markNotStarted.
  ///
  /// In en, this message translates to:
  /// **'This prayer\'s time hasn\'t started yet.'**
  String get markNotStarted;

  /// No description provided for @qadaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qada'**
  String get qadaTitle;

  /// Two lines next to the huge qada number.
  ///
  /// In en, this message translates to:
  /// **'prayers left\nto make up'**
  String get qadaLeft;

  /// No description provided for @qadaMadeUpSince.
  ///
  /// In en, this message translates to:
  /// **'You\'ve made up {count} since you started'**
  String qadaMadeUpSince(String count);

  /// No description provided for @qadaThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get qadaThisWeek;

  /// No description provided for @qadaWeekMadeUp.
  ///
  /// In en, this message translates to:
  /// **'{count} made up'**
  String qadaWeekMadeUp(String count);

  /// No description provided for @qadaMadeUp.
  ///
  /// In en, this message translates to:
  /// **'Made up'**
  String get qadaMadeUp;

  /// No description provided for @qadaAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done'**
  String get qadaAllDone;

  /// No description provided for @qadaAddOlder.
  ///
  /// In en, this message translates to:
  /// **'Add older missed prayers'**
  String get qadaAddOlder;

  /// No description provided for @qadaTip.
  ///
  /// In en, this message translates to:
  /// **'One at a time is enough. Many people pair one qada with each daily prayer.'**
  String get qadaTip;

  /// No description provided for @qadaAddOlderTitle.
  ///
  /// In en, this message translates to:
  /// **'Older missed prayers'**
  String get qadaAddOlderTitle;

  /// No description provided for @qadaAddOlderBody.
  ///
  /// In en, this message translates to:
  /// **'Enter how many of each prayer you still owe. They are added to your current counts.'**
  String get qadaAddOlderBody;

  /// No description provided for @qadaAddCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Add to qada} other{Add {count} to qada}}'**
  String qadaAddCount(int count);

  /// No description provided for @qadaEmpty.
  ///
  /// In en, this message translates to:
  /// **'No qada recorded. If you have older missed prayers, add them here.'**
  String get qadaEmpty;

  /// No description provided for @expenseAdd.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expenseAdd;

  /// No description provided for @expenseAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get expenseAddNote;

  /// No description provided for @expenseNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get expenseNoteHint;

  /// No description provided for @catGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get catGroceries;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// No description provided for @catBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get catBills;

  /// No description provided for @catSadaqa.
  ///
  /// In en, this message translates to:
  /// **'Sadaqa'**
  String get catSadaqa;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @expenseSave.
  ///
  /// In en, this message translates to:
  /// **'Save {amount} {currency}'**
  String expenseSave(String amount, String currency);

  /// No description provided for @expenseSaveSadaqa.
  ///
  /// In en, this message translates to:
  /// **'Save {amount} {currency} as sadaqa'**
  String expenseSaveSadaqa(String amount, String currency);

  /// No description provided for @expenseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get expenseEnterAmount;

  /// No description provided for @expenseSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get expenseSaved;

  /// No description provided for @expenseTodayList.
  ///
  /// In en, this message translates to:
  /// **'Today\'s entries'**
  String get expenseTodayList;

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @tasksDoneOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String tasksDoneOf(String done, String total);

  /// No description provided for @tasksAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add a task…'**
  String get tasksAddHint;

  /// No description provided for @tasksAddA11y.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get tasksAddA11y;

  /// No description provided for @winBeforeFajr.
  ///
  /// In en, this message translates to:
  /// **'Before Fajr'**
  String get winBeforeFajr;

  /// No description provided for @winAfterFajr.
  ///
  /// In en, this message translates to:
  /// **'After Fajr'**
  String get winAfterFajr;

  /// No description provided for @winBeforeDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Before Dhuhr'**
  String get winBeforeDhuhr;

  /// No description provided for @winAfterDhuhr.
  ///
  /// In en, this message translates to:
  /// **'After Dhuhr'**
  String get winAfterDhuhr;

  /// No description provided for @winAfterAsr.
  ///
  /// In en, this message translates to:
  /// **'After Asr'**
  String get winAfterAsr;

  /// No description provided for @winAfterMaghrib.
  ///
  /// In en, this message translates to:
  /// **'After Maghrib'**
  String get winAfterMaghrib;

  /// No description provided for @winAfterIsha.
  ///
  /// In en, this message translates to:
  /// **'After Isha'**
  String get winAfterIsha;

  /// No description provided for @winAnytime.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get winAnytime;

  /// No description provided for @winUntil.
  ///
  /// In en, this message translates to:
  /// **'until {time}'**
  String winUntil(String time);

  /// No description provided for @winFrom.
  ///
  /// In en, this message translates to:
  /// **'from {time}'**
  String winFrom(String time);

  /// No description provided for @winRange.
  ///
  /// In en, this message translates to:
  /// **'{a} – {b}'**
  String winRange(String a, String b);

  /// No description provided for @tasksOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unfinished task from earlier} other{{count} unfinished tasks from earlier}}'**
  String tasksOverdue(int count);

  /// No description provided for @tasksMoveToday.
  ///
  /// In en, this message translates to:
  /// **'Move to today'**
  String get tasksMoveToday;

  /// No description provided for @tasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned yet. Add a task to a prayer window.'**
  String get tasksEmpty;

  /// No description provided for @tasksDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get tasksDeleted;

  /// No description provided for @tasksAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done for today'**
  String get tasksAllDone;

  /// No description provided for @adhkarMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning adhkar'**
  String get adhkarMorning;

  /// No description provided for @adhkarEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening adhkar'**
  String get adhkarEvening;

  /// No description provided for @adhkarPosOf.
  ///
  /// In en, this message translates to:
  /// **'{pos} of {total}'**
  String adhkarPosOf(String pos, String total);

  /// No description provided for @adhkarRecite.
  ///
  /// In en, this message translates to:
  /// **'Recite {n}×'**
  String adhkarRecite(String n);

  /// No description provided for @adhkarComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get adhkarComplete;

  /// No description provided for @adhkarOf.
  ///
  /// In en, this message translates to:
  /// **'/ {n}'**
  String adhkarOf(String n);

  /// No description provided for @adhkarNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get adhkarNext;

  /// No description provided for @adhkarNextDhikr.
  ///
  /// In en, this message translates to:
  /// **'Next dhikr'**
  String get adhkarNextDhikr;

  /// No description provided for @adhkarFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get adhkarFinish;

  /// No description provided for @adhkarPrev.
  ///
  /// In en, this message translates to:
  /// **'Previous dhikr'**
  String get adhkarPrev;

  /// No description provided for @adhkarTapToCount.
  ///
  /// In en, this message translates to:
  /// **'Tap to count'**
  String get adhkarTapToCount;

  /// No description provided for @adhkarSetDone.
  ///
  /// In en, this message translates to:
  /// **'May Allah accept it from you.'**
  String get adhkarSetDone;

  /// No description provided for @adhkarTranslationNote.
  ///
  /// In en, this message translates to:
  /// **'Translation is approximate.'**
  String get adhkarTranslationNote;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Hijri calendar'**
  String get calendarTitle;

  /// No description provided for @calendarRange.
  ///
  /// In en, this message translates to:
  /// **'{year} · {start} – {end}'**
  String calendarRange(String year, String start, String end);

  /// No description provided for @calendarWhiteDays.
  ///
  /// In en, this message translates to:
  /// **'White days 13–15'**
  String get calendarWhiteDays;

  /// No description provided for @calendarMonThu.
  ///
  /// In en, this message translates to:
  /// **'Mon & Thu fasts'**
  String get calendarMonThu;

  /// No description provided for @calendarUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get calendarUpcoming;

  /// No description provided for @calendarMoonNote.
  ///
  /// In en, this message translates to:
  /// **'Dates may shift by a day depending on the local moon sighting.'**
  String get calendarMoonNote;

  /// No description provided for @calendarPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calendarPrevMonth;

  /// No description provided for @calendarNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calendarNextMonth;

  /// No description provided for @calendarEveningOf.
  ///
  /// In en, this message translates to:
  /// **'evening of {date}'**
  String calendarEveningOf(String date);

  /// No description provided for @evRajab.
  ///
  /// In en, this message translates to:
  /// **'Rajab begins'**
  String get evRajab;

  /// No description provided for @evMiraj.
  ///
  /// In en, this message translates to:
  /// **'Laylat al-Miʿrāj'**
  String get evMiraj;

  /// No description provided for @evBaraah.
  ///
  /// In en, this message translates to:
  /// **'Laylat al-Barāʾah'**
  String get evBaraah;

  /// No description provided for @evRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan begins'**
  String get evRamadan;

  /// No description provided for @evQadr.
  ///
  /// In en, this message translates to:
  /// **'Laylat al-Qadr'**
  String get evQadr;

  /// No description provided for @evEidFitr.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Fitr'**
  String get evEidFitr;

  /// No description provided for @evArafah.
  ///
  /// In en, this message translates to:
  /// **'Day of Arafah'**
  String get evArafah;

  /// No description provided for @evEidAdha.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Adha'**
  String get evEidAdha;

  /// No description provided for @evNewYear.
  ///
  /// In en, this message translates to:
  /// **'Islamic New Year'**
  String get evNewYear;

  /// No description provided for @evAshura.
  ///
  /// In en, this message translates to:
  /// **'Ashura'**
  String get evAshura;

  /// No description provided for @evMawlid.
  ///
  /// In en, this message translates to:
  /// **'Mawlid'**
  String get evMawlid;

  /// No description provided for @evLastTen.
  ///
  /// In en, this message translates to:
  /// **'Last ten nights begin'**
  String get evLastTen;

  /// No description provided for @fastLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast · {date}'**
  String fastLogTitle(String date);

  /// No description provided for @fastFasted.
  ///
  /// In en, this message translates to:
  /// **'Fasted'**
  String get fastFasted;

  /// No description provided for @fastMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get fastMissed;

  /// No description provided for @fastExcused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get fastExcused;

  /// No description provided for @fastClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get fastClear;

  /// No description provided for @fastTypeRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan fast'**
  String get fastTypeRamadan;

  /// No description provided for @fastTypeMonThu.
  ///
  /// In en, this message translates to:
  /// **'Monday/Thursday fast'**
  String get fastTypeMonThu;

  /// No description provided for @fastTypeWhiteDays.
  ///
  /// In en, this message translates to:
  /// **'White day fast'**
  String get fastTypeWhiteDays;

  /// No description provided for @fastTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Voluntary fast'**
  String get fastTypeOther;

  /// No description provided for @ramadanTitle.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get ramadanTitle;

  /// No description provided for @ramadanMode.
  ///
  /// In en, this message translates to:
  /// **'Ramadan mode'**
  String get ramadanMode;

  /// No description provided for @ramadanAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get ramadanAuto;

  /// No description provided for @ramadanOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get ramadanOn;

  /// No description provided for @ramadanOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get ramadanOff;

  /// No description provided for @ramadanInDays.
  ///
  /// In en, this message translates to:
  /// **'in {days} days'**
  String ramadanInDays(String days);

  /// No description provided for @ramadanDayOf.
  ///
  /// In en, this message translates to:
  /// **'Day {n} of {total}'**
  String ramadanDayOf(String n, String total);

  /// No description provided for @ramadanSuhoorReminder.
  ///
  /// In en, this message translates to:
  /// **'Suhoor reminder'**
  String get ramadanSuhoorReminder;

  /// No description provided for @ramadanSuhoorBefore.
  ///
  /// In en, this message translates to:
  /// **'{min} min before Fajr'**
  String ramadanSuhoorBefore(String min);

  /// No description provided for @ramadanIftarReminder.
  ///
  /// In en, this message translates to:
  /// **'Iftar at Maghrib'**
  String get ramadanIftarReminder;

  /// No description provided for @ramadanTaraweehReminder.
  ///
  /// In en, this message translates to:
  /// **'Taraweeh reminder'**
  String get ramadanTaraweehReminder;

  /// No description provided for @ramadanFasts.
  ///
  /// In en, this message translates to:
  /// **'Fasts this Ramadan'**
  String get ramadanFasts;

  /// No description provided for @ramadanTodayFast.
  ///
  /// In en, this message translates to:
  /// **'Today\'s fast'**
  String get ramadanTodayFast;

  /// No description provided for @ramadanNotNow.
  ///
  /// In en, this message translates to:
  /// **'Ramadan mode turns on by itself on 1 Ramaḍān.'**
  String get ramadanNotNow;

  /// No description provided for @toolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsTitle;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @qiblaTurn.
  ///
  /// In en, this message translates to:
  /// **'Turn until the arrow points up'**
  String get qiblaTurn;

  /// No description provided for @qiblaFacing.
  ///
  /// In en, this message translates to:
  /// **'You\'re facing the Qibla'**
  String get qiblaFacing;

  /// No description provided for @qiblaCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Compass needs calibration — move your phone in a figure 8.'**
  String get qiblaCalibrate;

  /// No description provided for @qiblaNoSensor.
  ///
  /// In en, this message translates to:
  /// **'This device has no compass. The Qibla is {deg}° clockwise from true north.'**
  String qiblaNoSensor(String deg);

  /// No description provided for @qiblaFromNorth.
  ///
  /// In en, this message translates to:
  /// **'{deg}° from north'**
  String qiblaFromNorth(String deg);

  /// No description provided for @qiblaDistance.
  ///
  /// In en, this message translates to:
  /// **'{km} km to Makkah'**
  String qiblaDistance(String km);

  /// No description provided for @qiblaOpen.
  ///
  /// In en, this message translates to:
  /// **'Open compass'**
  String get qiblaOpen;

  /// No description provided for @tasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tasbih;

  /// No description provided for @tasbihOf.
  ///
  /// In en, this message translates to:
  /// **'of {n}'**
  String tasbihOf(String n);

  /// No description provided for @tasbihComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete · {n}'**
  String tasbihComplete(String n);

  /// No description provided for @tasbihTapAgain.
  ///
  /// In en, this message translates to:
  /// **'Tap to start again'**
  String get tasbihTapAgain;

  /// No description provided for @tasbihCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom tasbih'**
  String get tasbihCustom;

  /// No description provided for @tasbihPreset.
  ///
  /// In en, this message translates to:
  /// **'After-prayer tasbih (33 · 33 · 34)'**
  String get tasbihPreset;

  /// No description provided for @tasbihPhrase.
  ///
  /// In en, this message translates to:
  /// **'Phrase'**
  String get tasbihPhrase;

  /// No description provided for @tasbihGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get tasbihGoal;

  /// No description provided for @tasbihCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get tasbihCount;

  /// No description provided for @tasbihTapA11y.
  ///
  /// In en, this message translates to:
  /// **'Count one'**
  String get tasbihTapA11y;

  /// No description provided for @toolsAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Adhkar'**
  String get toolsAdhkar;

  /// No description provided for @toolsMorningDue.
  ///
  /// In en, this message translates to:
  /// **'Morning due'**
  String get toolsMorningDue;

  /// No description provided for @toolsEveningDue.
  ///
  /// In en, this message translates to:
  /// **'Evening due'**
  String get toolsEveningDue;

  /// No description provided for @toolsAdhkarDone.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get toolsAdhkarDone;

  /// No description provided for @toolsCalendar.
  ///
  /// In en, this message translates to:
  /// **'Hijri calendar'**
  String get toolsCalendar;

  /// No description provided for @toolsRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get toolsRamadan;

  /// No description provided for @toolsRamadanNow.
  ///
  /// In en, this message translates to:
  /// **'Day {n}'**
  String toolsRamadanNow(String n);

  /// No description provided for @meTitle.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meTitle;

  /// No description provided for @meAll5.
  ///
  /// In en, this message translates to:
  /// **'All 5 prayers'**
  String get meAll5;

  /// No description provided for @meDaysInRow.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{day in a row} other{days in a row}}'**
  String meDaysInRow(int n);

  /// No description provided for @me2WeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'2 weeks ago'**
  String get me2WeeksAgo;

  /// No description provided for @meBest.
  ///
  /// In en, this message translates to:
  /// **'Best: {n} days'**
  String meBest(String n);

  /// No description provided for @meOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get meOnTime;

  /// No description provided for @meThisMonth.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get meThisMonth;

  /// No description provided for @meAdhkarStreak.
  ///
  /// In en, this message translates to:
  /// **'Adhkar streak'**
  String get meAdhkarStreak;

  /// No description provided for @meDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get meDays;

  /// No description provided for @meMorningEvening.
  ///
  /// In en, this message translates to:
  /// **'morning & evening'**
  String get meMorningEvening;

  /// No description provided for @meConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get meConsistency;

  /// No description provided for @meFasts.
  ///
  /// In en, this message translates to:
  /// **'Fasts this month'**
  String get meFasts;

  /// No description provided for @meFastsNone.
  ///
  /// In en, this message translates to:
  /// **'None logged yet'**
  String get meFastsNone;

  /// No description provided for @meFastMonThu.
  ///
  /// In en, this message translates to:
  /// **'{n} Mon/Thu'**
  String meFastMonThu(String n);

  /// No description provided for @meFastWhite.
  ///
  /// In en, this message translates to:
  /// **'{n} white days'**
  String meFastWhite(String n);

  /// No description provided for @meFastRamadan.
  ///
  /// In en, this message translates to:
  /// **'{n} Ramadan'**
  String meFastRamadan(String n);

  /// No description provided for @meFastOther.
  ///
  /// In en, this message translates to:
  /// **'{n} voluntary'**
  String meFastOther(String n);

  /// No description provided for @meSadaqa.
  ///
  /// In en, this message translates to:
  /// **'Sadaqa'**
  String get meSadaqa;

  /// No description provided for @meSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get meSpending;

  /// No description provided for @meNoSpending.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month yet.'**
  String get meNoSpending;

  /// No description provided for @meNoPrayerData.
  ///
  /// In en, this message translates to:
  /// **'Mark your prayers on Today to see your consistency here.'**
  String get meNoPrayerData;

  /// No description provided for @meSettingsA11y.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get meSettingsA11y;

  /// No description provided for @tipFajrTitle.
  ///
  /// In en, this message translates to:
  /// **'Fajr is the quietest.'**
  String get tipFajrTitle;

  /// No description provided for @tipFajrBody.
  ///
  /// In en, this message translates to:
  /// **'An alarm ten minutes before adhan, with water by the bed, helps many people.'**
  String get tipFajrBody;

  /// No description provided for @tipDhuhrTitle.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr slips at work.'**
  String get tipDhuhrTitle;

  /// No description provided for @tipDhuhrBody.
  ///
  /// In en, this message translates to:
  /// **'Block ten minutes in your calendar right after the adhan.'**
  String get tipDhuhrBody;

  /// No description provided for @tipAsrTitle.
  ///
  /// In en, this message translates to:
  /// **'Asr is easy to miss.'**
  String get tipAsrTitle;

  /// No description provided for @tipAsrBody.
  ///
  /// In en, this message translates to:
  /// **'Pray as soon as you hear it, before the afternoon errands.'**
  String get tipAsrBody;

  /// No description provided for @tipMaghribTitle.
  ///
  /// In en, this message translates to:
  /// **'Maghrib\'s window is short.'**
  String get tipMaghribTitle;

  /// No description provided for @tipMaghribBody.
  ///
  /// In en, this message translates to:
  /// **'Pray first, then set the table.'**
  String get tipMaghribBody;

  /// No description provided for @tipIshaTitle.
  ///
  /// In en, this message translates to:
  /// **'Isha drifts late.'**
  String get tipIshaTitle;

  /// No description provided for @tipIshaBody.
  ///
  /// In en, this message translates to:
  /// **'Pray it before tea and screens, then rest.'**
  String get tipIshaBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @secPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get secPrayerTimes;

  /// No description provided for @calcMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation method'**
  String get calcMethod;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @asrStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get asrStandard;

  /// No description provided for @asrHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get asrHanafi;

  /// No description provided for @matchMosque.
  ///
  /// In en, this message translates to:
  /// **'Match my mosque'**
  String get matchMosque;

  /// No description provided for @matchMosqueSub.
  ///
  /// In en, this message translates to:
  /// **'Shift all times to its timetable'**
  String get matchMosqueSub;

  /// No description provided for @perPrayerOffsets.
  ///
  /// In en, this message translates to:
  /// **'Adjust each prayer'**
  String get perPrayerOffsets;

  /// No description provided for @offsetMinutes.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String offsetMinutes(String value);

  /// No description provided for @secAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get secAlerts;

  /// No description provided for @alertAdhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get alertAdhan;

  /// No description provided for @alertSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get alertSilent;

  /// No description provided for @alertOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get alertOff;

  /// No description provided for @secGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get secGeneral;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @periodMode.
  ///
  /// In en, this message translates to:
  /// **'Period mode'**
  String get periodMode;

  /// No description provided for @periodModeSub.
  ///
  /// In en, this message translates to:
  /// **'Pauses prayer alerts. Streaks stay intact.'**
  String get periodModeSub;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeAuto;

  /// No description provided for @widgets.
  ///
  /// In en, this message translates to:
  /// **'Widgets'**
  String get widgets;

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'No account, no ads. Everything stays on this phone.'**
  String get privacyNote;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Waqt {version}'**
  String versionLabel(String version);

  /// No description provided for @hijriAdjust.
  ///
  /// In en, this message translates to:
  /// **'Hijri date'**
  String get hijriAdjust;

  /// No description provided for @hijriAdjustSub.
  ///
  /// In en, this message translates to:
  /// **'Match your local moon sighting'**
  String get hijriAdjustSub;

  /// No description provided for @hijriAdjustNone.
  ///
  /// In en, this message translates to:
  /// **'No adjustment'**
  String get hijriAdjustNone;

  /// No description provided for @adhkarReminders.
  ///
  /// In en, this message translates to:
  /// **'Adhkar reminders'**
  String get adhkarReminders;

  /// No description provided for @adhkarRemindersSub.
  ///
  /// In en, this message translates to:
  /// **'Morning after Fajr, evening after Asr'**
  String get adhkarRemindersSub;

  /// No description provided for @secRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get secRamadan;

  /// No description provided for @secNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get secNotifications;

  /// No description provided for @notifPermissionOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for Waqt. Turn them on in system settings.'**
  String get notifPermissionOff;

  /// No description provided for @exactAlarmOff.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms are off, so alerts may arrive a few minutes late.'**
  String get exactAlarmOff;

  /// No description provided for @allowExact.
  ///
  /// In en, this message translates to:
  /// **'Allow exact alarms'**
  String get allowExact;

  /// No description provided for @methodMwl.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get methodMwl;

  /// No description provided for @methodEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority'**
  String get methodEgyptian;

  /// No description provided for @methodKarachi.
  ///
  /// In en, this message translates to:
  /// **'University of Islamic Sciences, Karachi'**
  String get methodKarachi;

  /// No description provided for @methodUmmAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura, Makkah'**
  String get methodUmmAlQura;

  /// No description provided for @methodDubai.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get methodDubai;

  /// No description provided for @methodMoonSighting.
  ///
  /// In en, this message translates to:
  /// **'Moonsighting Committee'**
  String get methodMoonSighting;

  /// No description provided for @methodNorthAmerica.
  ///
  /// In en, this message translates to:
  /// **'ISNA (North America)'**
  String get methodNorthAmerica;

  /// No description provided for @methodKuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get methodKuwait;

  /// No description provided for @methodQatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get methodQatar;

  /// No description provided for @methodSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get methodSingapore;

  /// No description provided for @methodTurkey.
  ///
  /// In en, this message translates to:
  /// **'Diyanet (Turkey)'**
  String get methodTurkey;

  /// No description provided for @methodTehran.
  ///
  /// In en, this message translates to:
  /// **'Tehran'**
  String get methodTehran;

  /// No description provided for @widgetsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Home-screen widgets'**
  String get widgetsHelpTitle;

  /// No description provided for @widgetsHelpIos.
  ///
  /// In en, this message translates to:
  /// **'Touch and hold an empty area of the Home Screen, tap +, search for Waqt and choose the small, medium or lock-screen widget.'**
  String get widgetsHelpIos;

  /// No description provided for @widgetsHelpAndroid.
  ///
  /// In en, this message translates to:
  /// **'Touch and hold an empty area of the home screen, tap Widgets, find Waqt and drag the widget onto the screen. Its button marks the current prayer.'**
  String get widgetsHelpAndroid;

  /// No description provided for @widgetsHelpData.
  ///
  /// In en, this message translates to:
  /// **'Widgets show the next seven days of times even if you don\'t open the app.'**
  String get widgetsHelpData;

  /// No description provided for @widgetNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get widgetNext;

  /// No description provided for @widgetWindowOpen.
  ///
  /// In en, this message translates to:
  /// **'{prayer} · window open'**
  String widgetWindowOpen(String prayer);

  /// No description provided for @widgetMarkPrayed.
  ///
  /// In en, this message translates to:
  /// **'Mark as prayed'**
  String get widgetMarkPrayed;

  /// No description provided for @widgetMarked.
  ///
  /// In en, this message translates to:
  /// **'{prayer} marked'**
  String widgetMarked(String prayer);

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationTitle;

  /// No description provided for @locationUseCurrent.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get locationUseCurrent;

  /// No description provided for @locationSearch.
  ///
  /// In en, this message translates to:
  /// **'Search a city'**
  String get locationSearch;

  /// No description provided for @locationCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Enter coordinates'**
  String get locationCoordinates;

  /// No description provided for @locationLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get locationLatitude;

  /// No description provided for @locationLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get locationLongitude;

  /// No description provided for @locationName.
  ///
  /// In en, this message translates to:
  /// **'Place name'**
  String get locationName;

  /// No description provided for @locationLocating.
  ///
  /// In en, this message translates to:
  /// **'Finding you…'**
  String get locationLocating;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. Choose a city instead.'**
  String get locationDenied;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your location. Choose a city instead.'**
  String get locationFailed;

  /// No description provided for @locationNearby.
  ///
  /// In en, this message translates to:
  /// **'Near {city}'**
  String locationNearby(String city);

  /// No description provided for @locationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid latitude and longitude.'**
  String get locationInvalid;

  /// No description provided for @locationPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your location is used only to calculate prayer times and the Qibla. It never leaves this phone.'**
  String get locationPrivacy;

  /// No description provided for @obGreeting.
  ///
  /// In en, this message translates to:
  /// **'As-salāmu ʿalaykum'**
  String get obGreeting;

  /// No description provided for @obLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get obLanguageTitle;

  /// No description provided for @obLanguageSub.
  ///
  /// In en, this message translates to:
  /// **'You can change it later in Settings.'**
  String get obLanguageSub;

  /// No description provided for @obLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you pray?'**
  String get obLocationTitle;

  /// No description provided for @obMethodLine.
  ///
  /// In en, this message translates to:
  /// **'{method} · {madhab} Asr'**
  String obMethodLine(String method, String madhab);

  /// No description provided for @obAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get obAdvanced;

  /// No description provided for @obNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Never miss a prayer'**
  String get obNotifTitle;

  /// No description provided for @obNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Get a gentle alert at each prayer time. Choose adhan, silent or off for each prayer later.'**
  String get obNotifBody;

  /// No description provided for @obAllowNotif.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get obAllowNotif;

  /// No description provided for @obNotifAllowed.
  ///
  /// In en, this message translates to:
  /// **'Notifications are on'**
  String get obNotifAllowed;

  /// No description provided for @obBatteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep alerts on time'**
  String get obBatteryTitle;

  /// No description provided for @obBatteryBody.
  ///
  /// In en, this message translates to:
  /// **'Some Android phones pause apps to save battery. Set Waqt to \"Unrestricted\" in battery settings so the adhan is never late.'**
  String get obBatteryBody;

  /// No description provided for @obOpenBattery.
  ///
  /// In en, this message translates to:
  /// **'Open battery settings'**
  String get obOpenBattery;

  /// No description provided for @obStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get obStart;

  /// No description provided for @obPrivacy.
  ///
  /// In en, this message translates to:
  /// **'No account. No ads. Everything stays on this phone.'**
  String get obPrivacy;

  /// No description provided for @notifPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'{prayer} · {time}'**
  String notifPrayerTitle(String prayer, String time);

  /// No description provided for @notifPrayerBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s time for {prayer} in {place}.'**
  String notifPrayerBody(String prayer, String place);

  /// No description provided for @notifRemindTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder · {prayer}'**
  String notifRemindTitle(String prayer);

  /// No description provided for @notifRemindBody.
  ///
  /// In en, this message translates to:
  /// **'You asked to be reminded to pray {prayer}.'**
  String notifRemindBody(String prayer);

  /// No description provided for @notifMorningBody.
  ///
  /// In en, this message translates to:
  /// **'A few minutes of remembrance to start the day.'**
  String get notifMorningBody;

  /// No description provided for @notifEveningBody.
  ///
  /// In en, this message translates to:
  /// **'A few minutes of remembrance before evening.'**
  String get notifEveningBody;

  /// No description provided for @notifSuhoorTitle.
  ///
  /// In en, this message translates to:
  /// **'Suhoor ends at {time}'**
  String notifSuhoorTitle(String time);

  /// No description provided for @notifSuhoorBody.
  ///
  /// In en, this message translates to:
  /// **'{min} minutes until Fajr.'**
  String notifSuhoorBody(String min);

  /// No description provided for @notifIftarTitle.
  ///
  /// In en, this message translates to:
  /// **'Iftar time'**
  String get notifIftarTitle;

  /// No description provided for @notifIftarBody.
  ///
  /// In en, this message translates to:
  /// **'Maghrib has come in {place}. May Allah accept your fast.'**
  String notifIftarBody(String place);

  /// No description provided for @chanAdhan.
  ///
  /// In en, this message translates to:
  /// **'Prayer times · adhan'**
  String get chanAdhan;

  /// No description provided for @chanStandard.
  ///
  /// In en, this message translates to:
  /// **'Prayer times · standard sound'**
  String get chanStandard;

  /// No description provided for @chanReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get chanReminders;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'tk', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tk':
      return AppLocalizationsTk();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
