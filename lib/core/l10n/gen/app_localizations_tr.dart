// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Waqt';

  @override
  String get tabToday => 'Bugün';

  @override
  String get tabTools => 'Araçlar';

  @override
  String get tabMe => 'Ben';

  @override
  String get add => 'Ekle';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get done => 'Tamam';

  @override
  String get close => 'Kapat';

  @override
  String get back => 'Geri';

  @override
  String get next => 'İleri';

  @override
  String get skip => 'Atla';

  @override
  String get continueLabel => 'Devam';

  @override
  String get notNow => 'Şimdi değil';

  @override
  String get edit => 'Düzenle';

  @override
  String get delete => 'Sil';

  @override
  String get undo => 'Geri al';

  @override
  String get reset => 'Sıfırla';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get pickDate => 'Tarih seç';

  @override
  String listAnd(String a, String b) {
    return '$a ve $b';
  }

  @override
  String get errorGeneric => 'Bir şeyler ters gitti.';

  @override
  String get tryAgain => 'Tekrar dene';

  @override
  String get prayerFajr => 'Sabah';

  @override
  String get prayerSunrise => 'Güneş';

  @override
  String get prayerDhuhr => 'Öğle';

  @override
  String get prayerAsr => 'İkindi';

  @override
  String get prayerMaghrib => 'Akşam';

  @override
  String get prayerIsha => 'Yatsı';

  @override
  String weekdayName(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Pazartesi',
      'tue': 'Salı',
      'wed': 'Çarşamba',
      'thu': 'Perşembe',
      'fri': 'Cuma',
      'sat': 'Cumartesi',
      'other': 'Pazar',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Pzt',
      'tue': 'Sal',
      'wed': 'Çar',
      'thu': 'Per',
      'fri': 'Cum',
      'sat': 'Cmt',
      'other': 'Paz',
    });
    return '$_temp0';
  }

  @override
  String weekdayInitial(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'P',
      'tue': 'S',
      'wed': 'Ç',
      'thu': 'P',
      'fri': 'C',
      'sat': 'C',
      'other': 'P',
    });
    return '$_temp0';
  }

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'Ocak',
      'feb': 'Şubat',
      'mar': 'Mart',
      'apr': 'Nisan',
      'may': 'Mayıs',
      'jun': 'Haziran',
      'jul': 'Temmuz',
      'aug': 'Ağustos',
      'sep': 'Eylül',
      'oct': 'Ekim',
      'nov': 'Kasım',
      'other': 'Aralık',
    });
    return '$_temp0';
  }

  @override
  String monthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'Oca',
      'feb': 'Şub',
      'mar': 'Mar',
      'apr': 'Nis',
      'may': 'May',
      'jun': 'Haz',
      'jul': 'Tem',
      'aug': 'Ağu',
      'sep': 'Eyl',
      'oct': 'Eki',
      'nov': 'Kas',
      'other': 'Ara',
    });
    return '$_temp0';
  }

  @override
  String monthStandalone(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'Ocak',
      'feb': 'Şubat',
      'mar': 'Mart',
      'apr': 'Nisan',
      'may': 'Mayıs',
      'jun': 'Haziran',
      'jul': 'Temmuz',
      'aug': 'Ağustos',
      'sep': 'Eylül',
      'oct': 'Ekim',
      'nov': 'Kasım',
      'other': 'Aralık',
    });
    return '$_temp0';
  }

  @override
  String dateLong(String weekday, String day, String month) {
    return '$day $month $weekday';
  }

  @override
  String dateDayMonth(String day, String month) {
    return '$day $month';
  }

  @override
  String dateShortWeekday(String weekday, String day, String month) {
    return '$day $month $weekday';
  }

  @override
  String hijriMonth(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Muharrem',
      'm2': 'Safer',
      'm3': 'Rebiülevvel',
      'm4': 'Rebiülahir',
      'm5': 'Cemaziyelevvel',
      'm6': 'Cemaziyelahir',
      'm7': 'Recep',
      'm8': 'Şaban',
      'm9': 'Ramazan',
      'm10': 'Şevval',
      'm11': 'Zilkade',
      'other': 'Zilhicce',
    });
    return '$_temp0';
  }

  @override
  String hijriMonthLong(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Muharrem',
      'm2': 'Safer',
      'm3': 'Rebiülevvel',
      'm4': 'Rebiülahir',
      'm5': 'Cemaziyelevvel',
      'm6': 'Cemaziyelahir',
      'm7': 'Recep',
      'm8': 'Şaban',
      'm9': 'Ramazan',
      'm10': 'Şevval',
      'm11': 'Zilkade',
      'other': 'Zilhicce',
    });
    return '$_temp0';
  }

  @override
  String hijriDate(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get unitH => 'sa';

  @override
  String get unitM => 'dk';

  @override
  String get unitS => 'sn';

  @override
  String durationHM(String h, String m) {
    return '$h sa $m dk';
  }

  @override
  String durationM(String m) {
    return '$m dk';
  }

  @override
  String minutesShort(String m) {
    return '$m dk';
  }

  @override
  String inDuration(String d) {
    return '$d sonra';
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
      other: '$days gün sonra',
      one: 'yarın',
      zero: 'bugün',
    );
    return '$name: $_temp0';
  }

  @override
  String get homeNextPrayer => 'Sıradaki namaz';

  @override
  String get homeIn => '';

  @override
  String get homeInAfter => 'sonra';

  @override
  String get homeRamadanKicker => 'Ramazan · İftar';

  @override
  String get homeIftar => 'İftar';

  @override
  String homeMaghribAt(String time) {
    return 'Akşam $time';
  }

  @override
  String homeSuhoorLine(String time, String n, String total) {
    return 'Sahur $time bitiyor · Oruç $n/$total';
  }

  @override
  String homeAfterIshaKicker(String time) {
    return 'Yatsıdan sonra · $time';
  }

  @override
  String get homeYourDay => 'Gününüz';

  @override
  String get homeUpNext => 'Sırada';

  @override
  String get homeStart => 'Başla';

  @override
  String get homeMarkDone => 'Bitti';

  @override
  String homeAdhkarAfter(String window, String min) {
    return '$window · $min dk';
  }

  @override
  String get homeTaraweeh => 'Teravih';

  @override
  String homeTaraweehSub(String time) {
    return 'Camide · hatırlatma $time';
  }

  @override
  String get homeSpentToday => 'Bugün harcanan';

  @override
  String homeInclSadaqa(String amount) {
    return '$amount sadaka dahil';
  }

  @override
  String get homeTasks => 'Görevler';

  @override
  String homeTasksOf(String total) {
    return '/ $total';
  }

  @override
  String homeQadaRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kaza kaldı',
    );
    return '$_temp0';
  }

  @override
  String get homeMakeUp => 'Kaza kıl';

  @override
  String homeUnmarkedTitle(String prayers) {
    return 'Dün $prayers işaretlenmedi';
  }

  @override
  String get homeUnmarkedBody => 'Siz seçmedikçe kazaya bir şey eklenmez.';

  @override
  String get homeUnmarkedAllPrayed => 'Hepsi kılındı';

  @override
  String get homeAddExpense => 'Harcama ekle';

  @override
  String get homeSetLocation => 'Konum seç';

  @override
  String get markClosedAtSunrise => 'güneş doğunca kapandı';

  @override
  String markClosedAt(String time) {
    return '$time kapandı';
  }

  @override
  String markLeft(String d) {
    return '$d kaldı';
  }

  @override
  String markOpensAt(String time) {
    return '$time başlıyor';
  }

  @override
  String get markOnTime => 'Vaktinde kılındı';

  @override
  String markOnTimeSub(String prayer) {
    return '$prayer vakti içinde';
  }

  @override
  String get markCongregation => 'Cemaatle';

  @override
  String get markCongregationSub => 'Cemaatle, vaktinde';

  @override
  String get markLate => 'Geç kılındı';

  @override
  String get markLateSub => 'Vakti çıktıktan sonra';

  @override
  String get markMissed => 'Kaçırıldı, kazaya ekle';

  @override
  String get markMissedSub => 'Bir şey eklenmeden önce onaylarsınız';

  @override
  String get markExcused => 'Mazeretli';

  @override
  String get markExcusedSub => 'Özel gün modu açık — kaza yok, seri korunur';

  @override
  String markConfirmTitle(String prayer) {
    return 'Kazaya 1 $prayer eklensin mi?';
  }

  @override
  String get markConfirmBody =>
      'İstediğiniz zaman kaza edebilirsiniz. Onaylamadıkça hiçbir şey eklenmez.';

  @override
  String get markAddToQada => 'Kazaya ekle';

  @override
  String get markAdded => 'Kazaya eklendi. Fırsat buldukça kaza edin.';

  @override
  String get markRemind => '15 dk sonra hatırlat';

  @override
  String markReminderSet(String time) {
    return 'Hatırlatma $time için kuruldu';
  }

  @override
  String get markClear => 'İşareti kaldır';

  @override
  String get markNotStarted => 'Bu namazın vakti henüz girmedi.';

  @override
  String get qadaTitle => 'Kaza';

  @override
  String get qadaLeft => 'kaza edilecek\nnamaz';

  @override
  String qadaMadeUpSince(String count) {
    return 'Başladığınızdan beri $count kaza kıldınız';
  }

  @override
  String get qadaThisWeek => 'Bu hafta';

  @override
  String qadaWeekMadeUp(String count) {
    return '$count kaza kılındı';
  }

  @override
  String get qadaMadeUp => 'Kıldım';

  @override
  String get qadaAllDone => 'Tamamlandı';

  @override
  String get qadaAddOlder => 'Eski kaçırılan namazları ekle';

  @override
  String get qadaTip =>
      'Birer birer yeterli. Birçok kişi her vakit namazıyla bir kaza kılar.';

  @override
  String get qadaAddOlderTitle => 'Eski kaçırılan namazlar';

  @override
  String get qadaAddOlderBody =>
      'Her namazdan kaç tane borcunuz olduğunu girin. Mevcut sayılara eklenir.';

  @override
  String qadaAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kazaya $count ekle',
      zero: 'Kazaya ekle',
    );
    return '$_temp0';
  }

  @override
  String get qadaEmpty =>
      'Kaza kaydı yok. Eski kaçırılan namazlarınız varsa buraya ekleyin.';

  @override
  String get expenseAdd => 'Harcama ekle';

  @override
  String get expenseAddNote => 'Not ekle';

  @override
  String get expenseNoteHint => 'Not';

  @override
  String get catGroceries => 'Market';

  @override
  String get catTransport => 'Ulaşım';

  @override
  String get catFood => 'Yemek';

  @override
  String get catBills => 'Faturalar';

  @override
  String get catSadaqa => 'Sadaka';

  @override
  String get catOther => 'Diğer';

  @override
  String expenseSave(String amount, String currency) {
    return '$amount $currency kaydet';
  }

  @override
  String expenseSaveSadaqa(String amount, String currency) {
    return '$amount $currency sadaka olarak kaydet';
  }

  @override
  String get expenseEnterAmount => 'Tutar girin';

  @override
  String get expenseSaved => 'Kaydedildi';

  @override
  String get expenseTodayList => 'Bugünkü kayıtlar';

  @override
  String get expenseDeleted => 'Harcama silindi';

  @override
  String get tasksTitle => 'Görevler';

  @override
  String tasksDoneOf(String done, String total) {
    return '$total görevden $done tamam';
  }

  @override
  String get tasksAddHint => 'Görev ekle…';

  @override
  String get tasksAddA11y => 'Görev ekle';

  @override
  String get winBeforeFajr => 'Sabahtan önce';

  @override
  String get winAfterFajr => 'Sabahtan sonra';

  @override
  String get winBeforeDhuhr => 'Öğleden önce';

  @override
  String get winAfterDhuhr => 'Öğleden sonra';

  @override
  String get winAfterAsr => 'İkindiden sonra';

  @override
  String get winAfterMaghrib => 'Akşamdan sonra';

  @override
  String get winAfterIsha => 'Yatsıdan sonra';

  @override
  String get winAnytime => 'Herhangi bir zaman';

  @override
  String winUntil(String time) {
    return '$time kadar';
  }

  @override
  String winFrom(String time) {
    return '$time itibaren';
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
      other: 'Önceki günlerden $count bitmemiş görev',
    );
    return '$_temp0';
  }

  @override
  String get tasksMoveToday => 'Bugüne taşı';

  @override
  String get tasksEmpty => 'Henüz plan yok. Bir namaz aralığına görev ekleyin.';

  @override
  String get tasksDeleted => 'Görev silindi';

  @override
  String get tasksAllDone => 'Bugünlük hepsi tamam';

  @override
  String get adhkarMorning => 'Sabah zikirleri';

  @override
  String get adhkarEvening => 'Akşam zikirleri';

  @override
  String adhkarPosOf(String pos, String total) {
    return '$pos / $total';
  }

  @override
  String adhkarRecite(String n) {
    return '$n× okuyun';
  }

  @override
  String get adhkarComplete => 'Tamamlandı';

  @override
  String adhkarOf(String n) {
    return '/ $n';
  }

  @override
  String get adhkarNext => 'İleri';

  @override
  String get adhkarNextDhikr => 'Sonraki zikir';

  @override
  String get adhkarFinish => 'Bitir';

  @override
  String get adhkarPrev => 'Önceki zikir';

  @override
  String get adhkarTapToCount => 'Saymak için dokunun';

  @override
  String get adhkarSetDone => 'Allah kabul etsin.';

  @override
  String get adhkarTranslationNote => 'Çeviri yaklaşıktır.';

  @override
  String get calendarTitle => 'Hicri takvim';

  @override
  String calendarRange(String year, String start, String end) {
    return '$year · $start – $end';
  }

  @override
  String get calendarWhiteDays => 'Eyyam-ı bîd 13–15';

  @override
  String get calendarMonThu => 'Pzt ve Per oruçları';

  @override
  String get calendarUpcoming => 'Yaklaşanlar';

  @override
  String get calendarMoonNote =>
      'Tarihler yerel hilal gözlemine göre bir gün kayabilir.';

  @override
  String get calendarPrevMonth => 'Önceki ay';

  @override
  String get calendarNextMonth => 'Sonraki ay';

  @override
  String calendarEveningOf(String date) {
    return '$date akşamı';
  }

  @override
  String get evRajab => 'Recep ayı başlıyor';

  @override
  String get evMiraj => 'Miraç Kandili';

  @override
  String get evBaraah => 'Berat Kandili';

  @override
  String get evRamadan => 'Ramazan başlıyor';

  @override
  String get evQadr => 'Kadir Gecesi';

  @override
  String get evEidFitr => 'Ramazan Bayramı';

  @override
  String get evArafah => 'Arefe günü';

  @override
  String get evEidAdha => 'Kurban Bayramı';

  @override
  String get evNewYear => 'Hicri Yılbaşı';

  @override
  String get evAshura => 'Aşure Günü';

  @override
  String get evMawlid => 'Mevlid Kandili';

  @override
  String get evLastTen => 'Son on gece başlıyor';

  @override
  String fastLogTitle(String date) {
    return 'Oruç · $date';
  }

  @override
  String get fastFasted => 'Oruç tuttum';

  @override
  String get fastMissed => 'Tutamadım';

  @override
  String get fastExcused => 'Mazeretli';

  @override
  String get fastClear => 'Temizle';

  @override
  String get fastTypeRamadan => 'Ramazan orucu';

  @override
  String get fastTypeMonThu => 'Pazartesi/Perşembe orucu';

  @override
  String get fastTypeWhiteDays => 'Eyyam-ı bîd orucu';

  @override
  String get fastTypeOther => 'Nafile oruç';

  @override
  String get fastTypeQada => 'Kaza orucu';

  @override
  String get ramadanTitle => 'Ramazan';

  @override
  String get ramadanMode => 'Ramazan modu';

  @override
  String get ramadanAuto => 'Otomatik';

  @override
  String get ramadanOn => 'Açık';

  @override
  String get ramadanOff => 'Kapalı';

  @override
  String ramadanInDays(String days) {
    return '$days gün sonra';
  }

  @override
  String ramadanDayOf(String n, String total) {
    return '$total günden $n. gün';
  }

  @override
  String get ramadanSuhoorReminder => 'Sahur hatırlatması';

  @override
  String ramadanSuhoorBefore(String min) {
    return 'Sabahtan $min dk önce';
  }

  @override
  String get ramadanIftarReminder => 'Akşamda iftar';

  @override
  String get ramadanTaraweehReminder => 'Teravih hatırlatması';

  @override
  String get ramadanFasts => 'Bu Ramazandaki oruçlar';

  @override
  String get ramadanTodayFast => 'Bugünkü oruç';

  @override
  String get ramadanNotNow =>
      'Ramazan modu 1 Ramazan\'da kendiliğinden açılır.';

  @override
  String get toolsTitle => 'Araçlar';

  @override
  String get qibla => 'Kıble';

  @override
  String get qiblaTurn => 'Ok yukarıyı gösterene kadar dönün';

  @override
  String get qiblaFacing => 'Kıbleye dönüksünüz';

  @override
  String get qiblaCalibrate =>
      'Pusula kalibrasyon istiyor — telefonu 8 çizerek hareket ettirin.';

  @override
  String qiblaNoSensor(String deg) {
    return 'Bu cihazda pusula yok. Kıble, gerçek kuzeyden saat yönünde $deg°.';
  }

  @override
  String qiblaFromNorth(String deg) {
    return 'kuzeyden $deg°';
  }

  @override
  String qiblaDistance(String km) {
    return 'Mekke\'ye $km km';
  }

  @override
  String get qiblaOpen => 'Pusulayı aç';

  @override
  String get tasbih => 'Tesbih';

  @override
  String tasbihOf(String n) {
    return '/ $n';
  }

  @override
  String tasbihComplete(String n) {
    return 'Tamam · $n';
  }

  @override
  String get tasbihTapAgain => 'Yeniden başlamak için dokunun';

  @override
  String get tasbihCustom => 'Özel tesbih';

  @override
  String get tasbihPreset => 'Namaz sonrası tesbih (33 · 33 · 34)';

  @override
  String get tasbihPhrase => 'İfade';

  @override
  String get tasbihGoal => 'Hedef';

  @override
  String get tasbihCount => 'Say';

  @override
  String get tasbihTapA11y => 'Bir say';

  @override
  String get toolsAdhkar => 'Zikirler';

  @override
  String get toolsMorningDue => 'Sabah vakti';

  @override
  String get toolsEveningDue => 'Akşam vakti';

  @override
  String get toolsAdhkarDone => 'Bugün tamam';

  @override
  String get toolsCalendar => 'Hicri takvim';

  @override
  String get toolsRamadan => 'Ramazan';

  @override
  String toolsRamadanNow(String n) {
    return '$n. gün';
  }

  @override
  String get meTitle => 'Ben';

  @override
  String get meAll5 => '5 vakit namaz';

  @override
  String meDaysInRow(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'gün üst üste',
    );
    return '$_temp0';
  }

  @override
  String get me2WeeksAgo => '2 hafta önce';

  @override
  String meBest(String n) {
    return 'En iyi: $n gün';
  }

  @override
  String get meOnTime => 'Vaktinde';

  @override
  String get meThisMonth => 'bu ay';

  @override
  String get meAdhkarStreak => 'Zikir serisi';

  @override
  String get meDays => 'gün';

  @override
  String get meMorningEvening => 'sabah ve akşam';

  @override
  String get meConsistency => 'İstikrar';

  @override
  String get meFasts => 'Bu ayki oruçlar';

  @override
  String get meFastsNone => 'Henüz kayıt yok';

  @override
  String meFastMonThu(String n) {
    return '$n Pzt/Per';
  }

  @override
  String meFastWhite(String n) {
    return '$n eyyam-ı bîd';
  }

  @override
  String meFastRamadan(String n) {
    return '$n Ramazan';
  }

  @override
  String meFastOther(String n) {
    return '$n nafile';
  }

  @override
  String get meSadaqa => 'Sadaka';

  @override
  String get meSpending => 'Harcamalar';

  @override
  String get meNoSpending => 'Bu ay henüz harcama yok.';

  @override
  String get meNoPrayerData =>
      'İstikrarınızı görmek için namazlarınızı Bugün sekmesinde işaretleyin.';

  @override
  String get meSettingsA11y => 'Ayarlar';

  @override
  String get tipFajrTitle => 'Sabah en sessiz olanı.';

  @override
  String get tipFajrBody =>
      'Ezandan on dakika önce bir alarm ve yatağın yanında su, birçok kişiye yardımcı olur.';

  @override
  String get tipDhuhrTitle => 'Öğle iş arasında kaçıyor.';

  @override
  String get tipDhuhrBody =>
      'Ezandan hemen sonra takviminizde on dakika ayırın.';

  @override
  String get tipAsrTitle => 'İkindi kolay kaçıyor.';

  @override
  String get tipAsrBody => 'Duyar duymaz, öğleden sonraki işlerden önce kılın.';

  @override
  String get tipMaghribTitle => 'Akşamın vakti kısa.';

  @override
  String get tipMaghribBody => 'Önce namaz, sonra sofra.';

  @override
  String get tipIshaTitle => 'Yatsı geç kalıyor.';

  @override
  String get tipIshaBody => 'Çaydan ve ekranlardan önce kılın, sonra dinlenin.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get secPrayerTimes => 'Namaz vakitleri';

  @override
  String get calcMethod => 'Hesaplama yöntemi';

  @override
  String get asr => 'İkindi';

  @override
  String get asrStandard => 'Standart';

  @override
  String get asrHanafi => 'Hanefi';

  @override
  String get matchMosque => 'Camime göre ayarla';

  @override
  String get matchMosqueSub => 'Tüm vakitleri onun takvimine kaydır';

  @override
  String get perPrayerOffsets => 'Her namazı ayarla';

  @override
  String offsetMinutes(String value) {
    return '$value dk';
  }

  @override
  String get secAlerts => 'Bildirimler';

  @override
  String get alertAdhan => 'Ezan';

  @override
  String get alertSilent => 'Sessiz';

  @override
  String get alertOff => 'Kapalı';

  @override
  String get secGeneral => 'Genel';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get currency => 'Para birimi';

  @override
  String get location => 'Konum';

  @override
  String get periodMode => 'Özel gün modu';

  @override
  String get periodModeSub => 'Namaz bildirimlerini durdurur. Seriler korunur.';

  @override
  String get appearance => 'Görünüm';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeAuto => 'Otomatik';

  @override
  String get widgets => 'Widget\'lar';

  @override
  String get privacyNote =>
      'Hesap yok, reklam yok. Her şey bu telefonda kalır.';

  @override
  String versionLabel(String version) {
    return 'Waqt $version';
  }

  @override
  String get hijriAdjust => 'Hicri tarih';

  @override
  String get hijriAdjustSub => 'Yerel hilal gözlemine uydur';

  @override
  String get hijriAdjustNone => 'Düzeltme yok';

  @override
  String get adhkarReminders => 'Zikir hatırlatmaları';

  @override
  String get adhkarRemindersSub =>
      'Sabah namazdan sonra, akşam ikindiden sonra';

  @override
  String get secRamadan => 'Ramazan';

  @override
  String get secNotifications => 'Bildirimler';

  @override
  String get notifPermissionOff =>
      'Waqt için bildirimler kapalı. Sistem ayarlarından açın.';

  @override
  String get exactAlarmOff =>
      'Tam zamanlı alarmlar kapalı; bildirimler birkaç dakika gecikebilir.';

  @override
  String get allowExact => 'Tam zamanlı alarmlara izin ver';

  @override
  String get methodMwl => 'Müslüman Dünya Birliği';

  @override
  String get methodEgyptian => 'Mısır Genel Kurumu';

  @override
  String get methodKarachi => 'Karaçi İslami İlimler Üniversitesi';

  @override
  String get methodUmmAlQura => 'Ümmü\'l-Kura, Mekke';

  @override
  String get methodDubai => 'Dubai';

  @override
  String get methodMoonSighting => 'Hilal Gözlem Komitesi';

  @override
  String get methodNorthAmerica => 'ISNA (Kuzey Amerika)';

  @override
  String get methodKuwait => 'Kuveyt';

  @override
  String get methodQatar => 'Katar';

  @override
  String get methodSingapore => 'Singapur';

  @override
  String get methodTurkey => 'Diyanet (Türkiye)';

  @override
  String get methodTehran => 'Tahran';

  @override
  String get widgetsHelpTitle => 'Ana ekran widget\'ları';

  @override
  String get widgetsHelpIos =>
      'Ana ekranda boş bir alana basılı tutun, + simgesine dokunun, Waqt\'ı arayın ve küçük, orta ya da kilit ekranı widget\'ını seçin.';

  @override
  String get widgetsHelpAndroid =>
      'Ana ekranda boş bir alana basılı tutun, Widget\'lar\'a dokunun, Waqt\'ı bulun ve widget\'ı ekrana sürükleyin. Düğmesi mevcut namazı işaretler.';

  @override
  String get widgetsHelpData =>
      'Widget\'lar uygulamayı açmasanız da sonraki yedi günün vakitlerini gösterir.';

  @override
  String get widgetNext => 'Sıradaki';

  @override
  String widgetWindowOpen(String prayer) {
    return '$prayer · vakit girdi';
  }

  @override
  String get widgetMarkPrayed => 'Kılındı olarak işaretle';

  @override
  String widgetMarked(String prayer) {
    return '$prayer işaretlendi';
  }

  @override
  String get locationTitle => 'Konum';

  @override
  String get locationUseCurrent => 'Konumumu kullan';

  @override
  String get locationSearch => 'Şehir ara';

  @override
  String get locationCoordinates => 'Koordinat gir';

  @override
  String get locationLatitude => 'Enlem';

  @override
  String get locationLongitude => 'Boylam';

  @override
  String get locationName => 'Yer adı';

  @override
  String get locationLocating => 'Konumunuz bulunuyor…';

  @override
  String get locationDenied =>
      'Konum izni verilmedi. Bunun yerine bir şehir seçin.';

  @override
  String get locationFailed => 'Konumunuz alınamadı. Bir şehir seçin.';

  @override
  String locationNearby(String city) {
    return '$city yakınında';
  }

  @override
  String get locationInvalid => 'Geçerli enlem ve boylam girin.';

  @override
  String get locationPrivacy =>
      'Konumunuz yalnızca namaz vakitlerini ve kıbleyi hesaplamak için kullanılır. Bu telefondan asla çıkmaz.';

  @override
  String get obGreeting => 'Esselâmü aleyküm';

  @override
  String get obLanguageTitle => 'Dilinizi seçin';

  @override
  String get obLanguageSub => 'Daha sonra Ayarlar\'dan değiştirebilirsiniz.';

  @override
  String get obLocationTitle => 'Nerede namaz kılıyorsunuz?';

  @override
  String obMethodLine(String method, String madhab) {
    return '$method · $madhab ikindi';
  }

  @override
  String get obAdvanced => 'Gelişmiş';

  @override
  String get obNotifTitle => 'Hiçbir namazı kaçırmayın';

  @override
  String get obNotifBody =>
      'Her namaz vaktinde nazik bir bildirim alın. Daha sonra her namaz için ezan, sessiz veya kapalı seçin.';

  @override
  String get obAllowNotif => 'Bildirimlere izin ver';

  @override
  String get obNotifAllowed => 'Bildirimler açık';

  @override
  String get obBatteryTitle => 'Bildirimler zamanında gelsin';

  @override
  String get obBatteryBody =>
      'Bazı Android telefonlar pil tasarrufu için uygulamaları durdurur. Ezanın gecikmemesi için pil ayarlarında Waqt\'ı \"Kısıtlamasız\" yapın.';

  @override
  String get obOpenBattery => 'Pil ayarlarını aç';

  @override
  String get obStart => 'Başla';

  @override
  String get obPrivacy => 'Hesap yok. Reklam yok. Her şey bu telefonda kalır.';

  @override
  String notifPrayerTitle(String prayer, String time) {
    return '$prayer · $time';
  }

  @override
  String notifPrayerBody(String prayer, String place) {
    return '$place: $prayer vakti girdi.';
  }

  @override
  String notifRemindTitle(String prayer) {
    return 'Hatırlatma · $prayer';
  }

  @override
  String notifRemindBody(String prayer) {
    return '$prayer namazını hatırlatmamı istediniz.';
  }

  @override
  String get notifMorningBody => 'Güne birkaç dakikalık zikirle başlayın.';

  @override
  String get notifEveningBody => 'Akşamdan önce birkaç dakikalık zikir.';

  @override
  String notifSuhoorTitle(String time) {
    return 'Sahur $time bitiyor';
  }

  @override
  String notifSuhoorBody(String min) {
    return 'Sabaha $min dakika kaldı.';
  }

  @override
  String get notifIftarTitle => 'İftar vakti';

  @override
  String notifIftarBody(String place) {
    return '$place: akşam vakti girdi. Allah orucunuzu kabul etsin.';
  }

  @override
  String get chanAdhan => 'Namaz vakitleri · ezan';

  @override
  String get chanStandard => 'Namaz vakitleri · standart ses';

  @override
  String get chanReminders => 'Hatırlatmalar';

  @override
  String get tabQuran => 'Kur’an';

  @override
  String get tabLibrary => 'Kütüphane';

  @override
  String get quranTitle => 'Kur’an-ı Kerim';

  @override
  String get quranContinue => 'Okumaya devam et';

  @override
  String get quranStart => 'Okumaya başla';

  @override
  String get quranStartHint => 'Fâtiha suresiyle başlayın.';

  @override
  String quranAyahN(String n) {
    return 'Ayet $n';
  }

  @override
  String quranPageN(String n) {
    return 'Sayfa $n';
  }

  @override
  String quranJuzN(String n) {
    return 'Cüz $n';
  }

  @override
  String get quranSurahs => 'Sureler';

  @override
  String get quranJuzTab => 'Cüzler';

  @override
  String quranAyahCount(int count) {
    return '$count ayet';
  }

  @override
  String get quranMeccan => 'Mekkî';

  @override
  String get quranMedinan => 'Medenî';

  @override
  String get quranSearch => 'Kur’an’da ara';

  @override
  String get quranSearchHint => 'Sure, 2:255 veya kelimeler';

  @override
  String quranGoTo(String ref) {
    return '$ref git';
  }

  @override
  String get quranNoResults => 'Sonuç yok. Daha az kelime veya Arapça deneyin.';

  @override
  String quranResults(int count) {
    return '$count ayet';
  }

  @override
  String quranSearchIn(String translation) {
    return 'Arapça ve $translation içinde aranıyor';
  }

  @override
  String get quranBookmarks => 'Yer imleri';

  @override
  String get quranNoBookmarks =>
      'Henüz yer imi yok. Kaydetmek için bir ayete dokunun.';

  @override
  String get quranBookmark => 'Yer imi ekle';

  @override
  String get quranRemoveBookmark => 'Yer imini kaldır';

  @override
  String get quranRemoveNoteConfirm => 'Bu yer imi ve notu silinsin mi?';

  @override
  String get quranBookmarked => 'Yer imlerine eklendi';

  @override
  String get moreActions => 'Daha fazla';

  @override
  String get copy => 'Kopyala';

  @override
  String get copied => 'Kopyalandı';

  @override
  String get shareImage => 'Görsel olarak paylaş';

  @override
  String get shareText => 'Metni paylaş';

  @override
  String get share => 'Paylaş';

  @override
  String get quranAddNote => 'Not ekle';

  @override
  String get quranNoteHint => 'Bu ayet sizin için ne ifade ediyor?';

  @override
  String get quranSetLastRead => 'Burada kaldım olarak işaretle';

  @override
  String get quranReadingSettings => 'Okuma ayarları';

  @override
  String get quranArabicSize => 'Arapça boyutu';

  @override
  String get quranTextSize => 'Meal boyutu';

  @override
  String get quranShowTranslation => 'Meali göster';

  @override
  String get quranShowTranslit => 'Okunuşu göster';

  @override
  String get quranTranslation => 'Meal';

  @override
  String get quranArabicFont => 'Arapça yazı';

  @override
  String get quranFontUthmani => 'Osmanî';

  @override
  String get quranFontNaskh => 'Nesih (sade)';

  @override
  String get quranSepia => 'Sıcak kâğıt';

  @override
  String get quranKeepAwake => 'Okurken ekranı açık tut';

  @override
  String get quranMemorize => 'Ezber modu';

  @override
  String get quranMemorizeHint =>
      'Arapça gizli. Okuyun, sonra kontrol için dokunun.';

  @override
  String get quranTapToReveal => 'Görmek için dokunun';

  @override
  String get quranModeList => 'Mealli görünüm';

  @override
  String get quranModePage => 'Mushaf sayfaları';

  @override
  String get quranSajda => 'Secde';

  @override
  String get quranToday => 'Bugün';

  @override
  String quranGoal(String read, String goal) {
    return '$goal ayetten $read';
  }

  @override
  String quranGoalPages(String read, String goal) {
    return '$goal sayfadan $read';
  }

  @override
  String get khatmLast14 => 'Son 14 gün';

  @override
  String get quranGoalDone => 'Günlük hedef tamam';

  @override
  String quranStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün üst üste',
      zero: 'Bugün bir seri başlatın',
    );
    return '$_temp0';
  }

  @override
  String get quranDailyGoal => 'Günlük hedef';

  @override
  String quranDailyGoalValue(int count) {
    return 'Günde $count ayet';
  }

  @override
  String get quranReadTracking =>
      'Ayetler üzerlerinde biraz durduğunuzda okunmuş sayılır.';

  @override
  String get quranOfDay => 'Günün ayeti';

  @override
  String get quranOpenInReader => 'Kur’an’da aç';

  @override
  String quranSurahInfo(String place, String ayahs) {
    return '$place · $ayahs';
  }

  @override
  String quranNextSurah(String name) {
    return 'Sonraki: $name';
  }

  @override
  String get quranLoading => 'Kur’an açılıyor…';

  @override
  String get quranReadSurah => 'Oku';

  @override
  String get khatmTitle => 'Hatim planı';

  @override
  String get khatmShort => 'Hatim';

  @override
  String get khatmIntro =>
      'Kur’an’ın tamamını kendi temponuzda okuyun. Waqt kalan kısmı kalan günlere dağıtır; kaçırılan bir gün planı bozmaz.';

  @override
  String get khatmChoose => 'Bitirme süresi';

  @override
  String khatmDays(int count) {
    return '$count gün';
  }

  @override
  String khatmPerDay(String pages) {
    return '≈ günde $pages sayfa';
  }

  @override
  String get khatmStart => 'Planı başlat';

  @override
  String khatmDayOf(String day, String total) {
    return '$total günün $day. günü';
  }

  @override
  String khatmTodayTarget(String pages, String from) {
    return 'Bugün: $pages sayfa, $from itibaren';
  }

  @override
  String get khatmTodayDone => 'Bugünkü kısım tamam. Barakallahu fik!';

  @override
  String get khatmBehind =>
      'Biraz geridesiniz — bugünkü kısım biraz daha uzun.';

  @override
  String get khatmOnTrack => 'Planda';

  @override
  String get khatmEnd => 'Planı bitir';

  @override
  String get khatmEndConfirm =>
      'Bu plan bitirilsin mi? Okuma geçmişiniz kalır.';

  @override
  String get khatmComplete => 'Hatim tamamlandı! Allah kabul etsin.';

  @override
  String khatmProgress(String read, String total) {
    return '$total sayfadan $read';
  }

  @override
  String khatmDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün kaldı',
      zero: 'Son gün',
    );
    return '$_temp0';
  }

  @override
  String get khatmRamadan => 'Ramazan';

  @override
  String get khatmNewPlan => 'Yeni plan';

  @override
  String get khatmShareText => 'Waqt ile Kur’an’ı hatmettim. Elhamdülillah!';

  @override
  String get khatmReminder => 'Yatsıdan sonra hatırlat';

  @override
  String get notifQuranTitle => 'Bugünün Kur’an’ı';

  @override
  String get notifQuranBody => 'Uyumadan önce Kur’an ile birkaç dakika.';

  @override
  String get hifzTitle => 'Ezber';

  @override
  String get hifzIntro =>
      'Ezberlediğiniz sureleri ekleyin. Her birini aralıklı bir düzende tekrar edin — 1, 3, 7, 14, 30 ve 90 gün — böylece sağlam kalsın.';

  @override
  String get hifzAdd => 'Sure ekle';

  @override
  String get hifzDue => 'Tekrar zamanı';

  @override
  String get hifzUpcoming => 'Yaklaşan';

  @override
  String get hifzReview => 'Tekrar et';

  @override
  String get hifzHowWent => 'Tekrar nasıl geçti?';

  @override
  String get hifzStrong => 'Sağlam';

  @override
  String get hifzWeak => 'Çalışmalı';

  @override
  String hifzNext(String date) {
    return 'Sonraki tekrar $date';
  }

  @override
  String get hifzEmpty =>
      'Listeniz boş. Amme cüzündeki kısa sureler harika bir başlangıç.';

  @override
  String get hifzRemove => 'Listeden çıkar';

  @override
  String get hifzSuggested => 'Önerilen';

  @override
  String get hifzAllSurahs => 'Tüm sureler';

  @override
  String get hifzTileIdle => 'Aralıklı tekrar';

  @override
  String hifzDueCount(int count) {
    return 'Bugün $count sure';
  }

  @override
  String get khatmTileIdle => 'Planlı bitirin';

  @override
  String get hifzAgain => 'Tekrar';

  @override
  String get quranJumpTo => 'Sure, cüz veya sayfaya git';

  @override
  String get quranPages => 'Sayfalar';

  @override
  String get hifzMemorized => 'Ezberlendi';

  @override
  String get libraryHadith => 'Hadis külliyatı';

  @override
  String get libraryDuas => 'Dualar';

  @override
  String get libraryDuasSub => 'Günün her anı için';

  @override
  String get libraryNames => 'Allah’ın 99 ismi';

  @override
  String get libraryNamesSub => 'Esmâ-ül Hüsnâ';

  @override
  String get libraryLearn => 'Öğren';

  @override
  String get libraryLearnSub => 'Namaz, abdest, oruç ve daha fazlası';

  @override
  String get libraryAdhkar => 'Sabah ve akşam zikirleri';

  @override
  String get librarySaved => 'Kaydedilenler';

  @override
  String get librarySavedEmpty =>
      'Bir hadisi, duayı veya ismi kaydedin; burada görünür.';

  @override
  String get libraryContentReview =>
      'Metinler klasik kaynaklardan derlenmiştir. Şüphe durumunda bir âlime danışın.';

  @override
  String get hadithTitle => 'Hadis';

  @override
  String get hadithOfDay => 'Günün hadisi';

  @override
  String get hadithBookNawawi => 'Nevevî’nin 40 Hadisi';

  @override
  String get hadithBookQudsi => '40 Kudsî Hadis';

  @override
  String get hadithBookBukhari => 'Sahîh-i Buhârî';

  @override
  String get hadithBookMuslim => 'Sahîh-i Müslim';

  @override
  String hadithCount(int count) {
    return '$count hadis';
  }

  @override
  String hadithN(String n) {
    return 'Hadis $n';
  }

  @override
  String get hadithBooks => 'Kitaplar';

  @override
  String get hadithSearchHint => 'Kelime veya numara arayın';

  @override
  String get hadithShowArabic => 'Arapça metni göster';

  @override
  String get hadithTranslation => 'Tercüme';

  @override
  String get hadithNoResults => 'Hadis bulunamadı.';

  @override
  String get hadithFallback =>
      'Dilinizde mevcut değil — İngilizce gösteriliyor.';

  @override
  String hadithRange(String from, String to) {
    return 'Hadis $from–$to';
  }

  @override
  String get hadithOpenBook => 'Külliyatı oku';

  @override
  String get langEnglish => 'İngilizce';

  @override
  String get langRussian => 'Rusça';

  @override
  String get langTurkish => 'Türkçe';

  @override
  String get duaSearchHint => 'Dua ara';

  @override
  String duaRepeat(String count) {
    return '$count kez';
  }

  @override
  String get duaAll => 'Tümü';

  @override
  String get duaFavorites => 'Favoriler';

  @override
  String get namesQuiz => 'Alıştırma';

  @override
  String get namesQuizQuestion => 'Bu isim ne anlama gelir?';

  @override
  String namesQuizScore(String right, String total) {
    return '$total sorudan $right doğru';
  }

  @override
  String get namesQuizNext => 'Sonraki';

  @override
  String get namesQuizAgain => 'Tekrar alıştırma';

  @override
  String namesLearned(String count) {
    return '99’dan $count öğrenildi';
  }

  @override
  String get namesHadith =>
      '“Allah’ın doksan dokuz ismi vardır; onları ezberleyen cennete girer.” — Buhârî ve Müslim';

  @override
  String learnSteps(int count) {
    return '$count adım';
  }

  @override
  String learnStepN(String n) {
    return 'Adım $n';
  }

  @override
  String get meQuranStreak => 'Kur’an serisi';

  @override
  String get meQuranDaily => 'her gün okuma';

  @override
  String get meAyahsRead => 'Okunan ayetler';

  @override
  String get notifTestTitle => 'Test bildirimi gönder';

  @override
  String get notifTestSub =>
      '5 saniye içinde gelir — sesi kontrol etmek için telefonu kilitleyin.';

  @override
  String get notifTestBody =>
      'Bunu görüp duyuyorsanız namaz bildirimleri çalışacaktır.';

  @override
  String get notifTestSent => 'Test bildirimi yolda…';

  @override
  String get fastsOwedTitle => 'Kaza edilecek oruçlar';

  @override
  String fastsOwedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün',
      zero: 'Hepsi kaza edildi — elhamdülillah',
    );
    return '$_temp0';
  }

  @override
  String get fastsOwedSub =>
      'Kaçırılan veya mazeretli Ramazan günleri, tuttuğunuz kaza oruçları düşülerek.';

  @override
  String get fastsLogQada => 'Bugün kaza orucu tuttum';

  @override
  String get backupTitle => 'Yedekle ve geri yükle';

  @override
  String get backupRowSub => 'Verilerinizi yeni telefona taşıyın';

  @override
  String get backupIntro =>
      'Waqt’ta hesap ve bulut yok. Bir yedek dosyası dışa aktarın ve güvenli bir yerde saklayın (Dosyalar, Telegram “Kayıtlı mesajlar”, kendinize e-posta). Her telefonda geri yükleyin.';

  @override
  String get backupExport => 'Yedeği dışa aktar';

  @override
  String get backupImport => 'Dosyadan geri yükle';

  @override
  String get backupRestore => 'Geri yükle';

  @override
  String get backupRestoreTitle => 'Tüm veriler değiştirilsin mi?';

  @override
  String get backupRestoreBody =>
      'Bu telefondaki her şey yedekle değiştirilecek.';

  @override
  String get backupRestored => 'Geri yüklendi. Tekrar hoş geldiniz!';

  @override
  String get backupInvalid => 'Bu dosya bir Waqt yedeği değil.';

  @override
  String get zakatTitle => 'Zekât hesaplayıcı';

  @override
  String get zakatShort => 'Zekât';

  @override
  String get zakatDue => 'Ödenecek zekât';

  @override
  String get zakatAbove => 'Nisabın üzerinde — %2,5 ödenir.';

  @override
  String get zakatBelow => 'Nisabın altında — zekât gerekmez.';

  @override
  String get zakatNeedPrice =>
      'Nisabı bulmak için bugünkü altın veya gümüş fiyatını girin.';

  @override
  String get zakatWealth => 'Zekâta tabi servet';

  @override
  String get zakatNisab => 'Nisap';

  @override
  String get zakatNisabBasis => 'Nisap ölçüsü';

  @override
  String get zakatNisabGold => 'Altın · 85 g';

  @override
  String get zakatNisabSilver => 'Gümüş · 595 g';

  @override
  String get zakatPriceHint =>
      'Waqt internete bağlanmaz — gram başına bugünkü yerel fiyatı yazın.';

  @override
  String get zakatGoldPrice => 'Altın fiyatı';

  @override
  String get zakatSilverPrice => 'Gümüş fiyatı';

  @override
  String get zakatPerGram => 'gram başına';

  @override
  String get zakatGrams => 'g';

  @override
  String get zakatAssets => 'Varlıklarınız';

  @override
  String get zakatLiabilities => 'Şu anki borçlarınız';

  @override
  String get zakatCash => 'Nakit ve banka';

  @override
  String get zakatGold => 'Altın';

  @override
  String get zakatSilver => 'Gümüş';

  @override
  String get zakatInvestments => 'Hisse ve yatırımlar';

  @override
  String get zakatBusiness => 'Ticari mallar';

  @override
  String get zakatReceivables => 'Size olan alacaklar';

  @override
  String get zakatDebts => 'Vadesi gelen borçlar';

  @override
  String get zakatRecord => 'Sadaka harcaması olarak kaydet';

  @override
  String get zakatRecorded => 'Harcamalara kaydedildi';

  @override
  String get zakatNote =>
      'Zekât, bir kamerî yıl elde tutulan ve nisabı aşan servetin %2,5’idir. Ev, araba ve kişisel eşyalar sayılmaz. Durumunuz için bir âlime danışın.';

  @override
  String get timetableTitle => 'Namaz vakitleri çizelgesi';

  @override
  String get timetableShort => 'Çizelge';

  @override
  String get timetableNote =>
      'Vakitler yönteminize, ikindi ayarınıza ve cami düzeltmelerine göredir. Cumalar vurgulanır.';

  @override
  String get habitsTitle => 'Alışkanlıklar';

  @override
  String get habitsAdd => 'Yeni alışkanlık';

  @override
  String get habitsNameHint => 'örn. Kur’an’dan bir sayfa oku';

  @override
  String get habitsEmpty =>
      'Küçük günlük alışkanlıklar birikir. Sürdürmek istediğiniz birini ekleyin.';

  @override
  String habitsDoneToday(String done, String total) {
    return 'Bugün $total’dan $done';
  }

  @override
  String get habitsSuggestions => 'Fikirler';

  @override
  String get habitSugQuran => 'Kur’an’dan bir sayfa oku';

  @override
  String get habitSugDhikr => '100× Sübhanallah';

  @override
  String get habitSugWater => '8 bardak su iç';

  @override
  String get habitSugWalk => '20 dakika yürüyüş';

  @override
  String get habitSugSadaqa => 'Biraz sadaka ver';

  @override
  String get habitSugParents => 'Anne babamı ara';

  @override
  String get habitSugGratitude => 'Şükrettiğim 3 şeyi yaz';

  @override
  String get habitSugRead => 'Kitaptan 10 sayfa oku';

  @override
  String get habitSugSleep => '23:00’ten önce uyu';

  @override
  String get shareThemeEmerald => 'Zümrüt';

  @override
  String get shareThemePaper => 'Kâğıt';

  @override
  String get shareThemeNight => 'Gece';

  @override
  String get shareWithArabic => 'Arapça';

  @override
  String get shareWithTranslation => 'Meal';

  @override
  String get shareFooter => 'Waqt · gününüz namaz etrafında';
}
