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

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

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

  /// No description provided for @homePrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get homePrayerTimes;

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

  /// No description provided for @homeWorshipTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s worship'**
  String get homeWorshipTitle;

  /// No description provided for @homeWorshipHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the ones you completed'**
  String get homeWorshipHint;

  /// No description provided for @homePrayers.
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get homePrayers;

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
  /// **'{window} · ≈{min} min read'**
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

  /// No description provided for @expenseAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get expenseAddCategory;

  /// No description provided for @expenseCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get expenseCategoryName;

  /// No description provided for @expenseCategoryExists.
  ///
  /// In en, this message translates to:
  /// **'This category already exists.'**
  String get expenseCategoryExists;

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
  /// **'Eating out'**
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

  /// No description provided for @calendarTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer times & tracker'**
  String get calendarTrackerTitle;

  /// No description provided for @calendarOpenTracker.
  ///
  /// In en, this message translates to:
  /// **'Open prayer tracker'**
  String get calendarOpenTracker;

  /// No description provided for @calendarTogglePrayer.
  ///
  /// In en, this message translates to:
  /// **'Mark {prayer} as prayed'**
  String calendarTogglePrayer(String prayer);

  /// No description provided for @calendarFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get calendarFast;

  /// No description provided for @calendarToggleFast.
  ///
  /// In en, this message translates to:
  /// **'Mark the fast as kept'**
  String get calendarToggleFast;

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

  /// No description provided for @fastTypeQada.
  ///
  /// In en, this message translates to:
  /// **'Make-up fast'**
  String get fastTypeQada;

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
  /// **'Calendar'**
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
  /// **'Sound'**
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
  /// **'Touch and hold an empty area of the Home Screen, tap +, search for Waqt and choose the small, medium, large or lock-screen widget.'**
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

  /// No description provided for @widgetRemainingTime.
  ///
  /// In en, this message translates to:
  /// **'Remaining time'**
  String get widgetRemainingTime;

  /// No description provided for @widgetTodayRecord.
  ///
  /// In en, this message translates to:
  /// **'Today\'s record'**
  String get widgetTodayRecord;

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

  /// No description provided for @tabQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get tabQuran;

  /// No description provided for @tabLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get tabLibrary;

  /// No description provided for @quranTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quranTitle;

  /// No description provided for @quranContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get quranContinue;

  /// No description provided for @quranStart.
  ///
  /// In en, this message translates to:
  /// **'Start reading'**
  String get quranStart;

  /// No description provided for @quranStartHint.
  ///
  /// In en, this message translates to:
  /// **'Begin with Al-Fatihah, the Opening.'**
  String get quranStartHint;

  /// No description provided for @quranAyahN.
  ///
  /// In en, this message translates to:
  /// **'Ayah {n}'**
  String quranAyahN(String n);

  /// No description provided for @quranPageN.
  ///
  /// In en, this message translates to:
  /// **'Page {n}'**
  String quranPageN(String n);

  /// No description provided for @quranJuzN.
  ///
  /// In en, this message translates to:
  /// **'Juz {n}'**
  String quranJuzN(String n);

  /// No description provided for @quranSurahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get quranSurahs;

  /// No description provided for @quranJuzTab.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get quranJuzTab;

  /// No description provided for @quranAyahCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} ayah} other{{count} ayahs}}'**
  String quranAyahCount(int count);

  /// No description provided for @quranMeccan.
  ///
  /// In en, this message translates to:
  /// **'Meccan'**
  String get quranMeccan;

  /// No description provided for @quranMedinan.
  ///
  /// In en, this message translates to:
  /// **'Medinan'**
  String get quranMedinan;

  /// No description provided for @quranSearch.
  ///
  /// In en, this message translates to:
  /// **'Search the Quran'**
  String get quranSearch;

  /// No description provided for @quranSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Surah, 2:255 or any words'**
  String get quranSearchHint;

  /// No description provided for @quranGoTo.
  ///
  /// In en, this message translates to:
  /// **'Go to {ref}'**
  String quranGoTo(String ref);

  /// No description provided for @quranNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matches. Try fewer words or Arabic.'**
  String get quranNoResults;

  /// No description provided for @quranResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} ayah} other{{count} ayahs}}'**
  String quranResults(int count);

  /// No description provided for @quranSearchIn.
  ///
  /// In en, this message translates to:
  /// **'Searching Arabic and {translation}'**
  String quranSearchIn(String translation);

  /// No description provided for @quranBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get quranBookmarks;

  /// No description provided for @quranNoBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet. Long-press an ayah or tap ••• to save it here.'**
  String get quranNoBookmarks;

  /// No description provided for @quranBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get quranBookmark;

  /// No description provided for @quranRemoveBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get quranRemoveBookmark;

  /// No description provided for @quranRemoveNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this bookmark and its note?'**
  String get quranRemoveNoteConfirm;

  /// No description provided for @translationLabel.
  ///
  /// In en, this message translates to:
  /// **'Translation: {name}'**
  String translationLabel(String name);

  /// No description provided for @quranBookmarked.
  ///
  /// In en, this message translates to:
  /// **'Saved to bookmarks'**
  String get quranBookmarked;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreActions;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @shareImage.
  ///
  /// In en, this message translates to:
  /// **'Share as image'**
  String get shareImage;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Share text'**
  String get shareText;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @quranAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get quranAddNote;

  /// No description provided for @quranNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What does this ayah mean to you?'**
  String get quranNoteHint;

  /// No description provided for @quranSetLastRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as where I stopped'**
  String get quranSetLastRead;

  /// No description provided for @quranReadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Reading settings'**
  String get quranReadingSettings;

  /// No description provided for @quranArabicSize.
  ///
  /// In en, this message translates to:
  /// **'Arabic size'**
  String get quranArabicSize;

  /// No description provided for @quranTextSize.
  ///
  /// In en, this message translates to:
  /// **'Translation size'**
  String get quranTextSize;

  /// No description provided for @quranShowTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show translation'**
  String get quranShowTranslation;

  /// No description provided for @quranShowTranslit.
  ///
  /// In en, this message translates to:
  /// **'Show transliteration'**
  String get quranShowTranslit;

  /// No description provided for @quranTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get quranTranslation;

  /// No description provided for @quranArabicFont.
  ///
  /// In en, this message translates to:
  /// **'Arabic script'**
  String get quranArabicFont;

  /// No description provided for @quranFontUthmani.
  ///
  /// In en, this message translates to:
  /// **'Uthmani'**
  String get quranFontUthmani;

  /// No description provided for @quranFontNaskh.
  ///
  /// In en, this message translates to:
  /// **'Naskh (plain)'**
  String get quranFontNaskh;

  /// No description provided for @quranSepia.
  ///
  /// In en, this message translates to:
  /// **'Warm paper'**
  String get quranSepia;

  /// No description provided for @quranKeepAwake.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on while reading'**
  String get quranKeepAwake;

  /// No description provided for @quranMemorize.
  ///
  /// In en, this message translates to:
  /// **'Memorize mode'**
  String get quranMemorize;

  /// No description provided for @quranMemorizeHint.
  ///
  /// In en, this message translates to:
  /// **'Arabic is hidden. Recite, then tap to check.'**
  String get quranMemorizeHint;

  /// No description provided for @quranTapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get quranTapToReveal;

  /// No description provided for @quranModeList.
  ///
  /// In en, this message translates to:
  /// **'Translation view'**
  String get quranModeList;

  /// No description provided for @quranModePage.
  ///
  /// In en, this message translates to:
  /// **'Mushaf pages'**
  String get quranModePage;

  /// No description provided for @quranSajda.
  ///
  /// In en, this message translates to:
  /// **'Sajdah'**
  String get quranSajda;

  /// No description provided for @quranToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get quranToday;

  /// No description provided for @quranGoal.
  ///
  /// In en, this message translates to:
  /// **'{read} of {goal} ayahs'**
  String quranGoal(String read, String goal);

  /// No description provided for @quranGoalPages.
  ///
  /// In en, this message translates to:
  /// **'{read} of {goal} pages'**
  String quranGoalPages(String read, String goal);

  /// No description provided for @khatmLast14.
  ///
  /// In en, this message translates to:
  /// **'Last 14 days'**
  String get khatmLast14;

  /// No description provided for @quranGoalDone.
  ///
  /// In en, this message translates to:
  /// **'Daily goal reached'**
  String get quranGoalDone;

  /// No description provided for @quranStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Start a streak today} one{{count} day in a row} other{{count} days in a row}}'**
  String quranStreak(int count);

  /// No description provided for @quranDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get quranDailyGoal;

  /// No description provided for @quranDailyGoalValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} ayah a day} other{{count} ayahs a day}}'**
  String quranDailyGoalValue(int count);

  /// No description provided for @quranReadTracking.
  ///
  /// In en, this message translates to:
  /// **'Ayahs count as read after you spend a moment on them.'**
  String get quranReadTracking;

  /// No description provided for @quranOfDay.
  ///
  /// In en, this message translates to:
  /// **'Ayah of the day'**
  String get quranOfDay;

  /// No description provided for @quranOpenInReader.
  ///
  /// In en, this message translates to:
  /// **'Open in Quran'**
  String get quranOpenInReader;

  /// No description provided for @quranSurahInfo.
  ///
  /// In en, this message translates to:
  /// **'{place} · {ayahs}'**
  String quranSurahInfo(String place, String ayahs);

  /// No description provided for @quranNextSurah.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}'**
  String quranNextSurah(String name);

  /// No description provided for @quranLoading.
  ///
  /// In en, this message translates to:
  /// **'Opening the Quran…'**
  String get quranLoading;

  /// No description provided for @quranReadSurah.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get quranReadSurah;

  /// No description provided for @khatmTitle.
  ///
  /// In en, this message translates to:
  /// **'Khatm plan'**
  String get khatmTitle;

  /// No description provided for @khatmShort.
  ///
  /// In en, this message translates to:
  /// **'Khatm'**
  String get khatmShort;

  /// No description provided for @khatmIntro.
  ///
  /// In en, this message translates to:
  /// **'Read the whole Quran at your pace. Waqt spreads what’s left over the remaining days, so a missed day never ruins the plan.'**
  String get khatmIntro;

  /// No description provided for @khatmChoose.
  ///
  /// In en, this message translates to:
  /// **'Finish in'**
  String get khatmChoose;

  /// No description provided for @khatmDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String khatmDays(int count);

  /// No description provided for @khatmPerDay.
  ///
  /// In en, this message translates to:
  /// **'≈ {pages} pages a day'**
  String khatmPerDay(String pages);

  /// No description provided for @khatmStart.
  ///
  /// In en, this message translates to:
  /// **'Start plan'**
  String get khatmStart;

  /// No description provided for @khatmDayOf.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {total}'**
  String khatmDayOf(String day, String total);

  /// No description provided for @khatmTodayTarget.
  ///
  /// In en, this message translates to:
  /// **'Today: {pages} pages, from {from}'**
  String khatmTodayTarget(String pages, String from);

  /// No description provided for @khatmTodayDone.
  ///
  /// In en, this message translates to:
  /// **'Today’s portion is done. Barakallahu fik!'**
  String get khatmTodayDone;

  /// No description provided for @khatmBehind.
  ///
  /// In en, this message translates to:
  /// **'A little behind — today’s portion is a bit bigger.'**
  String get khatmBehind;

  /// No description provided for @khatmOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get khatmOnTrack;

  /// No description provided for @khatmEnd.
  ///
  /// In en, this message translates to:
  /// **'End plan'**
  String get khatmEnd;

  /// No description provided for @khatmEndConfirm.
  ///
  /// In en, this message translates to:
  /// **'End this plan? Your reading history stays.'**
  String get khatmEndConfirm;

  /// No description provided for @khatmComplete.
  ///
  /// In en, this message translates to:
  /// **'Khatm complete! May Allah accept it from you.'**
  String get khatmComplete;

  /// No description provided for @khatmProgress.
  ///
  /// In en, this message translates to:
  /// **'{read} of {total} pages'**
  String khatmProgress(String read, String total);

  /// No description provided for @khatmDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Last day} one{{count} day left} other{{count} days left}}'**
  String khatmDaysLeft(int count);

  /// No description provided for @khatmRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get khatmRamadan;

  /// No description provided for @khatmNewPlan.
  ///
  /// In en, this message translates to:
  /// **'Start a new plan'**
  String get khatmNewPlan;

  /// No description provided for @khatmShareText.
  ///
  /// In en, this message translates to:
  /// **'I completed a khatm of the Quran with Waqt. Alhamdulillah!'**
  String get khatmShareText;

  /// No description provided for @khatmReminder.
  ///
  /// In en, this message translates to:
  /// **'Remind me after Isha'**
  String get khatmReminder;

  /// No description provided for @notifQuranTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s Quran'**
  String get notifQuranTitle;

  /// No description provided for @notifQuranBody.
  ///
  /// In en, this message translates to:
  /// **'A few minutes with the Quran before sleep.'**
  String get notifQuranBody;

  /// No description provided for @hifzTitle.
  ///
  /// In en, this message translates to:
  /// **'Memorize'**
  String get hifzTitle;

  /// No description provided for @hifzIntro.
  ///
  /// In en, this message translates to:
  /// **'Add surahs you’re memorizing. Review each on a spaced schedule — 1, 3, 7, 14, 30 and 90 days — so it stays strong.'**
  String get hifzIntro;

  /// No description provided for @hifzAdd.
  ///
  /// In en, this message translates to:
  /// **'Add surah'**
  String get hifzAdd;

  /// No description provided for @hifzDue.
  ///
  /// In en, this message translates to:
  /// **'Due for review'**
  String get hifzDue;

  /// No description provided for @hifzUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get hifzUpcoming;

  /// No description provided for @hifzReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get hifzReview;

  /// No description provided for @hifzHowWent.
  ///
  /// In en, this message translates to:
  /// **'How did the review go?'**
  String get hifzHowWent;

  /// No description provided for @hifzStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get hifzStrong;

  /// No description provided for @hifzWeak.
  ///
  /// In en, this message translates to:
  /// **'Shaky'**
  String get hifzWeak;

  /// No description provided for @hifzNext.
  ///
  /// In en, this message translates to:
  /// **'Next review {date}'**
  String hifzNext(String date);

  /// No description provided for @hifzEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing on your list yet. Short surahs from Juz ʿAmma are a great start.'**
  String get hifzEmpty;

  /// No description provided for @hifzRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get hifzRemove;

  /// No description provided for @hifzSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get hifzSuggested;

  /// No description provided for @hifzAllSurahs.
  ///
  /// In en, this message translates to:
  /// **'All surahs'**
  String get hifzAllSurahs;

  /// No description provided for @hifzTileIdle.
  ///
  /// In en, this message translates to:
  /// **'Spaced review'**
  String get hifzTileIdle;

  /// No description provided for @hifzDueCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} due today} other{{count} due today}}'**
  String hifzDueCount(int count);

  /// No description provided for @khatmTileIdle.
  ///
  /// In en, this message translates to:
  /// **'Finish on a schedule'**
  String get khatmTileIdle;

  /// No description provided for @hifzAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get hifzAgain;

  /// No description provided for @quranJumpTo.
  ///
  /// In en, this message translates to:
  /// **'Jump to surah, juz or page'**
  String get quranJumpTo;

  /// No description provided for @quranPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get quranPages;

  /// No description provided for @hifzMemorized.
  ///
  /// In en, this message translates to:
  /// **'Memorized'**
  String get hifzMemorized;

  /// No description provided for @libraryHadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith collections'**
  String get libraryHadith;

  /// No description provided for @libraryDuas.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get libraryDuas;

  /// No description provided for @libraryDuasSub.
  ///
  /// In en, this message translates to:
  /// **'For every moment of the day'**
  String get libraryDuasSub;

  /// No description provided for @libraryNames.
  ///
  /// In en, this message translates to:
  /// **'99 Names of Allah'**
  String get libraryNames;

  /// No description provided for @libraryNamesSub.
  ///
  /// In en, this message translates to:
  /// **'Asmaʾ al-Husna'**
  String get libraryNamesSub;

  /// No description provided for @libraryLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get libraryLearn;

  /// No description provided for @libraryLearnSub.
  ///
  /// In en, this message translates to:
  /// **'Prayer, wudu, fasting and more'**
  String get libraryLearnSub;

  /// No description provided for @libraryAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Morning & evening adhkar'**
  String get libraryAdhkar;

  /// No description provided for @librarySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get librarySaved;

  /// No description provided for @librarySavedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Bookmark a hadith, dua or Name and it will appear here.'**
  String get librarySavedEmpty;

  /// No description provided for @libraryContentReview.
  ///
  /// In en, this message translates to:
  /// **'Texts are compiled from classical sources. Please verify with a scholar when in doubt.'**
  String get libraryContentReview;

  /// No description provided for @hadithTitle.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get hadithTitle;

  /// No description provided for @hadithOfDay.
  ///
  /// In en, this message translates to:
  /// **'Hadith of the day'**
  String get hadithOfDay;

  /// No description provided for @hadithBookNawawi.
  ///
  /// In en, this message translates to:
  /// **'40 Hadith of an-Nawawi'**
  String get hadithBookNawawi;

  /// No description provided for @hadithBookQudsi.
  ///
  /// In en, this message translates to:
  /// **'40 Hadith Qudsi'**
  String get hadithBookQudsi;

  /// No description provided for @hadithBookBukhari.
  ///
  /// In en, this message translates to:
  /// **'Sahih al-Bukhari'**
  String get hadithBookBukhari;

  /// No description provided for @hadithBookMuslim.
  ///
  /// In en, this message translates to:
  /// **'Sahih Muslim'**
  String get hadithBookMuslim;

  /// No description provided for @hadithCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} hadith} other{{count} hadith}}'**
  String hadithCount(int count);

  /// No description provided for @hadithN.
  ///
  /// In en, this message translates to:
  /// **'Hadith {n}'**
  String hadithN(String n);

  /// No description provided for @hadithBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get hadithBooks;

  /// No description provided for @hadithSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search words or a number'**
  String get hadithSearchHint;

  /// No description provided for @hadithSearchAll.
  ///
  /// In en, this message translates to:
  /// **'Search hadith'**
  String get hadithSearchAll;

  /// No description provided for @hadithSearchAllHint.
  ///
  /// In en, this message translates to:
  /// **'Words in any collection'**
  String get hadithSearchAllHint;

  /// No description provided for @hadithShowArabic.
  ///
  /// In en, this message translates to:
  /// **'Show Arabic text'**
  String get hadithShowArabic;

  /// No description provided for @hadithTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get hadithTranslation;

  /// No description provided for @quranMushafStyle.
  ///
  /// In en, this message translates to:
  /// **'Mushaf style'**
  String get quranMushafStyle;

  /// No description provided for @quranMushafStyleSub.
  ///
  /// In en, this message translates to:
  /// **'Parchment page, 15-line Madani layout (page view), pink “Allah”, gold verse markers'**
  String get quranMushafStyleSub;

  /// No description provided for @quranTajweed.
  ///
  /// In en, this message translates to:
  /// **'Tajweed colors'**
  String get quranTajweed;

  /// No description provided for @quranTajweedSub.
  ///
  /// In en, this message translates to:
  /// **'Colors the recitation rules (ghunna, madd, qalqala…)'**
  String get quranTajweedSub;

  /// No description provided for @searchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Results for “{query}”'**
  String searchResultsFor(String query);

  /// No description provided for @searchNoneFor.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”'**
  String searchNoneFor(String query);

  /// No description provided for @hadithNoResults.
  ///
  /// In en, this message translates to:
  /// **'No hadith found.'**
  String get hadithNoResults;

  /// No description provided for @hadithFallback.
  ///
  /// In en, this message translates to:
  /// **'Not available in your language — showing English.'**
  String get hadithFallback;

  /// No description provided for @hadithRange.
  ///
  /// In en, this message translates to:
  /// **'Hadith {from}–{to}'**
  String hadithRange(String from, String to);

  /// No description provided for @hadithOpenBook.
  ///
  /// In en, this message translates to:
  /// **'Read the collection'**
  String get hadithOpenBook;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get langRussian;

  /// No description provided for @langTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get langTurkish;

  /// No description provided for @duaSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search duas'**
  String get duaSearchHint;

  /// No description provided for @duaRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat {count}×'**
  String duaRepeat(String count);

  /// No description provided for @duaAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get duaAll;

  /// No description provided for @duaFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get duaFavorites;

  /// No description provided for @namesQuiz.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get namesQuiz;

  /// No description provided for @namesQuizQuestion.
  ///
  /// In en, this message translates to:
  /// **'What does this Name mean?'**
  String get namesQuizQuestion;

  /// No description provided for @namesQuizScore.
  ///
  /// In en, this message translates to:
  /// **'{right} of {total} correct'**
  String namesQuizScore(String right, String total);

  /// No description provided for @namesQuizNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get namesQuizNext;

  /// No description provided for @namesQuizAgain.
  ///
  /// In en, this message translates to:
  /// **'Practice again'**
  String get namesQuizAgain;

  /// No description provided for @namesLearned.
  ///
  /// In en, this message translates to:
  /// **'{count} of 99 learned'**
  String namesLearned(String count);

  /// No description provided for @namesHadith.
  ///
  /// In en, this message translates to:
  /// **'“Allah has ninety-nine names; whoever learns them will enter Paradise.” — Bukhari & Muslim'**
  String get namesHadith;

  /// No description provided for @learnSteps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} step} other{{count} steps}}'**
  String learnSteps(int count);

  /// No description provided for @learnStepN.
  ///
  /// In en, this message translates to:
  /// **'Step {n}'**
  String learnStepN(String n);

  /// No description provided for @meQuranStreak.
  ///
  /// In en, this message translates to:
  /// **'Quran streak'**
  String get meQuranStreak;

  /// No description provided for @meQuranDaily.
  ///
  /// In en, this message translates to:
  /// **'reading every day'**
  String get meQuranDaily;

  /// No description provided for @mePrayedToday.
  ///
  /// In en, this message translates to:
  /// **'prayed today'**
  String get mePrayedToday;

  /// No description provided for @meStartStreak.
  ///
  /// In en, this message translates to:
  /// **'Pray all five today to start your streak'**
  String get meStartStreak;

  /// No description provided for @meStreakShare.
  ///
  /// In en, this message translates to:
  /// **'Five prayers a day, with Waqt'**
  String get meStreakShare;

  /// No description provided for @meSettingsRow.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get meSettingsRow;

  /// No description provided for @habitsEmptyShort.
  ///
  /// In en, this message translates to:
  /// **'Build a small daily habit'**
  String get habitsEmptyShort;

  /// No description provided for @homeAddExpenseShort.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get homeAddExpenseShort;

  /// No description provided for @qadaMadeUpSnack.
  ///
  /// In en, this message translates to:
  /// **'{prayer}: one made up'**
  String qadaMadeUpSnack(String prayer);

  /// No description provided for @qadaYearsHelper.
  ///
  /// In en, this message translates to:
  /// **'I missed about…'**
  String get qadaYearsHelper;

  /// No description provided for @qadaMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} month} other{{count} months}}'**
  String qadaMonths(int count);

  /// No description provided for @qadaYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} year} other{{count} years}}'**
  String qadaYears(int count);

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get expensesTitle;

  /// No description provided for @expensesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No spending recorded this month.'**
  String get expensesEmpty;

  /// No description provided for @incomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeTitle;

  /// No description provided for @incomeAdd.
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get incomeAdd;

  /// No description provided for @incomeSaved.
  ///
  /// In en, this message translates to:
  /// **'Income saved'**
  String get incomeSaved;

  /// No description provided for @incomeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Income deleted'**
  String get incomeDeleted;

  /// No description provided for @incomeSave.
  ///
  /// In en, this message translates to:
  /// **'Save {amount} {currency}'**
  String incomeSave(String amount, String currency);

  /// No description provided for @incomeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No income recorded this month.'**
  String get incomeEmpty;

  /// No description provided for @catSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get catSalary;

  /// No description provided for @catBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get catBusiness;

  /// No description provided for @catGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get catGift;

  /// No description provided for @catInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get catInvestment;

  /// No description provided for @transactionExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transactionExpense;

  /// No description provided for @transactionIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionIncome;

  /// No description provided for @financeTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending & Income'**
  String get financeTitle;

  /// No description provided for @netBalance.
  ///
  /// In en, this message translates to:
  /// **'Net balance'**
  String get netBalance;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get totalIncome;

  /// No description provided for @totalExpense.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get totalExpense;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get filterExpenses;

  /// No description provided for @filterIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get filterIncome;

  /// No description provided for @todayIncome.
  ///
  /// In en, this message translates to:
  /// **'Income today'**
  String get todayIncome;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions recorded this month.'**
  String get noTransactions;

  /// No description provided for @categoryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get categoryDelete;

  /// No description provided for @categoryDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? Existing transactions will keep this name.'**
  String categoryDeleteConfirm(String name);

  /// No description provided for @meAyahsRead.
  ///
  /// In en, this message translates to:
  /// **'Ayahs read'**
  String get meAyahsRead;

  /// No description provided for @notifTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a test alert'**
  String get notifTestTitle;

  /// No description provided for @notifTestSub.
  ///
  /// In en, this message translates to:
  /// **'Arrives in 5 seconds — lock your phone to check sound and banner.'**
  String get notifTestSub;

  /// No description provided for @notifTestBody.
  ///
  /// In en, this message translates to:
  /// **'If you can see and hear this, prayer alerts will work.'**
  String get notifTestBody;

  /// No description provided for @notifTestSent.
  ///
  /// In en, this message translates to:
  /// **'Test alert on its way…'**
  String get notifTestSent;

  /// No description provided for @fastsOwedTitle.
  ///
  /// In en, this message translates to:
  /// **'Fasts to make up'**
  String get fastsOwedTitle;

  /// No description provided for @fastsOwedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All made up — alhamdulillah} one{{count} day} other{{count} days}}'**
  String fastsOwedCount(int count);

  /// No description provided for @fastsOwedSub.
  ///
  /// In en, this message translates to:
  /// **'Missed or excused Ramadan days, minus make-up fasts you log.'**
  String get fastsOwedSub;

  /// No description provided for @fastsLogQada.
  ///
  /// In en, this message translates to:
  /// **'I fasted a make-up day today'**
  String get fastsLogQada;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupTitle;

  /// No description provided for @backupRowSub.
  ///
  /// In en, this message translates to:
  /// **'Move your data to a new phone'**
  String get backupRowSub;

  /// No description provided for @backupIntro.
  ///
  /// In en, this message translates to:
  /// **'Waqt has no account and no cloud. Export a backup file and keep it safe (Files, Telegram “Saved messages”, email to yourself). Restore it on any phone.'**
  String get backupIntro;

  /// No description provided for @backupExport.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get backupExport;

  /// No description provided for @backupImport.
  ///
  /// In en, this message translates to:
  /// **'Restore from file'**
  String get backupImport;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupRestore;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all data?'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'Everything on this phone will be replaced by the backup.'**
  String get backupRestoreBody;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored. Welcome back!'**
  String get backupRestored;

  /// No description provided for @backupNever.
  ///
  /// In en, this message translates to:
  /// **'No backup yet'**
  String get backupNever;

  /// No description provided for @backupLast.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String backupLast(String date);

  /// No description provided for @backupInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file isn’t a Waqt backup.'**
  String get backupInvalid;

  /// No description provided for @zakatTitle.
  ///
  /// In en, this message translates to:
  /// **'Zakat calculator'**
  String get zakatTitle;

  /// No description provided for @zakatShort.
  ///
  /// In en, this message translates to:
  /// **'Zakat'**
  String get zakatShort;

  /// No description provided for @zakatDue.
  ///
  /// In en, this message translates to:
  /// **'Zakat due'**
  String get zakatDue;

  /// No description provided for @zakatAbove.
  ///
  /// In en, this message translates to:
  /// **'Above nisab — 2.5% is due.'**
  String get zakatAbove;

  /// No description provided for @zakatBelow.
  ///
  /// In en, this message translates to:
  /// **'Below nisab — no zakat is due.'**
  String get zakatBelow;

  /// No description provided for @zakatNeedPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter today’s gold or silver price to find the nisab.'**
  String get zakatNeedPrice;

  /// No description provided for @zakatWealth.
  ///
  /// In en, this message translates to:
  /// **'Zakatable wealth'**
  String get zakatWealth;

  /// No description provided for @zakatNisab.
  ///
  /// In en, this message translates to:
  /// **'Nisab'**
  String get zakatNisab;

  /// No description provided for @zakatNisabBasis.
  ///
  /// In en, this message translates to:
  /// **'Nisab based on'**
  String get zakatNisabBasis;

  /// No description provided for @zakatNisabGold.
  ///
  /// In en, this message translates to:
  /// **'Gold · 85 g'**
  String get zakatNisabGold;

  /// No description provided for @zakatNisabSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver · 595 g'**
  String get zakatNisabSilver;

  /// No description provided for @zakatPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Waqt never goes online — type today’s local price per gram.'**
  String get zakatPriceHint;

  /// No description provided for @zakatGoldPrice.
  ///
  /// In en, this message translates to:
  /// **'Gold price'**
  String get zakatGoldPrice;

  /// No description provided for @zakatSilverPrice.
  ///
  /// In en, this message translates to:
  /// **'Silver price'**
  String get zakatSilverPrice;

  /// No description provided for @zakatPerGram.
  ///
  /// In en, this message translates to:
  /// **'per gram'**
  String get zakatPerGram;

  /// No description provided for @zakatGrams.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get zakatGrams;

  /// No description provided for @zakatAssets.
  ///
  /// In en, this message translates to:
  /// **'What you own'**
  String get zakatAssets;

  /// No description provided for @zakatLiabilities.
  ///
  /// In en, this message translates to:
  /// **'What you owe now'**
  String get zakatLiabilities;

  /// No description provided for @zakatCash.
  ///
  /// In en, this message translates to:
  /// **'Cash & bank'**
  String get zakatCash;

  /// No description provided for @zakatGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get zakatGold;

  /// No description provided for @zakatSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get zakatSilver;

  /// No description provided for @zakatInvestments.
  ///
  /// In en, this message translates to:
  /// **'Shares & savings'**
  String get zakatInvestments;

  /// No description provided for @zakatBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business stock'**
  String get zakatBusiness;

  /// No description provided for @zakatReceivables.
  ///
  /// In en, this message translates to:
  /// **'Money owed to you'**
  String get zakatReceivables;

  /// No description provided for @zakatDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts due now'**
  String get zakatDebts;

  /// No description provided for @zakatRecord.
  ///
  /// In en, this message translates to:
  /// **'Record as sadaqa expense'**
  String get zakatRecord;

  /// No description provided for @zakatRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded in expenses'**
  String get zakatRecorded;

  /// No description provided for @zakatNote.
  ///
  /// In en, this message translates to:
  /// **'Zakat is 2.5% of wealth above the nisab held for one lunar year. Your home, car and personal items are not counted. Ask a scholar for your situation.'**
  String get zakatNote;

  /// No description provided for @timetableTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer timetable'**
  String get timetableTitle;

  /// No description provided for @timetableShort.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get timetableShort;

  /// No description provided for @timetableNote.
  ///
  /// In en, this message translates to:
  /// **'Times use your method, Asr setting and mosque offsets. Fridays are highlighted.'**
  String get timetableNote;

  /// No description provided for @habitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habitsTitle;

  /// No description provided for @habitsAdd.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get habitsAdd;

  /// No description provided for @habitsNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Read one page of Quran'**
  String get habitsNameHint;

  /// No description provided for @habitsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Small daily habits add up. Add one you want to keep — prayer-related or not.'**
  String get habitsEmpty;

  /// No description provided for @habitsDoneToday.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} today'**
  String habitsDoneToday(String done, String total);

  /// No description provided for @habitsSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Ideas'**
  String get habitsSuggestions;

  /// No description provided for @habitSugQuran.
  ///
  /// In en, this message translates to:
  /// **'Read one page of Quran'**
  String get habitSugQuran;

  /// No description provided for @habitSugDhikr.
  ///
  /// In en, this message translates to:
  /// **'100× SubhanAllah'**
  String get habitSugDhikr;

  /// No description provided for @habitSugWater.
  ///
  /// In en, this message translates to:
  /// **'Drink 8 glasses of water'**
  String get habitSugWater;

  /// No description provided for @habitSugWalk.
  ///
  /// In en, this message translates to:
  /// **'20-minute walk'**
  String get habitSugWalk;

  /// No description provided for @habitSugSadaqa.
  ///
  /// In en, this message translates to:
  /// **'Give a little sadaqa'**
  String get habitSugSadaqa;

  /// No description provided for @habitSugParents.
  ///
  /// In en, this message translates to:
  /// **'Call my parents'**
  String get habitSugParents;

  /// No description provided for @habitSugGratitude.
  ///
  /// In en, this message translates to:
  /// **'Write 3 things I’m grateful for'**
  String get habitSugGratitude;

  /// No description provided for @habitSugRead.
  ///
  /// In en, this message translates to:
  /// **'Read 10 pages of a book'**
  String get habitSugRead;

  /// No description provided for @habitSugSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep before 23:00'**
  String get habitSugSleep;

  /// No description provided for @ramadanChallenge.
  ///
  /// In en, this message translates to:
  /// **'Ramadan challenge'**
  String get ramadanChallenge;

  /// No description provided for @ramadanChallengeScore.
  ///
  /// In en, this message translates to:
  /// **'{score} of 5 today'**
  String ramadanChallengeScore(String score);

  /// No description provided for @ramadanCoreDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Full days start with fast, prayers and Quran} one{{count} full day so far} other{{count} full days so far}}'**
  String ramadanCoreDays(int count);

  /// No description provided for @ramadanItemFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get ramadanItemFast;

  /// No description provided for @ramadanItemPrayers.
  ///
  /// In en, this message translates to:
  /// **'5 prayers'**
  String get ramadanItemPrayers;

  /// No description provided for @ramadanItemQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get ramadanItemQuran;

  /// No description provided for @ramadanItemDhikr.
  ///
  /// In en, this message translates to:
  /// **'Dhikr'**
  String get ramadanItemDhikr;

  /// No description provided for @ramadanItemSadaqa.
  ///
  /// In en, this message translates to:
  /// **'Sadaqa'**
  String get ramadanItemSadaqa;

  /// No description provided for @ramadanChallengeIntro.
  ///
  /// In en, this message translates to:
  /// **'When Ramadan begins, Waqt tracks five daily goals — fast, prayers, Quran, dhikr and sadaqa — and lets you share your progress.'**
  String get ramadanChallengeIntro;

  /// No description provided for @obGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get obGetStarted;

  /// No description provided for @obTagline.
  ///
  /// In en, this message translates to:
  /// **'Your day, around the five prayers.'**
  String get obTagline;

  /// No description provided for @obValuePrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer times that just work'**
  String get obValuePrayer;

  /// No description provided for @obValuePrayerSub.
  ///
  /// In en, this message translates to:
  /// **'Alerts, qibla, tracking and gentle qada help.'**
  String get obValuePrayerSub;

  /// No description provided for @obValueQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran & hadith, offline'**
  String get obValueQuran;

  /// No description provided for @obValueQuranSub.
  ///
  /// In en, this message translates to:
  /// **'8 translations, khatm planner, memorization, duas.'**
  String get obValueQuranSub;

  /// No description provided for @obValueDay.
  ///
  /// In en, this message translates to:
  /// **'Plan your whole day'**
  String get obValueDay;

  /// No description provided for @obValueDaySub.
  ///
  /// In en, this message translates to:
  /// **'Tasks by prayer time, spending, habits and streaks.'**
  String get obValueDaySub;

  /// No description provided for @obValuePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private by design'**
  String get obValuePrivate;

  /// No description provided for @obValuePrivateSub.
  ///
  /// In en, this message translates to:
  /// **'No account, no ads, no tracking. Works offline.'**
  String get obValuePrivateSub;

  /// No description provided for @shareThemeEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get shareThemeEmerald;

  /// No description provided for @shareThemePaper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get shareThemePaper;

  /// No description provided for @shareThemeNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get shareThemeNight;

  /// No description provided for @shareWithArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get shareWithArabic;

  /// No description provided for @shareWithTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get shareWithTranslation;

  /// No description provided for @shareFooter.
  ///
  /// In en, this message translates to:
  /// **'Waqt · your day around prayer'**
  String get shareFooter;

  /// No description provided for @quranReminderAfterIsha.
  ///
  /// In en, this message translates to:
  /// **'Quran reminder after Isha'**
  String get quranReminderAfterIsha;

  /// No description provided for @khatmOverdue.
  ///
  /// In en, this message translates to:
  /// **'The plan’s days are over — extend it to keep a gentle pace.'**
  String get khatmOverdue;

  /// No description provided for @khatmFarBehind.
  ///
  /// In en, this message translates to:
  /// **'Behind by {count, plural, one{{count} page} other{{count} pages}} — no pressure, any amount counts.'**
  String khatmFarBehind(int count);

  /// No description provided for @khatmExtend.
  ///
  /// In en, this message translates to:
  /// **'Extend by {count, plural, one{{count} day} other{{count} days}}'**
  String khatmExtend(int count);

  /// No description provided for @expenseAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Tap + to note a purchase'**
  String get expenseAddFirst;

  /// No description provided for @tmOfficialTable.
  ///
  /// In en, this message translates to:
  /// **'Official Turkmenistan timetable'**
  String get tmOfficialTable;

  /// No description provided for @chipDone.
  ///
  /// In en, this message translates to:
  /// **'marked'**
  String get chipDone;

  /// No description provided for @chipNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get chipNow;

  /// No description provided for @chipUnmarked.
  ///
  /// In en, this message translates to:
  /// **'not marked yet'**
  String get chipUnmarked;

  /// No description provided for @chipUpcoming.
  ///
  /// In en, this message translates to:
  /// **'upcoming'**
  String get chipUpcoming;

  /// No description provided for @chipMissed.
  ///
  /// In en, this message translates to:
  /// **'missed, in qada'**
  String get chipMissed;

  /// No description provided for @chipExcused.
  ///
  /// In en, this message translates to:
  /// **'excused'**
  String get chipExcused;

  /// No description provided for @tasksAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Plan something around a prayer'**
  String get tasksAddFirst;
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
