// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkmen (`tk`).
class AppLocalizationsTk extends AppLocalizations {
  AppLocalizationsTk([String locale = 'tk']) : super(locale);

  @override
  String get appName => 'Waqt';

  @override
  String get tabToday => 'Şu gün';

  @override
  String get tabTools => 'Gurallar';

  @override
  String get tabMe => 'Men';

  @override
  String get add => 'Goş';

  @override
  String get save => 'Ýatda sakla';

  @override
  String get cancel => 'Ýatyr';

  @override
  String get done => 'Taýýar';

  @override
  String get close => 'Ýap';

  @override
  String get back => 'Yza';

  @override
  String get next => 'Indiki';

  @override
  String get skip => 'Geç';

  @override
  String get continueLabel => 'Dowam et';

  @override
  String get notNow => 'Häzir däl';

  @override
  String get edit => 'Üýtget';

  @override
  String get delete => 'Poz';

  @override
  String get undo => 'Yzyna al';

  @override
  String get reset => 'Täzeden';

  @override
  String get today => 'Şu gün';

  @override
  String get yesterday => 'Düýn';

  @override
  String get pickDate => 'Sene saýla';

  @override
  String listAnd(String a, String b) {
    return '$a we $b';
  }

  @override
  String get errorGeneric => 'Bir zat ýalňyş gitdi.';

  @override
  String get tryAgain => 'Gaýtadan synanyş';

  @override
  String get prayerFajr => 'Ertir';

  @override
  String get prayerSunrise => 'Gün dogşy';

  @override
  String get prayerDhuhr => 'Öýle';

  @override
  String get prayerAsr => 'Ikindi';

  @override
  String get prayerMaghrib => 'Agşam';

  @override
  String get prayerIsha => 'Ýassy';

  @override
  String weekdayName(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Duşenbe',
      'tue': 'Sişenbe',
      'wed': 'Çarşenbe',
      'thu': 'Penşenbe',
      'fri': 'Anna',
      'sat': 'Şenbe',
      'other': 'Ýekşenbe',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Duş',
      'tue': 'Siş',
      'wed': 'Çar',
      'thu': 'Pen',
      'fri': 'Ann',
      'sat': 'Şen',
      'other': 'Ýek',
    });
    return '$_temp0';
  }

  @override
  String weekdayInitial(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'D',
      'tue': 'S',
      'wed': 'Ç',
      'thu': 'P',
      'fri': 'A',
      'sat': 'Ş',
      'other': 'Ý',
    });
    return '$_temp0';
  }

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'ýanwar',
      'feb': 'fewral',
      'mar': 'mart',
      'apr': 'aprel',
      'may': 'maý',
      'jun': 'iýun',
      'jul': 'iýul',
      'aug': 'awgust',
      'sep': 'sentýabr',
      'oct': 'oktýabr',
      'nov': 'noýabr',
      'other': 'dekabr',
    });
    return '$_temp0';
  }

  @override
  String monthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'ýan',
      'feb': 'few',
      'mar': 'mar',
      'apr': 'apr',
      'may': 'maý',
      'jun': 'iýn',
      'jul': 'iýl',
      'aug': 'awg',
      'sep': 'sen',
      'oct': 'okt',
      'nov': 'noý',
      'other': 'dek',
    });
    return '$_temp0';
  }

  @override
  String monthStandalone(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'Ýanwar',
      'feb': 'Fewral',
      'mar': 'Mart',
      'apr': 'Aprel',
      'may': 'Maý',
      'jun': 'Iýun',
      'jul': 'Iýul',
      'aug': 'Awgust',
      'sep': 'Sentýabr',
      'oct': 'Oktýabr',
      'nov': 'Noýabr',
      'other': 'Dekabr',
    });
    return '$_temp0';
  }

  @override
  String dateLong(String weekday, String day, String month) {
    return '$day-nji $month, $weekday';
  }

  @override
  String dateDayMonth(String day, String month) {
    return '$day-nji $month';
  }

  @override
  String dateShortWeekday(String weekday, String day, String month) {
    return '$day $month, $weekday';
  }

  @override
  String hijriMonth(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Muharram',
      'm2': 'Sapar',
      'm3': 'Rebiulewwel',
      'm4': 'Rebiulahyr',
      'm5': 'Jumadel-ewwel',
      'm6': 'Jumadel-ahyr',
      'm7': 'Rejep',
      'm8': 'Şagban',
      'm9': 'Remezan',
      'm10': 'Şawwal',
      'm11': 'Zülkaáde',
      'other': 'Zülhijje',
    });
    return '$_temp0';
  }

  @override
  String hijriMonthLong(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Muharram',
      'm2': 'Sapar',
      'm3': 'Rebiulewwel',
      'm4': 'Rebiulahyr',
      'm5': 'Jumadel-ewwel',
      'm6': 'Jumadel-ahyr',
      'm7': 'Rejep',
      'm8': 'Şagban',
      'm9': 'Remezan',
      'm10': 'Şawwal',
      'm11': 'Zülkaáde',
      'other': 'Zülhijje',
    });
    return '$_temp0';
  }

  @override
  String hijriDate(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get unitH => 's';

  @override
  String get unitM => 'm';

  @override
  String get unitS => 'sek';

  @override
  String durationHM(String h, String m) {
    return '$h s $m min';
  }

  @override
  String durationM(String m) {
    return '$m min';
  }

  @override
  String minutesShort(String m) {
    return '$m min';
  }

  @override
  String inDuration(String d) {
    return '$d soň';
  }

  @override
  String daysCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n gün',
    );
    return '$_temp0';
  }

  @override
  String daysUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'gün');
    return '$_temp0';
  }

  @override
  String eventCountdown(int days, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days günden',
      one: 'ertir',
      zero: 'şu gün',
    );
    return '$name $_temp0';
  }

  @override
  String get homeNextPrayer => 'Indiki namaz';

  @override
  String get homeIn => '';

  @override
  String get homeInAfter => 'soň';

  @override
  String get homeRamadanKicker => 'Remezan · Agyz açmak';

  @override
  String get homeIftar => 'Agyz açmak';

  @override
  String homeMaghribAt(String time) {
    return 'Agşam $time';
  }

  @override
  String homeSuhoorLine(String time, String n, String total) {
    return 'Sähri $time-da gutarýar · Agyz $n/$total';
  }

  @override
  String homeAfterIshaKicker(String time) {
    return 'Ýassydan soň · $time';
  }

  @override
  String get homeYourDay => 'Siziň günüňiz';

  @override
  String get homeUpNext => 'Indiki';

  @override
  String get homeStart => 'Başla';

  @override
  String get homeMarkDone => 'Taýýar';

  @override
  String homeAdhkarAfter(String window, String min) {
    return '$window · $min min';
  }

  @override
  String get homeTaraweeh => 'Terawih';

  @override
  String homeTaraweehSub(String time) {
    return 'Metjitde · ýatlatma $time';
  }

  @override
  String get homeSpentToday => 'Şu günki çykdajy';

  @override
  String homeInclSadaqa(String amount) {
    return '$amount sadaka bilen';
  }

  @override
  String get homeTasks => 'Işler';

  @override
  String homeTasksOf(String total) {
    return '/ $total';
  }

  @override
  String homeQadaRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kaza galdy',
    );
    return '$_temp0';
  }

  @override
  String get homeMakeUp => 'Kaza et';

  @override
  String homeUnmarkedTitle(String prayers) {
    return 'Düýn $prayers bellenmedi';
  }

  @override
  String get homeUnmarkedBody => 'Siz saýlamasaňyz, kaza hiç zat goşulmaýar.';

  @override
  String get homeUnmarkedAllPrayed => 'Hemmesi okaldy';

  @override
  String get homeAddExpense => 'Çykdajy goş';

  @override
  String get homeSetLocation => 'Ýeri saýla';

  @override
  String get markClosedAtSunrise => 'gün dogşy bilen gutardy';

  @override
  String markClosedAt(String time) {
    return '$time-da gutardy';
  }

  @override
  String markLeft(String d) {
    return '$d galdy';
  }

  @override
  String markOpensAt(String time) {
    return '$time-da başlaýar';
  }

  @override
  String get markOnTime => 'Wagtynda okaldy';

  @override
  String markOnTimeSub(String prayer) {
    return '$prayer wagtynyň içinde';
  }

  @override
  String get markCongregation => 'Jemagat bilen';

  @override
  String get markCongregationSub => 'Jemagat bilen, wagtynda';

  @override
  String get markLate => 'Gijä galyp okaldy';

  @override
  String get markLateSub => 'Wagty geçenden soň';

  @override
  String get markMissed => 'Galdy, kaza goş';

  @override
  String get markMissedSub => 'Bir zat goşulmazdan öň tassyklarsyňyz';

  @override
  String get markExcused => 'Ötünçli';

  @override
  String get markExcusedSub =>
      'Aýbaşy tertibi açyk — kaza ýok, yzygiderlik saklanýar';

  @override
  String markConfirmTitle(String prayer) {
    return 'Kaza 1 $prayer goşulsynmy?';
  }

  @override
  String get markConfirmBody =>
      'Ony islän wagtyňyz kaza edip bilersiňiz. Tassyklamasaňyz hiç zat goşulmaýar.';

  @override
  String get markAddToQada => 'Kaza goş';

  @override
  String get markAdded => 'Kaza goşuldy. Mümkin bolanda kaza ediň.';

  @override
  String get markRemind => '15 minutdan ýatlat';

  @override
  String markReminderSet(String time) {
    return 'Ýatlatma $time-a goýuldy';
  }

  @override
  String get markClear => 'Belligi aýyr';

  @override
  String get markNotStarted => 'Bu namazyň wagty heniz girmedi.';

  @override
  String get qadaTitle => 'Kaza';

  @override
  String get qadaLeft => 'kaza edilmeli\nnamaz';

  @override
  String qadaMadeUpSince(String count) {
    return 'Başlanyňyzdan bäri $count kaza etdiňiz';
  }

  @override
  String get qadaThisWeek => 'Şu hepde';

  @override
  String qadaWeekMadeUp(String count) {
    return '$count kaza edildi';
  }

  @override
  String get qadaMadeUp => 'Kaza etdim';

  @override
  String get qadaAllDone => 'Hemmesi';

  @override
  String get qadaAddOlder => 'Öňki galan namazlary goş';

  @override
  String get qadaTip =>
      'Birden kaza etmek ýeterlik. Köpler her parz namaz bilen bir kaza okaýar.';

  @override
  String get qadaAddOlderTitle => 'Öňki galan namazlar';

  @override
  String get qadaAddOlderBody =>
      'Her namazdan näçesi galandygyny giriziň. Olar häzirki sanlara goşular.';

  @override
  String qadaAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kaza $count goş',
      zero: 'Kaza goş',
    );
    return '$_temp0';
  }

  @override
  String get qadaEmpty =>
      'Kaza ýok. Öňki galan namazlaryňyz bar bolsa, şu ýere goşuň.';

  @override
  String get expenseAdd => 'Çykdajy goş';

  @override
  String get expenseAddNote => 'Bellik goş';

  @override
  String get expenseNoteHint => 'Bellik';

  @override
  String get catGroceries => 'Azyk';

  @override
  String get catTransport => 'Ulag';

  @override
  String get catFood => 'Nahar';

  @override
  String get catBills => 'Tölegler';

  @override
  String get catSadaqa => 'Sadaka';

  @override
  String get catOther => 'Beýleki';

  @override
  String expenseSave(String amount, String currency) {
    return '$amount $currency ýatda sakla';
  }

  @override
  String expenseSaveSadaqa(String amount, String currency) {
    return '$amount $currency sadaka hökmünde sakla';
  }

  @override
  String get expenseEnterAmount => 'Möçberi giriziň';

  @override
  String get expenseSaved => 'Saklandy';

  @override
  String get expenseTodayList => 'Şu günki ýazgylar';

  @override
  String get expenseDeleted => 'Çykdajy pozuldy';

  @override
  String get tasksTitle => 'Işler';

  @override
  String tasksDoneOf(String done, String total) {
    return '$total işden $done taýýar';
  }

  @override
  String get tasksAddHint => 'Iş goş…';

  @override
  String get tasksAddA11y => 'Iş goş';

  @override
  String get winBeforeFajr => 'Ertirden öň';

  @override
  String get winAfterFajr => 'Ertirden soň';

  @override
  String get winBeforeDhuhr => 'Öýläden öň';

  @override
  String get winAfterDhuhr => 'Öýläden soň';

  @override
  String get winAfterAsr => 'Ikindiden soň';

  @override
  String get winAfterMaghrib => 'Agşamdan soň';

  @override
  String get winAfterIsha => 'Ýassydan soň';

  @override
  String get winAnytime => 'Islendik wagt';

  @override
  String winUntil(String time) {
    return '$time-a çenli';
  }

  @override
  String winFrom(String time) {
    return '$time-dan';
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
      other: 'Öňki günlerden $count gutarylmadyk iş',
    );
    return '$_temp0';
  }

  @override
  String get tasksMoveToday => 'Şu güne geçir';

  @override
  String get tasksEmpty =>
      'Entek hiç zat meýilleşdirilmedi. Namaz wagtyna iş goşuň.';

  @override
  String get tasksDeleted => 'Iş pozuldy';

  @override
  String get tasksAllDone => 'Şu günlük hemmesi taýýar';

  @override
  String get adhkarMorning => 'Ertirki zikirler';

  @override
  String get adhkarEvening => 'Agşamky zikirler';

  @override
  String adhkarPosOf(String pos, String total) {
    return '$pos / $total';
  }

  @override
  String adhkarRecite(String n) {
    return '$n× okaň';
  }

  @override
  String get adhkarComplete => 'Tamam';

  @override
  String adhkarOf(String n) {
    return '/ $n';
  }

  @override
  String get adhkarNext => 'Indiki';

  @override
  String get adhkarNextDhikr => 'Indiki zikir';

  @override
  String get adhkarFinish => 'Tamamla';

  @override
  String get adhkarPrev => 'Öňki zikir';

  @override
  String get adhkarTapToCount => 'Sanamak üçin basyň';

  @override
  String get adhkarSetDone => 'Alla kabul etsin.';

  @override
  String get adhkarTranslationNote => 'Terjime takmynan.';

  @override
  String get calendarTitle => 'Hijri senenamasy';

  @override
  String calendarRange(String year, String start, String end) {
    return '$year · $start – $end';
  }

  @override
  String get calendarWhiteDays => 'Ak günler 13–15';

  @override
  String get calendarMonThu => 'Duş we Pen oraza';

  @override
  String get calendarUpcoming => 'Ýakyn günler';

  @override
  String get calendarMoonNote =>
      'Seneler ýerli Aý görülişine baglylykda bir gün süýşüp biler.';

  @override
  String get calendarPrevMonth => 'Öňki aý';

  @override
  String get calendarNextMonth => 'Indiki aý';

  @override
  String calendarEveningOf(String date) {
    return '$date agşamy';
  }

  @override
  String get evRajab => 'Rejep aýy başlaýar';

  @override
  String get evMiraj => 'Miraç gijesi';

  @override
  String get evBaraah => 'Beraat gijesi';

  @override
  String get evRamadan => 'Remezan başlaýar';

  @override
  String get evQadr => 'Gadyr gijesi';

  @override
  String get evEidFitr => 'Oraza baýramy';

  @override
  String get evArafah => 'Arafat güni';

  @override
  String get evEidAdha => 'Gurban baýramy';

  @override
  String get evNewYear => 'Hijri täze ýyly';

  @override
  String get evAshura => 'Aşyr güni';

  @override
  String get evMawlid => 'Mewlit';

  @override
  String get evLastTen => 'Soňky on gije başlaýar';

  @override
  String fastLogTitle(String date) {
    return 'Oraza · $date';
  }

  @override
  String get fastFasted => 'Oraza tutdum';

  @override
  String get fastMissed => 'Galdy';

  @override
  String get fastExcused => 'Ötünçli';

  @override
  String get fastClear => 'Arassala';

  @override
  String get fastTypeRamadan => 'Remezan orazasy';

  @override
  String get fastTypeMonThu => 'Duşenbe/Penşenbe orazasy';

  @override
  String get fastTypeWhiteDays => 'Ak gün orazasy';

  @override
  String get fastTypeOther => 'Nepil oraza';

  @override
  String get ramadanTitle => 'Remezan';

  @override
  String get ramadanMode => 'Remezan tertibi';

  @override
  String get ramadanAuto => 'Awtomatik';

  @override
  String get ramadanOn => 'Açyk';

  @override
  String get ramadanOff => 'Ýapyk';

  @override
  String ramadanInDays(String days) {
    return '$days günden';
  }

  @override
  String ramadanDayOf(String n, String total) {
    return '$total günden $n-nji';
  }

  @override
  String get ramadanSuhoorReminder => 'Sähri ýatlatmasy';

  @override
  String ramadanSuhoorBefore(String min) {
    return 'Ertirden $min min öň';
  }

  @override
  String get ramadanIftarReminder => 'Agşamda agyz açmak';

  @override
  String get ramadanTaraweehReminder => 'Terawih ýatlatmasy';

  @override
  String get ramadanFasts => 'Şu Remezandaky orazalar';

  @override
  String get ramadanTodayFast => 'Şu günki oraza';

  @override
  String get ramadanNotNow => 'Remezan tertibi 1 Remezanda özi açylýar.';

  @override
  String get toolsTitle => 'Gurallar';

  @override
  String get qibla => 'Kybla';

  @override
  String get qiblaTurn => 'Ok ýokary görkezýänçä öwrüliň';

  @override
  String get qiblaFacing => 'Siz Kybla tarap';

  @override
  String get qiblaCalibrate => 'Kompas sazlamaly — telefony 8 şekilinde aýlaň.';

  @override
  String qiblaNoSensor(String deg) {
    return 'Bu enjamda kompas ýok. Kybla demirgazykdan sagat ugruna $deg°.';
  }

  @override
  String qiblaFromNorth(String deg) {
    return 'demirgazykdan $deg°';
  }

  @override
  String qiblaDistance(String km) {
    return 'Mekgä çenli $km km';
  }

  @override
  String get qiblaOpen => 'Kompasy aç';

  @override
  String get tasbih => 'Täsbih';

  @override
  String tasbihOf(String n) {
    return '/ $n';
  }

  @override
  String tasbihComplete(String n) {
    return 'Tamam · $n';
  }

  @override
  String get tasbihTapAgain => 'Täzeden başlamak üçin basyň';

  @override
  String get tasbihCustom => 'Öz täsbihiňiz';

  @override
  String get tasbihPreset => 'Namazdan soňky täsbih (33 · 33 · 34)';

  @override
  String get tasbihPhrase => 'Söz';

  @override
  String get tasbihGoal => 'Maksat';

  @override
  String get tasbihCount => 'San';

  @override
  String get tasbihTapA11y => 'Bir sana';

  @override
  String get toolsAdhkar => 'Zikirler';

  @override
  String get toolsMorningDue => 'Ertirki wagty';

  @override
  String get toolsEveningDue => 'Agşamky wagty';

  @override
  String get toolsAdhkarDone => 'Şu gün taýýar';

  @override
  String get toolsCalendar => 'Hijri senenamasy';

  @override
  String get toolsRamadan => 'Remezan';

  @override
  String toolsRamadanNow(String n) {
    return '$n-nji gün';
  }

  @override
  String get meTitle => 'Men';

  @override
  String get meAll5 => 'Bäş wagt namaz';

  @override
  String meDaysInRow(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'gün yzygiderli',
    );
    return '$_temp0';
  }

  @override
  String get me2WeeksAgo => '2 hepde öň';

  @override
  String meBest(String n) {
    return 'Iň gowy: $n gün';
  }

  @override
  String get meOnTime => 'Wagtynda';

  @override
  String get meThisMonth => 'şu aý';

  @override
  String get meAdhkarStreak => 'Zikir yzygiderligi';

  @override
  String get meDays => 'gün';

  @override
  String get meMorningEvening => 'ertir we agşam';

  @override
  String get meConsistency => 'Yzygiderlik';

  @override
  String get meFasts => 'Şu aýdaky orazalar';

  @override
  String get meFastsNone => 'Entek bellenmedi';

  @override
  String meFastMonThu(String n) {
    return '$n Duş/Pen';
  }

  @override
  String meFastWhite(String n) {
    return '$n ak gün';
  }

  @override
  String meFastRamadan(String n) {
    return '$n Remezan';
  }

  @override
  String meFastOther(String n) {
    return '$n nepil';
  }

  @override
  String get meSadaqa => 'Sadaka';

  @override
  String get meSpending => 'Çykdajylar';

  @override
  String get meNoSpending => 'Şu aý entek çykdajy ýok.';

  @override
  String get meNoPrayerData =>
      'Yzygiderligi görmek üçin namazlaryňyzy «Şu gün» sahypasynda belläň.';

  @override
  String get meSettingsA11y => 'Sazlamalar';

  @override
  String get tipFajrTitle => 'Ertir iň köp galýan namaz.';

  @override
  String get tipFajrBody =>
      'Azandan on minut öň budilnik we ýanyňyzda suw köplere kömek edýär.';

  @override
  String get tipDhuhrTitle => 'Öýle işde ýatdan çykýar.';

  @override
  String get tipDhuhrBody => 'Azandan soň on minuty senenamaňyzda belläň.';

  @override
  String get tipAsrTitle => 'Ikindi aňsat galýar.';

  @override
  String get tipAsrBody => 'Eşiden badyňyza, öýlänki işlerden öň okaň.';

  @override
  String get tipMaghribTitle => 'Agşamyň wagty gysga.';

  @override
  String get tipMaghribBody => 'Ilki namaz, soň saçak.';

  @override
  String get tipIshaTitle => 'Ýassy gijä süýşýär.';

  @override
  String get tipIshaBody => 'Çaýdan we ekrandan öň okaň, soň dynç alyň.';

  @override
  String get settingsTitle => 'Sazlamalar';

  @override
  String get secPrayerTimes => 'Namaz wagtlary';

  @override
  String get calcMethod => 'Hasaplama usuly';

  @override
  String get asr => 'Ikindi';

  @override
  String get asrStandard => 'Standart';

  @override
  String get asrHanafi => 'Hanafy';

  @override
  String get matchMosque => 'Metjidime laýyklaşdyr';

  @override
  String get matchMosqueSub => 'Ähli wagtlary onuň tertibine süýşür';

  @override
  String get perPrayerOffsets => 'Her namazy sazla';

  @override
  String offsetMinutes(String value) {
    return '$value min';
  }

  @override
  String get secAlerts => 'Duýduryşlar';

  @override
  String get alertAdhan => 'Azan';

  @override
  String get alertSilent => 'Sessiz';

  @override
  String get alertOff => 'Öçük';

  @override
  String get secGeneral => 'Umumy';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Ulgam';

  @override
  String get currency => 'Pul birligi';

  @override
  String get location => 'Ýerleşýän ýeri';

  @override
  String get periodMode => 'Aýbaşy tertibi';

  @override
  String get periodModeSub =>
      'Namaz duýduryşlaryny togtadýar. Yzygiderlik saklanýar.';

  @override
  String get appearance => 'Görnüş';

  @override
  String get themeLight => 'Ýagty';

  @override
  String get themeDark => 'Garaňky';

  @override
  String get themeAuto => 'Awto';

  @override
  String get widgets => 'Widžetler';

  @override
  String get privacyNote =>
      'Hasap ýok, mahabat ýok. Hemme zat şu telefonda galýar.';

  @override
  String versionLabel(String version) {
    return 'Waqt $version';
  }

  @override
  String get hijriAdjust => 'Hijri senesi';

  @override
  String get hijriAdjustSub => 'Ýerli Aý görlüşine laýyklaşdyr';

  @override
  String get hijriAdjustNone => 'Düzediş ýok';

  @override
  String get adhkarReminders => 'Zikir ýatlatmalary';

  @override
  String get adhkarRemindersSub => 'Ertir namazdan soň, agşam ikindiden soň';

  @override
  String get secRamadan => 'Remezan';

  @override
  String get secNotifications => 'Bildirişler';

  @override
  String get notifPermissionOff =>
      'Waqt üçin bildirişler öçük. Ulgam sazlamalarynda açyň.';

  @override
  String get exactAlarmOff =>
      'Takyk duýduryşlar öçük, şonuň üçin duýduryşlar birnäçe minut gijä galyp biler.';

  @override
  String get allowExact => 'Takyk duýduryşlara rugsat ber';

  @override
  String get methodMwl => 'Musulman Dünýä Ligasy';

  @override
  String get methodEgyptian => 'Müsür umumy edarasy';

  @override
  String get methodKarachi => 'Karaçi Yslam ylymlary uniwersiteti';

  @override
  String get methodUmmAlQura => 'Umm al-Kura, Mekge';

  @override
  String get methodDubai => 'Dubaý';

  @override
  String get methodMoonSighting => 'Aý görüş komiteti';

  @override
  String get methodNorthAmerica => 'ISNA (Demirgazyk Amerika)';

  @override
  String get methodKuwait => 'Kuweýt';

  @override
  String get methodQatar => 'Katar';

  @override
  String get methodSingapore => 'Singapur';

  @override
  String get methodTurkey => 'Diýanet (Türkiýe)';

  @override
  String get methodTehran => 'Tähran';

  @override
  String get widgetsHelpTitle => 'Baş ekran widžetleri';

  @override
  String get widgetsHelpIos =>
      'Baş ekranyň boş ýerine basyp saklaň, + basyň, Waqt gözläň we kiçi, orta ýa-da gulp ekrany widžetini saýlaň.';

  @override
  String get widgetsHelpAndroid =>
      'Baş ekranyň boş ýerine basyp saklaň, Widžetler basyň, Waqt tapyň we widžeti ekrana süýräň. Onuň düwmesi häzirki namazy belleýär.';

  @override
  String get widgetsHelpData =>
      'Widžetler programmany açmasaňyz hem indiki ýedi günüň wagtlaryny görkezýär.';

  @override
  String get locationTitle => 'Ýerleşýän ýeri';

  @override
  String get locationUseCurrent => 'Meniň ýerimi ulan';

  @override
  String get locationSearch => 'Şäher gözle';

  @override
  String get locationCoordinates => 'Koordinatlary girizmek';

  @override
  String get locationLatitude => 'Giňlik';

  @override
  String get locationLongitude => 'Uzaklyk';

  @override
  String get locationName => 'Ýeriň ady';

  @override
  String get locationLocating => 'Ýeriňiz kesgitlenýär…';

  @override
  String get locationDenied => 'Ýer rugsady berilmedi. Ýerine şäher saýlaň.';

  @override
  String get locationFailed => 'Ýeriňizi kesgitläp bolmady. Şäher saýlaň.';

  @override
  String locationNearby(String city) {
    return '$city golaýynda';
  }

  @override
  String get locationInvalid => 'Dogry giňlik we uzaklyk giriziň.';

  @override
  String get locationPrivacy =>
      'Ýeriňiz diňe namaz wagtlaryny we Kyblany hasaplamak üçin ulanylýar. Ol bu telefondan çykmaýar.';

  @override
  String get obGreeting => 'Essalawmaleýkim';

  @override
  String get obLanguageTitle => 'Diliňizi saýlaň';

  @override
  String get obLanguageSub => 'Soňra Sazlamalarda üýtgedip bilersiňiz.';

  @override
  String get obLocationTitle => 'Siz nirede namaz okaýarsyňyz?';

  @override
  String obMethodLine(String method, String madhab) {
    return '$method · $madhab ikindi';
  }

  @override
  String get obAdvanced => 'Giňişleýin';

  @override
  String get obNotifTitle => 'Namazy hiç wagt sypdyrmaň';

  @override
  String get obNotifBody =>
      'Her namaz wagtynda ýumşak duýduryş alyň. Soňra her namaz üçin azan, sessiz ýa-da öçük saýlaň.';

  @override
  String get obAllowNotif => 'Bildirişlere rugsat ber';

  @override
  String get obNotifAllowed => 'Bildirişler açyk';

  @override
  String get obBatteryTitle => 'Duýduryşlar wagtynda bolsun';

  @override
  String get obBatteryBody =>
      'Käbir Android telefonlar batareýany tygşytlamak üçin programmalary saklaýar. Azan gijä galmazlygy üçin Waqt-y batareýa sazlamalarynda «Çäklendirilmedik» ediň.';

  @override
  String get obOpenBattery => 'Batareýa sazlamalaryny aç';

  @override
  String get obStart => 'Başla';

  @override
  String get obPrivacy => 'Hasap ýok. Mahabat ýok. Hemme zat şu telefonda.';

  @override
  String notifPrayerTitle(String prayer, String time) {
    return '$prayer · $time';
  }

  @override
  String notifPrayerBody(String prayer, String place) {
    return '$place: $prayer namazynyň wagty geldi.';
  }

  @override
  String notifRemindTitle(String prayer) {
    return 'Ýatlatma · $prayer';
  }

  @override
  String notifRemindBody(String prayer) {
    return '$prayer namazyny ýatlatmagy haýyş etdiňiz.';
  }

  @override
  String get notifMorningBody => 'Güne birnäçe minutlyk zikir bilen başlaň.';

  @override
  String get notifEveningBody => 'Agşamdan öň birnäçe minutlyk zikir.';

  @override
  String notifSuhoorTitle(String time) {
    return 'Sähri $time-da gutarýar';
  }

  @override
  String notifSuhoorBody(String min) {
    return 'Ertire $min minut galdy.';
  }

  @override
  String get notifIftarTitle => 'Agyz açmak wagty';

  @override
  String notifIftarBody(String place) {
    return '$place: agşam girdi. Alla orazaňyzy kabul etsin.';
  }

  @override
  String get chanAdhan => 'Namaz wagtlary · azan';

  @override
  String get chanStandard => 'Namaz wagtlary · adaty ses';

  @override
  String get chanReminders => 'Ýatlatmalar';
}
