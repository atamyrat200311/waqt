// Single source for all UI strings. Generates lib/core/l10n/app_{en,tk,tr,ru}.arb.
//
//   dart run tool/gen_arb.dart && flutter gen-l10n
//
// Each entry: key -> [en, tk, tr, ru] (+ optional description). A leading "?" on a
// translation marks it REVIEW (translator unsure); the "?" is stripped and an
// `@key` description "REVIEW" is written into that language's ARB.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

const langs = ['en', 'tk', 'tr', 'ru'];

/// Placeholders whose type must be int (used in plurals or numeric formatting).
final intPlaceholder = RegExp(r'\{(\w+), plural');
final selectPlaceholder = RegExp(r'\{(\w+), select');
final simplePlaceholder = RegExp(r'\{(\w+)\}');

const Map<String, List<String>> s = {
  // ---------------------------------------------------------------- general
  'appName': ['Waqt', 'Waqt', 'Waqt', 'Waqt'],
  'tabToday': ['Today', 'Şu gün', 'Bugün', 'Сегодня'],
  'tabTools': ['Tools', 'Gurallar', 'Araçlar', 'Инструменты'],
  'tabMe': ['Me', 'Men', 'Ben', 'Я'],
  'add': ['Add', 'Goş', 'Ekle', 'Добавить'],
  'save': ['Save', 'Ýatda sakla', 'Kaydet', 'Сохранить'],
  'cancel': ['Cancel', 'Ýatyr', 'İptal', 'Отмена'],
  'done': ['Done', 'Taýýar', 'Tamam', 'Готово'],
  'close': ['Close', 'Ýap', 'Kapat', 'Закрыть'],
  'back': ['Back', 'Yza', 'Geri', 'Назад'],
  'next': ['Next', 'Indiki', 'İleri', 'Далее'],
  'skip': ['Skip', 'Geç', 'Atla', 'Пропустить'],
  'continueLabel': ['Continue', 'Dowam et', 'Devam', 'Продолжить'],
  'notNow': ['Not now', 'Häzir däl', 'Şimdi değil', 'Не сейчас'],
  'edit': ['Edit', 'Üýtget', 'Düzenle', 'Изменить'],
  'delete': ['Delete', 'Poz', 'Sil', 'Удалить'],
  'undo': ['Undo', 'Yzyna al', 'Geri al', 'Отменить'],
  'reset': ['Reset', 'Täzeden', 'Sıfırla', 'Сброс'],
  'today': ['Today', 'Şu gün', 'Bugün', 'Сегодня'],
  'yesterday': ['Yesterday', 'Düýn', 'Dün', 'Вчера'],
  'pickDate': ['Pick a date', 'Sene saýla', 'Tarih seç', 'Выбрать дату'],
  'listAnd': ['{a} and {b}', '{a} we {b}', '{a} ve {b}', '{a} и {b}'],
  'errorGeneric': [
    'Something went wrong.',
    'Bir zat ýalňyş gitdi.',
    'Bir şeyler ters gitti.',
    'Что-то пошло не так.'
  ],
  'tryAgain': ['Try again', 'Gaýtadan synanyş', 'Tekrar dene', 'Повторить'],

  // ------------------------------------------------------------- prayers
  'prayerFajr': ['Fajr', 'Ertir', 'Sabah', 'Фаджр'],
  'prayerSunrise': ['Sunrise', 'Gün dogşy', 'Güneş', 'Восход'],
  'prayerDhuhr': ['Dhuhr', 'Öýle', 'Öğle', 'Зухр'],
  'prayerAsr': ['Asr', 'Ikindi', 'İkindi', 'Аср'],
  'prayerMaghrib': ['Maghrib', 'Agşam', 'Akşam', 'Магриб'],
  'prayerIsha': ['Isha', 'Ýassy', 'Yatsı', 'Иша'],

  // ------------------------------------------------------- dates & units
  'weekdayName': [
    '{day, select, mon{Monday} tue{Tuesday} wed{Wednesday} thu{Thursday} fri{Friday} sat{Saturday} other{Sunday}}',
    '{day, select, mon{Duşenbe} tue{Sişenbe} wed{Çarşenbe} thu{Penşenbe} fri{Anna} sat{Şenbe} other{Ýekşenbe}}',
    '{day, select, mon{Pazartesi} tue{Salı} wed{Çarşamba} thu{Perşembe} fri{Cuma} sat{Cumartesi} other{Pazar}}',
    '{day, select, mon{понедельник} tue{вторник} wed{среда} thu{четверг} fri{пятница} sat{суббота} other{воскресенье}}',
  ],
  'weekdayShort': [
    '{day, select, mon{Mon} tue{Tue} wed{Wed} thu{Thu} fri{Fri} sat{Sat} other{Sun}}',
    '{day, select, mon{Duş} tue{Siş} wed{Çar} thu{Pen} fri{Ann} sat{Şen} other{Ýek}}',
    '{day, select, mon{Pzt} tue{Sal} wed{Çar} thu{Per} fri{Cum} sat{Cmt} other{Paz}}',
    '{day, select, mon{Пн} tue{Вт} wed{Ср} thu{Чт} fri{Пт} sat{Сб} other{Вс}}',
  ],
  'weekdayInitial': [
    '{day, select, mon{M} tue{T} wed{W} thu{T} fri{F} sat{S} other{S}}',
    '{day, select, mon{D} tue{S} wed{Ç} thu{P} fri{A} sat{Ş} other{Ý}}',
    '{day, select, mon{P} tue{S} wed{Ç} thu{P} fri{C} sat{C} other{P}}',
    '{day, select, mon{П} tue{В} wed{С} thu{Ч} fri{П} sat{С} other{В}}',
  ],
  'monthName': [
    '{month, select, jan{January} feb{February} mar{March} apr{April} may{May} jun{June} jul{July} aug{August} sep{September} oct{October} nov{November} other{December}}',
    '{month, select, jan{ýanwar} feb{fewral} mar{mart} apr{aprel} may{maý} jun{iýun} jul{iýul} aug{awgust} sep{sentýabr} oct{oktýabr} nov{noýabr} other{dekabr}}',
    '{month, select, jan{Ocak} feb{Şubat} mar{Mart} apr{Nisan} may{Mayıs} jun{Haziran} jul{Temmuz} aug{Ağustos} sep{Eylül} oct{Ekim} nov{Kasım} other{Aralık}}',
    '{month, select, jan{января} feb{февраля} mar{марта} apr{апреля} may{мая} jun{июня} jul{июля} aug{августа} sep{сентября} oct{октября} nov{ноября} other{декабря}}',
  ],
  'monthShort': [
    '{month, select, jan{Jan} feb{Feb} mar{Mar} apr{Apr} may{May} jun{Jun} jul{Jul} aug{Aug} sep{Sep} oct{Oct} nov{Nov} other{Dec}}',
    '{month, select, jan{ýan} feb{few} mar{mar} apr{apr} may{maý} jun{iýn} jul{iýl} aug{awg} sep{sen} oct{okt} nov{noý} other{dek}}',
    '{month, select, jan{Oca} feb{Şub} mar{Mar} apr{Nis} may{May} jun{Haz} jul{Tem} aug{Ağu} sep{Eyl} oct{Eki} nov{Kas} other{Ara}}',
    '{month, select, jan{янв} feb{фев} mar{мар} apr{апр} may{мая} jun{июн} jul{июл} aug{авг} sep{сен} oct{окт} nov{ноя} other{дек}}',
  ],
  'monthStandalone': [
    '{month, select, jan{January} feb{February} mar{March} apr{April} may{May} jun{June} jul{July} aug{August} sep{September} oct{October} nov{November} other{December}}',
    '{month, select, jan{Ýanwar} feb{Fewral} mar{Mart} apr{Aprel} may{Maý} jun{Iýun} jul{Iýul} aug{Awgust} sep{Sentýabr} oct{Oktýabr} nov{Noýabr} other{Dekabr}}',
    '{month, select, jan{Ocak} feb{Şubat} mar{Mart} apr{Nisan} may{Mayıs} jun{Haziran} jul{Temmuz} aug{Ağustos} sep{Eylül} oct{Ekim} nov{Kasım} other{Aralık}}',
    '{month, select, jan{Январь} feb{Февраль} mar{Март} apr{Апрель} may{Май} jun{Июнь} jul{Июль} aug{Август} sep{Сентябрь} oct{Октябрь} nov{Ноябрь} other{Декабрь}}',
  ],
  'dateLong': [
    '{weekday}, {day} {month}',
    '?{day}-nji {month}, {weekday}',
    '{day} {month} {weekday}',
    '{weekday}, {day} {month}',
  ],
  'dateDayMonth': ['{day} {month}', '{day}-nji {month}', '{day} {month}', '{day} {month}'],
  'dateShortWeekday': [
    '{weekday} {day} {month}',
    '{day} {month}, {weekday}',
    '{day} {month} {weekday}',
    '{weekday}, {day} {month}',
  ],
  'hijriMonth': [
    '{month, select, m1{Muḥarram} m2{Ṣafar} m3{Rabīʿ I} m4{Rabīʿ II} m5{Jumādā I} m6{Jumādā II} m7{Rajab} m8{Shaʿbān} m9{Ramaḍān} m10{Shawwāl} m11{Dhū al-Qaʿdah} other{Dhū al-Ḥijjah}}',
    '?{month, select, m1{Muharram} m2{Sapar} m3{Rebiulewwel} m4{Rebiulahyr} m5{Jumadel-ewwel} m6{Jumadel-ahyr} m7{Rejep} m8{Şagban} m9{Remezan} m10{Şawwal} m11{Zülkaáde} other{Zülhijje}}',
    '{month, select, m1{Muharrem} m2{Safer} m3{Rebiülevvel} m4{Rebiülahir} m5{Cemaziyelevvel} m6{Cemaziyelahir} m7{Recep} m8{Şaban} m9{Ramazan} m10{Şevval} m11{Zilkade} other{Zilhicce}}',
    '{month, select, m1{Мухаррам} m2{Сафар} m3{Раби аль-авваль} m4{Раби ас-сани} m5{Джумада аль-уля} m6{Джумада ас-сани} m7{Раджаб} m8{Шаабан} m9{Рамадан} m10{Шавваль} m11{Зуль-када} other{Зуль-хиджа}}',
  ],
  'hijriMonthLong': [
    '{month, select, m1{Muḥarram} m2{Ṣafar} m3{Rabīʿ al-Awwal} m4{Rabīʿ al-Thānī} m5{Jumādā al-Ūlā} m6{Jumādā al-Ākhirah} m7{Rajab} m8{Shaʿbān} m9{Ramaḍān} m10{Shawwāl} m11{Dhū al-Qaʿdah} other{Dhū al-Ḥijjah}}',
    '?{month, select, m1{Muharram} m2{Sapar} m3{Rebiulewwel} m4{Rebiulahyr} m5{Jumadel-ewwel} m6{Jumadel-ahyr} m7{Rejep} m8{Şagban} m9{Remezan} m10{Şawwal} m11{Zülkaáde} other{Zülhijje}}',
    '{month, select, m1{Muharrem} m2{Safer} m3{Rebiülevvel} m4{Rebiülahir} m5{Cemaziyelevvel} m6{Cemaziyelahir} m7{Recep} m8{Şaban} m9{Ramazan} m10{Şevval} m11{Zilkade} other{Zilhicce}}',
    '{month, select, m1{Мухаррам} m2{Сафар} m3{Раби аль-авваль} m4{Раби ас-сани} m5{Джумада аль-уля} m6{Джумада ас-сани} m7{Раджаб} m8{Шаабан} m9{Рамадан} m10{Шавваль} m11{Зуль-када} other{Зуль-хиджа}}',
  ],
  'hijriDate': ['{day} {month} {year}', '{day} {month} {year}', '{day} {month} {year}', '{day} {month} {year}'],
  'unitH': ['h', 's', 'sa', 'ч'],
  'unitM': ['m', 'm', 'dk', 'м'],
  'unitS': ['s', 'sek', 'sn', 'с'],
  'durationHM': ['{h}h {m}m', '{h} s {m} min', '{h} sa {m} dk', '{h} ч {m} мин'],
  'durationM': ['{m}m', '{m} min', '{m} dk', '{m} мин'],
  'minutesShort': ['{m} min', '{m} min', '{m} dk', '{m} мин'],
  'inDuration': ['in {d}', '{d} soň', '{d} sonra', 'через {d}'],
  'daysCount': [
    '{n, plural, =1{1 day} other{{n} days}}',
    '{n, plural, other{{n} gün}}',
    '{n, plural, other{{n} gün}}',
    '{n, plural, =1{{n} день} few{{n} дня} many{{n} дней} other{{n} дня}}',
  ],
  'daysUnit': [
    '{n, plural, =1{day} other{days}}',
    '{n, plural, other{gün}}',
    '{n, plural, other{gün}}',
    '{n, plural, =1{день} few{дня} many{дней} other{дня}}',
  ],
  'eventCountdown': [
    '{name} {days, plural, =0{today} =1{tomorrow} other{in {days} days}}',
    '?{name} {days, plural, =0{şu gün} =1{ertir} other{{days} günden}}',
    '{name}: {days, plural, =0{bugün} =1{yarın} other{{days} gün sonra}}',
    '{name} {days, plural, =0{сегодня} =1{завтра} few{через {days} дня} many{через {days} дней} other{через {days} дня}}',
  ],

  // ------------------------------------------------------------------ home
  'homeNextPrayer': ['Next prayer', 'Indiki namaz', 'Sıradaki namaz', 'Следующий намаз'],
  'homeIn': ['in', '', '', 'через'],
  'homeInAfter': ['', 'soň', 'sonra', ''],
  'homeRamadanKicker': ['Ramadan · Iftar', 'Remezan · Agyz açmak', 'Ramazan · İftar', 'Рамадан · Ифтар'],
  'homeIftar': ['Iftar', 'Agyz açmak', 'İftar', 'Ифтар'],
  'homeMaghribAt': ['Maghrib {time}', 'Agşam {time}', 'Akşam {time}', 'Магриб {time}'],
  'homeSuhoorLine': [
    'Suhoor ends {time} · Fast {n} of {total}',
    '?Sähri {time}-da gutarýar · Agyz {n}/{total}',
    'Sahur {time} bitiyor · Oruç {n}/{total}',
    'Сухур до {time} · Пост {n} из {total}',
  ],
  'homeAfterIshaKicker': ['After Isha · {time}', 'Ýassydan soň · {time}', 'Yatsıdan sonra · {time}', 'После иши · {time}'],
  'homeYourDay': ['Your day', 'Siziň günüňiz', 'Gününüz', 'Ваш день'],
  'homeUpNext': ['Up next', 'Indiki', 'Sırada', 'Далее'],
  'homeStart': ['Start', 'Başla', 'Başla', 'Начать'],
  'homeMarkDone': ['Done', 'Taýýar', 'Bitti', 'Готово'],
  'homeAdhkarAfter': ['{window} · {min} min', '{window} · {min} min', '{window} · {min} dk', '{window} · {min} мин'],
  'homeTaraweeh': ['Taraweeh', 'Terawih', 'Teravih', 'Таравих'],
  'homeTaraweehSub': [
    'At the mosque · reminder {time}',
    '?Metjitde · ýatlatma {time}',
    'Camide · hatırlatma {time}',
    'В мечети · напоминание {time}',
  ],
  'homeSpentToday': ['Spent today', 'Şu günki çykdajy', 'Bugün harcanan', 'Потрачено сегодня'],
  'homeInclSadaqa': ['incl. {amount} sadaqa', '?{amount} sadaka bilen', '{amount} sadaka dahil', 'вкл. {amount} садака'],
  'homeTasks': ['Tasks', 'Işler', 'Görevler', 'Задачи'],
  'homeTasksOf': ['of {total}', '/ {total}', '/ {total}', 'из {total}'],
  'homeQadaRemaining': [
    '{count, plural, =1{1 qada remaining} other{{count} qada remaining}}',
    '?{count, plural, other{{count} kaza galdy}}',
    '{count, plural, other{{count} kaza kaldı}}',
    '{count, plural, =1{Осталась {count} када} few{Осталось {count} када} many{Осталось {count} када} other{Осталось {count} када}}',
  ],
  'homeMakeUp': ['Make up', 'Kaza et', 'Kaza kıl', 'Восполнить'],
  'homeUnmarkedTitle': [
    'You didn\'t mark {prayers} yesterday',
    '?Düýn {prayers} bellenmedi',
    'Dün {prayers} işaretlenmedi',
    'Вчера не отмечены: {prayers}',
  ],
  'homeUnmarkedBody': [
    'Nothing is added to qada unless you choose.',
    '?Siz saýlamasaňyz, kaza hiç zat goşulmaýar.',
    'Siz seçmedikçe kazaya bir şey eklenmez.',
    'Ничего не добавится в када, пока вы не решите.',
  ],
  'homeUnmarkedAllPrayed': ['All prayed', 'Hemmesi okaldy', 'Hepsi kılındı', 'Все совершены'],
  'homeAddExpense': ['Add expense', 'Çykdajy goş', 'Harcama ekle', 'Добавить расход'],
  'homeSetLocation': ['Set location', 'Ýeri saýla', 'Konum seç', 'Указать место'],

  // ------------------------------------------------------------- mark sheet
  'markClosedAtSunrise': ['closed at sunrise', 'gün dogşy bilen gutardy', 'güneş doğunca kapandı', 'закончилось с восходом'],
  'markClosedAt': ['closed at {time}', '{time}-da gutardy', '{time} kapandı', 'закончилось в {time}'],
  'markLeft': ['{d} left', '{d} galdy', '{d} kaldı', 'осталось {d}'],
  'markOpensAt': ['opens at {time}', '{time}-da başlaýar', '{time} başlıyor', 'начнётся в {time}'],
  'markOnTime': ['Prayed on time', 'Wagtynda okaldy', 'Vaktinde kılındı', 'Совершён вовремя'],
  'markOnTimeSub': ['Within the {prayer} window', '{prayer} wagtynyň içinde', '{prayer} vakti içinde', 'В пределах времени {prayer}'],
  'markCongregation': ['In congregation', 'Jemagat bilen', 'Cemaatle', 'В джамаате'],
  'markCongregationSub': ['With the jamāʿah, on time', 'Jemagat bilen, wagtynda', 'Cemaatle, vaktinde', 'С джамаатом, вовремя'],
  'markLate': ['Prayed late', 'Gijä galyp okaldy', 'Geç kılındı', 'Совершён с опозданием'],
  'markLateSub': ['After the window closed', 'Wagty geçenden soň', 'Vakti çıktıktan sonra', 'После окончания времени'],
  'markMissed': ['Missed, add to qada', 'Galdy, kaza goş', 'Kaçırıldı, kazaya ekle', 'Пропущен, добавить в када'],
  'markMissedSub': [
    'You confirm before anything is added',
    '?Bir zat goşulmazdan öň tassyklarsyňyz',
    'Bir şey eklenmeden önce onaylarsınız',
    'Вы подтвердите перед добавлением',
  ],
  'markExcused': ['Excused', 'Ötünçli', 'Mazeretli', 'Освобождён'],
  'markExcusedSub': [
    'Period mode is on — no qada, streak kept',
    '?Aýbaşy tertibi açyk — kaza ýok, yzygiderlik saklanýar',
    'Özel gün modu açık — kaza yok, seri korunur',
    'Режим «особые дни» — без када, серия сохраняется',
  ],
  'markConfirmTitle': ['Add 1 {prayer} to your qada?', '?Kaza 1 {prayer} goşulsynmy?', 'Kazaya 1 {prayer} eklensin mi?', 'Добавить 1 {prayer} в када?'],
  'markConfirmBody': [
    'You can make it up at any time. Nothing is added until you confirm.',
    '?Ony islän wagtyňyz kaza edip bilersiňiz. Tassyklamasaňyz hiç zat goşulmaýar.',
    'İstediğiniz zaman kaza edebilirsiniz. Onaylamadıkça hiçbir şey eklenmez.',
    'Восполнить можно в любое время. Ничего не добавится без подтверждения.',
  ],
  'markAddToQada': ['Add to qada', 'Kaza goş', 'Kazaya ekle', 'Добавить в када'],
  'markAdded': [
    'Added to qada. Make it up whenever you can.',
    '?Kaza goşuldy. Mümkin bolanda kaza ediň.',
    'Kazaya eklendi. Fırsat buldukça kaza edin.',
    'Добавлено в када. Восполните, когда сможете.',
  ],
  'markRemind': ['Remind me in 15 min', '15 minutdan ýatlat', '15 dk sonra hatırlat', 'Напомнить через 15 мин'],
  'markReminderSet': ['Reminder set for {time}', 'Ýatlatma {time}-a goýuldy', 'Hatırlatma {time} için kuruldu', 'Напоминание на {time}'],
  'markClear': ['Clear mark', 'Belligi aýyr', 'İşareti kaldır', 'Снять отметку'],
  'markNotStarted': [
    'This prayer\'s time hasn\'t started yet.',
    '?Bu namazyň wagty heniz girmedi.',
    'Bu namazın vakti henüz girmedi.',
    'Время этого намаза ещё не наступило.',
  ],

  // ------------------------------------------------------------------ qada
  'qadaTitle': ['Qada', 'Kaza', 'Kaza', 'Када'],
  'qadaLeft': ['prayers left\nto make up', '?kaza edilmeli\nnamaz', 'kaza edilecek\nnamaz', 'намазов\nк восполнению'],
  'qadaMadeUpSince': [
    'You\'ve made up {count} since you started',
    '?Başlanyňyzdan bäri {count} kaza etdiňiz',
    'Başladığınızdan beri {count} kaza kıldınız',
    'С начала вы восполнили {count}',
  ],
  'qadaThisWeek': ['This week', 'Şu hepde', 'Bu hafta', 'На этой неделе'],
  'qadaWeekMadeUp': ['{count} made up', '{count} kaza edildi', '{count} kaza kılındı', 'восполнено: {count}'],
  'qadaMadeUp': ['Made up', 'Kaza etdim', 'Kıldım', 'Восполнил'],
  'qadaAllDone': ['All done', 'Hemmesi', 'Tamamlandı', 'Всё'],
  'qadaAddOlder': ['Add older missed prayers', 'Öňki galan namazlary goş', 'Eski kaçırılan namazları ekle', 'Добавить старые пропуски'],
  'qadaTip': [
    'One at a time is enough. Many people pair one qada with each daily prayer.',
    '?Birden kaza etmek ýeterlik. Köpler her parz namaz bilen bir kaza okaýar.',
    'Birer birer yeterli. Birçok kişi her vakit namazıyla bir kaza kılar.',
    'Достаточно по одному. Многие совершают одну када с каждым намазом.',
  ],
  'qadaAddOlderTitle': ['Older missed prayers', 'Öňki galan namazlar', 'Eski kaçırılan namazlar', 'Старые пропуски'],
  'qadaAddOlderBody': [
    'Enter how many of each prayer you still owe. They are added to your current counts.',
    '?Her namazdan näçesi galandygyny giriziň. Olar häzirki sanlara goşular.',
    'Her namazdan kaç tane borcunuz olduğunu girin. Mevcut sayılara eklenir.',
    'Укажите, сколько каждого намаза осталось. Они добавятся к текущим.',
  ],
  'qadaAddCount': [
    '{count, plural, =0{Add to qada} other{Add {count} to qada}}',
    '{count, plural, =0{Kaza goş} other{Kaza {count} goş}}',
    '{count, plural, =0{Kazaya ekle} other{Kazaya {count} ekle}}',
    '{count, plural, =0{Добавить в када} other{Добавить {count} в када}}',
  ],
  'qadaEmpty': [
    'No qada recorded. If you have older missed prayers, add them here.',
    '?Kaza ýok. Öňki galan namazlaryňyz bar bolsa, şu ýere goşuň.',
    'Kaza kaydı yok. Eski kaçırılan namazlarınız varsa buraya ekleyin.',
    'Када нет. Если есть старые пропуски, добавьте их здесь.',
  ],

  // --------------------------------------------------------------- expense
  'expenseAdd': ['Add expense', 'Çykdajy goş', 'Harcama ekle', 'Новый расход'],
  'expenseAddNote': ['Add a note', 'Bellik goş', 'Not ekle', 'Добавить заметку'],
  'expenseNoteHint': ['Note', 'Bellik', 'Not', 'Заметка'],
  'catGroceries': ['Groceries', 'Azyk', 'Market', 'Продукты'],
  'catTransport': ['Transport', 'Ulag', 'Ulaşım', 'Транспорт'],
  'catFood': ['Food', 'Nahar', 'Yemek', 'Еда'],
  'catBills': ['Bills', 'Tölegler', 'Faturalar', 'Счета'],
  'catSadaqa': ['Sadaqa', 'Sadaka', 'Sadaka', 'Садака'],
  'catOther': ['Other', 'Beýleki', 'Diğer', 'Другое'],
  'expenseSave': ['Save {amount} {currency}', '{amount} {currency} ýatda sakla', '{amount} {currency} kaydet', 'Сохранить {amount} {currency}'],
  'expenseSaveSadaqa': [
    'Save {amount} {currency} as sadaqa',
    '?{amount} {currency} sadaka hökmünde sakla',
    '{amount} {currency} sadaka olarak kaydet',
    'Сохранить {amount} {currency} как садаку',
  ],
  'expenseEnterAmount': ['Enter an amount', 'Möçberi giriziň', 'Tutar girin', 'Введите сумму'],
  'expenseSaved': ['Saved', 'Saklandy', 'Kaydedildi', 'Сохранено'],
  'expenseTodayList': ['Today\'s entries', 'Şu günki ýazgylar', 'Bugünkü kayıtlar', 'Записи за сегодня'],
  'expenseDeleted': ['Expense deleted', 'Çykdajy pozuldy', 'Harcama silindi', 'Расход удалён'],

  // ----------------------------------------------------------------- tasks
  'tasksTitle': ['Tasks', 'Işler', 'Görevler', 'Задачи'],
  'tasksDoneOf': ['{done} of {total} done', '{total} işden {done} taýýar', '{total} görevden {done} tamam', 'Готово {done} из {total}'],
  'tasksAddHint': ['Add a task…', 'Iş goş…', 'Görev ekle…', 'Новая задача…'],
  'tasksAddA11y': ['Add task', 'Iş goş', 'Görev ekle', 'Добавить задачу'],
  'winBeforeFajr': ['Before Fajr', 'Ertirden öň', 'Sabahtan önce', 'До фаджра'],
  'winAfterFajr': ['After Fajr', 'Ertirden soň', 'Sabahtan sonra', 'После фаджра'],
  'winBeforeDhuhr': ['Before Dhuhr', 'Öýläden öň', 'Öğleden önce', 'До зухра'],
  'winAfterDhuhr': ['After Dhuhr', 'Öýläden soň', 'Öğleden sonra', 'После зухра'],
  'winAfterAsr': ['After Asr', 'Ikindiden soň', 'İkindiden sonra', 'После асра'],
  'winAfterMaghrib': ['After Maghrib', 'Agşamdan soň', 'Akşamdan sonra', 'После магриба'],
  'winAfterIsha': ['After Isha', 'Ýassydan soň', 'Yatsıdan sonra', 'После иши'],
  'winAnytime': ['Anytime', 'Islendik wagt', 'Herhangi bir zaman', 'В любое время'],
  'winUntil': ['until {time}', '{time}-a çenli', '{time} kadar', 'до {time}'],
  'winFrom': ['from {time}', '{time}-dan', '{time} itibaren', 'с {time}'],
  'winRange': ['{a} – {b}', '{a} – {b}', '{a} – {b}', '{a} – {b}'],
  'tasksOverdue': [
    '{count, plural, =1{1 unfinished task from earlier} other{{count} unfinished tasks from earlier}}',
    '?{count, plural, other{Öňki günlerden {count} gutarylmadyk iş}}',
    '{count, plural, other{Önceki günlerden {count} bitmemiş görev}}',
    '{count, plural, =1{{count} незавершённая задача} few{{count} незавершённые задачи} many{{count} незавершённых задач} other{{count} незавершённых задачи}}',
  ],
  'tasksMoveToday': ['Move to today', 'Şu güne geçir', 'Bugüne taşı', 'Перенести на сегодня'],
  'tasksEmpty': [
    'Nothing planned yet. Add a task to a prayer window.',
    '?Entek hiç zat meýilleşdirilmedi. Namaz wagtyna iş goşuň.',
    'Henüz plan yok. Bir namaz aralığına görev ekleyin.',
    'Пока пусто. Добавьте задачу к времени намаза.',
  ],
  'tasksDeleted': ['Task deleted', 'Iş pozuldy', 'Görev silindi', 'Задача удалена'],
  'tasksAllDone': ['All done for today', 'Şu günlük hemmesi taýýar', 'Bugünlük hepsi tamam', 'На сегодня всё'],

  // ---------------------------------------------------------------- adhkar
  'adhkarMorning': ['Morning adhkar', 'Ertirki zikirler', 'Sabah zikirleri', 'Утренние азкары'],
  'adhkarEvening': ['Evening adhkar', 'Agşamky zikirler', 'Akşam zikirleri', 'Вечерние азкары'],
  'adhkarPosOf': ['{pos} of {total}', '{pos} / {total}', '{pos} / {total}', '{pos} из {total}'],
  'adhkarRecite': ['Recite {n}×', '{n}× okaň', '{n}× okuyun', 'Читать {n}×'],
  'adhkarComplete': ['Complete', 'Tamam', 'Tamamlandı', 'Готово'],
  'adhkarOf': ['/ {n}', '/ {n}', '/ {n}', '/ {n}'],
  'adhkarNext': ['Next', 'Indiki', 'İleri', 'Далее'],
  'adhkarNextDhikr': ['Next dhikr', 'Indiki zikir', 'Sonraki zikir', 'Следующий зикр'],
  'adhkarFinish': ['Finish', 'Tamamla', 'Bitir', 'Завершить'],
  'adhkarPrev': ['Previous dhikr', 'Öňki zikir', 'Önceki zikir', 'Предыдущий зикр'],
  'adhkarTapToCount': ['Tap to count', 'Sanamak üçin basyň', 'Saymak için dokunun', 'Нажмите для счёта'],
  'adhkarSetDone': [
    'May Allah accept it from you.',
    '?Alla kabul etsin.',
    'Allah kabul etsin.',
    'Да примет Аллах.',
  ],
  'adhkarTranslationNote': [
    'Translation is approximate.',
    '?Terjime takmynan.',
    'Çeviri yaklaşıktır.',
    'Перевод приблизительный.',
  ],

  // -------------------------------------------------------------- calendar
  'calendarTitle': ['Hijri calendar', 'Hijri senenamasy', 'Hicri takvim', 'Календарь хиджры'],
  'calendarRange': ['{year} · {start} – {end}', '{year} · {start} – {end}', '{year} · {start} – {end}', '{year} · {start} – {end}'],
  'calendarWhiteDays': ['White days 13–15', 'Ak günler 13–15', 'Eyyam-ı bîd 13–15', 'Белые дни 13–15'],
  'calendarMonThu': ['Mon & Thu fasts', 'Duş we Pen oraza', 'Pzt ve Per oruçları', 'Посты Пн и Чт'],
  'calendarUpcoming': ['Upcoming', 'Ýakyn günler', 'Yaklaşanlar', 'Ближайшие'],
  'calendarMoonNote': [
    'Dates may shift by a day depending on the local moon sighting.',
    '?Seneler ýerli Aý görülişine baglylykda bir gün süýşüp biler.',
    'Tarihler yerel hilal gözlemine göre bir gün kayabilir.',
    'Даты могут сдвинуться на день в зависимости от наблюдения луны.',
  ],
  'calendarPrevMonth': ['Previous month', 'Öňki aý', 'Önceki ay', 'Предыдущий месяц'],
  'calendarNextMonth': ['Next month', 'Indiki aý', 'Sonraki ay', 'Следующий месяц'],
  'calendarEveningOf': ['evening of {date}', '{date} agşamy', '{date} akşamı', 'вечер {date}'],
  'evRajab': ['Rajab begins', 'Rejep aýy başlaýar', 'Recep ayı başlıyor', 'Начало Раджаба'],
  'evMiraj': ['Laylat al-Miʿrāj', 'Miraç gijesi', 'Miraç Kandili', 'Ночь Мирадж'],
  'evBaraah': ['Laylat al-Barāʾah', 'Beraat gijesi', 'Berat Kandili', 'Ночь Бараат'],
  'evRamadan': ['Ramadan begins', 'Remezan başlaýar', 'Ramazan başlıyor', 'Начало Рамадана'],
  'evQadr': ['Laylat al-Qadr', 'Gadyr gijesi', 'Kadir Gecesi', 'Ночь Предопределения'],
  'evEidFitr': ['Eid al-Fitr', 'Oraza baýramy', 'Ramazan Bayramı', 'Ураза-байрам'],
  'evArafah': ['Day of Arafah', 'Arafat güni', 'Arefe günü', 'День Арафа'],
  'evEidAdha': ['Eid al-Adha', 'Gurban baýramy', 'Kurban Bayramı', 'Курбан-байрам'],
  'evNewYear': ['Islamic New Year', 'Hijri täze ýyly', 'Hicri Yılbaşı', 'Исламский Новый год'],
  'evAshura': ['Ashura', 'Aşyr güni', 'Aşure Günü', 'Ашура'],
  'evMawlid': ['Mawlid', 'Mewlit', 'Mevlid Kandili', 'Мавлид'],
  'evLastTen': ['Last ten nights begin', 'Soňky on gije başlaýar', 'Son on gece başlıyor', 'Начало последних десяти ночей'],
  'fastLogTitle': ['Fast · {date}', 'Oraza · {date}', 'Oruç · {date}', 'Пост · {date}'],
  'fastFasted': ['Fasted', 'Oraza tutdum', 'Oruç tuttum', 'Постился'],
  'fastMissed': ['Missed', 'Galdy', 'Tutamadım', 'Пропущен'],
  'fastExcused': ['Excused', 'Ötünçli', 'Mazeretli', 'Освобождён'],
  'fastClear': ['Clear', 'Arassala', 'Temizle', 'Очистить'],
  'fastTypeRamadan': ['Ramadan fast', 'Remezan orazasy', 'Ramazan orucu', 'Пост Рамадана'],
  'fastTypeMonThu': ['Monday/Thursday fast', 'Duşenbe/Penşenbe orazasy', 'Pazartesi/Perşembe orucu', 'Пост в Пн/Чт'],
  'fastTypeWhiteDays': ['White day fast', 'Ak gün orazasy', 'Eyyam-ı bîd orucu', 'Пост белого дня'],
  'fastTypeOther': ['Voluntary fast', 'Nepil oraza', 'Nafile oruç', 'Добровольный пост'],

  // --------------------------------------------------------------- ramadan
  'ramadanTitle': ['Ramadan', 'Remezan', 'Ramazan', 'Рамадан'],
  'ramadanMode': ['Ramadan mode', 'Remezan tertibi', 'Ramazan modu', 'Режим Рамадана'],
  'ramadanAuto': ['Automatic', 'Awtomatik', 'Otomatik', 'Автоматически'],
  'ramadanOn': ['On', 'Açyk', 'Açık', 'Вкл'],
  'ramadanOff': ['Off', 'Ýapyk', 'Kapalı', 'Выкл'],
  'ramadanInDays': ['in {days} days', '{days} günden', '{days} gün sonra', 'через {days} дн.'],
  'ramadanDayOf': ['Day {n} of {total}', '{total} günden {n}-nji', '{total} günden {n}. gün', 'День {n} из {total}'],
  'ramadanSuhoorReminder': ['Suhoor reminder', 'Sähri ýatlatmasy', 'Sahur hatırlatması', 'Напоминание о сухуре'],
  'ramadanSuhoorBefore': ['{min} min before Fajr', 'Ertirden {min} min öň', 'Sabahtan {min} dk önce', 'За {min} мин до фаджра'],
  'ramadanIftarReminder': ['Iftar at Maghrib', 'Agşamda agyz açmak', 'Akşamda iftar', 'Ифтар в магриб'],
  'ramadanTaraweehReminder': ['Taraweeh reminder', 'Terawih ýatlatmasy', 'Teravih hatırlatması', 'Напоминание о таравихе'],
  'ramadanFasts': ['Fasts this Ramadan', 'Şu Remezandaky orazalar', 'Bu Ramazandaki oruçlar', 'Посты в этот Рамадан'],
  'ramadanTodayFast': ['Today\'s fast', 'Şu günki oraza', 'Bugünkü oruç', 'Сегодняшний пост'],
  'ramadanNotNow': [
    'Ramadan mode turns on by itself on 1 Ramaḍān.',
    '?Remezan tertibi 1 Remezanda özi açylýar.',
    'Ramazan modu 1 Ramazan\'da kendiliğinden açılır.',
    'Режим Рамадана включится сам 1 Рамадана.',
  ],

  // ----------------------------------------------------------------- tools
  'toolsTitle': ['Tools', 'Gurallar', 'Araçlar', 'Инструменты'],
  'qibla': ['Qibla', 'Kybla', 'Kıble', 'Кибла'],
  'qiblaTurn': ['Turn until the arrow points up', 'Ok ýokary görkezýänçä öwrüliň', 'Ok yukarıyı gösterene kadar dönün', 'Поворачивайтесь, пока стрелка не укажет вверх'],
  'qiblaFacing': ['You\'re facing the Qibla', 'Siz Kybla tarap', 'Kıbleye dönüksünüz', 'Вы смотрите на Киблу'],
  'qiblaCalibrate': [
    'Compass needs calibration — move your phone in a figure 8.',
    '?Kompas sazlamaly — telefony 8 şekilinde aýlaň.',
    'Pusula kalibrasyon istiyor — telefonu 8 çizerek hareket ettirin.',
    'Нужна калибровка — поводите телефоном восьмёркой.',
  ],
  'qiblaNoSensor': [
    'This device has no compass. The Qibla is {deg}° clockwise from true north.',
    '?Bu enjamda kompas ýok. Kybla demirgazykdan sagat ugruna {deg}°.',
    'Bu cihazda pusula yok. Kıble, gerçek kuzeyden saat yönünde {deg}°.',
    'На устройстве нет компаса. Кибла — {deg}° по часовой от севера.',
  ],
  'qiblaFromNorth': ['{deg}° from north', 'demirgazykdan {deg}°', 'kuzeyden {deg}°', '{deg}° от севера'],
  'qiblaDistance': ['{km} km to Makkah', 'Mekgä çenli {km} km', 'Mekke\'ye {km} km', 'До Мекки {km} км'],
  'qiblaOpen': ['Open compass', 'Kompasy aç', 'Pusulayı aç', 'Открыть компас'],
  'tasbih': ['Tasbih', 'Täsbih', 'Tesbih', 'Тасбих'],
  'tasbihOf': ['of {n}', '/ {n}', '/ {n}', 'из {n}'],
  'tasbihComplete': ['Complete · {n}', 'Tamam · {n}', 'Tamam · {n}', 'Готово · {n}'],
  'tasbihTapAgain': ['Tap to start again', 'Täzeden başlamak üçin basyň', 'Yeniden başlamak için dokunun', 'Нажмите, чтобы начать снова'],
  'tasbihCustom': ['Custom tasbih', 'Öz täsbihiňiz', 'Özel tesbih', 'Свой тасбих'],
  'tasbihPreset': ['After-prayer tasbih (33 · 33 · 34)', 'Namazdan soňky täsbih (33 · 33 · 34)', 'Namaz sonrası tesbih (33 · 33 · 34)', 'Тасбих после намаза (33 · 33 · 34)'],
  'tasbihPhrase': ['Phrase', 'Söz', 'İfade', 'Фраза'],
  'tasbihGoal': ['Goal', 'Maksat', 'Hedef', 'Цель'],
  'tasbihCount': ['Count', 'San', 'Say', 'Счёт'],
  'tasbihTapA11y': ['Count one', 'Bir sana', 'Bir say', 'Отсчитать один'],
  'toolsAdhkar': ['Adhkar', 'Zikirler', 'Zikirler', 'Азкары'],
  'toolsMorningDue': ['Morning due', 'Ertirki wagty', 'Sabah vakti', 'Пора утренних'],
  'toolsEveningDue': ['Evening due', 'Agşamky wagty', 'Akşam vakti', 'Пора вечерних'],
  'toolsAdhkarDone': ['Done today', 'Şu gün taýýar', 'Bugün tamam', 'Сегодня готово'],
  'toolsCalendar': ['Hijri calendar', 'Hijri senenamasy', 'Hicri takvim', 'Календарь хиджры'],
  'toolsRamadan': ['Ramadan', 'Remezan', 'Ramazan', 'Рамадан'],
  'toolsRamadanNow': ['Day {n}', '{n}-nji gün', '{n}. gün', 'День {n}'],

  // -------------------------------------------------------------------- me
  'meTitle': ['Me', 'Men', 'Ben', 'Я'],
  'meAll5': ['All 5 prayers', 'Bäş wagt namaz', '5 vakit namaz', 'Все 5 намазов'],
  'meDaysInRow': [
    '{n, plural, =1{day in a row} other{days in a row}}',
    '{n, plural, other{gün yzygiderli}}',
    '{n, plural, other{gün üst üste}}',
    '{n, plural, =1{день подряд} few{дня подряд} many{дней подряд} other{дня подряд}}',
  ],
  'me2WeeksAgo': ['2 weeks ago', '2 hepde öň', '2 hafta önce', '2 недели назад'],
  'meBest': ['Best: {n} days', 'Iň gowy: {n} gün', 'En iyi: {n} gün', 'Рекорд: {n} дн.'],
  'meOnTime': ['On time', 'Wagtynda', 'Vaktinde', 'Вовремя'],
  'meThisMonth': ['this month', 'şu aý', 'bu ay', 'в этом месяце'],
  'meAdhkarStreak': ['Adhkar streak', 'Zikir yzygiderligi', 'Zikir serisi', 'Серия азкаров'],
  'meDays': ['days', 'gün', 'gün', 'дн.'],
  'meMorningEvening': ['morning & evening', 'ertir we agşam', 'sabah ve akşam', 'утро и вечер'],
  'meConsistency': ['Consistency', 'Yzygiderlik', 'İstikrar', 'Постоянство'],
  'meFasts': ['Fasts this month', 'Şu aýdaky orazalar', 'Bu ayki oruçlar', 'Посты в этом месяце'],
  'meFastsNone': ['None logged yet', 'Entek bellenmedi', 'Henüz kayıt yok', 'Пока не отмечено'],
  'meFastMonThu': ['{n} Mon/Thu', '{n} Duş/Pen', '{n} Pzt/Per', '{n} Пн/Чт'],
  'meFastWhite': ['{n} white days', '{n} ak gün', '{n} eyyam-ı bîd', '{n} белых дн.'],
  'meFastRamadan': ['{n} Ramadan', '{n} Remezan', '{n} Ramazan', '{n} Рамадан'],
  'meFastOther': ['{n} voluntary', '{n} nepil', '{n} nafile', '{n} добровольных'],
  'meSadaqa': ['Sadaqa', 'Sadaka', 'Sadaka', 'Садака'],
  'meSpending': ['Spending', 'Çykdajylar', 'Harcamalar', 'Расходы'],
  'meNoSpending': ['No expenses this month yet.', 'Şu aý entek çykdajy ýok.', 'Bu ay henüz harcama yok.', 'В этом месяце расходов пока нет.'],
  'meNoPrayerData': [
    'Mark your prayers on Today to see your consistency here.',
    '?Yzygiderligi görmek üçin namazlaryňyzy «Şu gün» sahypasynda belläň.',
    'İstikrarınızı görmek için namazlarınızı Bugün sekmesinde işaretleyin.',
    'Отмечайте намазы на вкладке «Сегодня», чтобы видеть статистику.',
  ],
  'meSettingsA11y': ['Settings', 'Sazlamalar', 'Ayarlar', 'Настройки'],
  'tipFajrTitle': ['Fajr is the quietest.', '?Ertir iň köp galýan namaz.', 'Sabah en sessiz olanı.', 'Фаджр — самый тихий.'],
  'tipFajrBody': [
    'An alarm ten minutes before adhan, with water by the bed, helps many people.',
    '?Azandan on minut öň budilnik we ýanyňyzda suw köplere kömek edýär.',
    'Ezandan on dakika önce bir alarm ve yatağın yanında su, birçok kişiye yardımcı olur.',
    'Будильник за десять минут до азана и вода у кровати помогают многим.',
  ],
  'tipDhuhrTitle': ['Dhuhr slips at work.', '?Öýle işde ýatdan çykýar.', 'Öğle iş arasında kaçıyor.', 'Зухр теряется на работе.'],
  'tipDhuhrBody': [
    'Block ten minutes in your calendar right after the adhan.',
    '?Azandan soň on minuty senenamaňyzda belläň.',
    'Ezandan hemen sonra takviminizde on dakika ayırın.',
    'Забронируйте десять минут в календаре сразу после азана.',
  ],
  'tipAsrTitle': ['Asr is easy to miss.', '?Ikindi aňsat galýar.', 'İkindi kolay kaçıyor.', 'Аср легко пропустить.'],
  'tipAsrBody': [
    'Pray as soon as you hear it, before the afternoon errands.',
    '?Eşiden badyňyza, öýlänki işlerden öň okaň.',
    'Duyar duymaz, öğleden sonraki işlerden önce kılın.',
    'Молитесь сразу, до дневных дел.',
  ],
  'tipMaghribTitle': ['Maghrib\'s window is short.', '?Agşamyň wagty gysga.', 'Akşamın vakti kısa.', 'Время магриба короткое.'],
  'tipMaghribBody': [
    'Pray first, then set the table.',
    '?Ilki namaz, soň saçak.',
    'Önce namaz, sonra sofra.',
    'Сначала намаз, потом стол.',
  ],
  'tipIshaTitle': ['Isha drifts late.', '?Ýassy gijä süýşýär.', 'Yatsı geç kalıyor.', 'Иша уходит на поздний час.'],
  'tipIshaBody': [
    'Pray it before tea and screens, then rest.',
    '?Çaýdan we ekrandan öň okaň, soň dynç alyň.',
    'Çaydan ve ekranlardan önce kılın, sonra dinlenin.',
    'Совершите его до чая и экранов, потом отдыхайте.',
  ],

  // -------------------------------------------------------------- settings
  'settingsTitle': ['Settings', 'Sazlamalar', 'Ayarlar', 'Настройки'],
  'secPrayerTimes': ['Prayer times', 'Namaz wagtlary', 'Namaz vakitleri', 'Время намаза'],
  'calcMethod': ['Calculation method', 'Hasaplama usuly', 'Hesaplama yöntemi', 'Метод расчёта'],
  'asr': ['Asr', 'Ikindi', 'İkindi', 'Аср'],
  'asrStandard': ['Standard', 'Standart', 'Standart', 'Стандарт'],
  'asrHanafi': ['Hanafi', 'Hanafy', 'Hanefi', 'Ханафи'],
  'matchMosque': ['Match my mosque', 'Metjidime laýyklaşdyr', 'Camime göre ayarla', 'Как в моей мечети'],
  'matchMosqueSub': ['Shift all times to its timetable', 'Ähli wagtlary onuň tertibine süýşür', 'Tüm vakitleri onun takvimine kaydır', 'Сдвинуть время по её расписанию'],
  'perPrayerOffsets': ['Adjust each prayer', 'Her namazy sazla', 'Her namazı ayarla', 'Настроить каждый намаз'],
  'offsetMinutes': ['{value} min', '{value} min', '{value} dk', '{value} мин'],
  'secAlerts': ['Alerts', 'Duýduryşlar', 'Bildirimler', 'Уведомления'],
  'alertAdhan': ['Adhan', 'Azan', 'Ezan', 'Азан'],
  'alertSilent': ['Silent', 'Sessiz', 'Sessiz', 'Тихо'],
  'alertOff': ['Off', 'Öçük', 'Kapalı', 'Выкл'],
  'secGeneral': ['General', 'Umumy', 'Genel', 'Общие'],
  'language': ['Language', 'Dil', 'Dil', 'Язык'],
  'languageSystem': ['System', 'Ulgam', 'Sistem', 'Системный'],
  'currency': ['Currency', 'Pul birligi', 'Para birimi', 'Валюта'],
  'location': ['Location', 'Ýerleşýän ýeri', 'Konum', 'Местоположение'],
  'periodMode': ['Period mode', 'Aýbaşy tertibi', 'Özel gün modu', 'Особые дни'],
  'periodModeSub': ['Pauses prayer alerts. Streaks stay intact.', '?Namaz duýduryşlaryny togtadýar. Yzygiderlik saklanýar.', 'Namaz bildirimlerini durdurur. Seriler korunur.', 'Приостанавливает уведомления. Серии сохраняются.'],
  'appearance': ['Appearance', 'Görnüş', 'Görünüm', 'Оформление'],
  'themeLight': ['Light', 'Ýagty', 'Açık', 'Светлая'],
  'themeDark': ['Dark', 'Garaňky', 'Koyu', 'Тёмная'],
  'themeAuto': ['Auto', 'Awto', 'Otomatik', 'Авто'],
  'widgets': ['Widgets', 'Widžetler', 'Widget\'lar', 'Виджеты'],
  'privacyNote': [
    'No account, no ads. Everything stays on this phone.',
    '?Hasap ýok, mahabat ýok. Hemme zat şu telefonda galýar.',
    'Hesap yok, reklam yok. Her şey bu telefonda kalır.',
    'Без аккаунта и рекламы. Всё остаётся на этом телефоне.',
  ],
  'versionLabel': ['Waqt {version}', 'Waqt {version}', 'Waqt {version}', 'Waqt {version}'],
  'hijriAdjust': ['Hijri date', 'Hijri senesi', 'Hicri tarih', 'Дата хиджры'],
  'hijriAdjustSub': ['Match your local moon sighting', 'Ýerli Aý görlüşine laýyklaşdyr', 'Yerel hilal gözlemine uydur', 'По местному наблюдению луны'],
  'hijriAdjustNone': ['No adjustment', 'Düzediş ýok', 'Düzeltme yok', 'Без поправки'],
  'adhkarReminders': ['Adhkar reminders', 'Zikir ýatlatmalary', 'Zikir hatırlatmaları', 'Напоминания об азкарах'],
  'adhkarRemindersSub': ['Morning after Fajr, evening after Asr', 'Ertir namazdan soň, agşam ikindiden soň', 'Sabah namazdan sonra, akşam ikindiden sonra', 'Утром после фаджра, вечером после асра'],
  'secRamadan': ['Ramadan', 'Remezan', 'Ramazan', 'Рамадан'],
  'secNotifications': ['Notifications', 'Bildirişler', 'Bildirimler', 'Уведомления'],
  'notifPermissionOff': [
    'Notifications are off for Waqt. Turn them on in system settings.',
    '?Waqt üçin bildirişler öçük. Ulgam sazlamalarynda açyň.',
    'Waqt için bildirimler kapalı. Sistem ayarlarından açın.',
    'Уведомления для Waqt выключены. Включите их в настройках системы.',
  ],
  'exactAlarmOff': [
    'Exact alarms are off, so alerts may arrive a few minutes late.',
    '?Takyk duýduryşlar öçük, şonuň üçin duýduryşlar birnäçe minut gijä galyp biler.',
    'Tam zamanlı alarmlar kapalı; bildirimler birkaç dakika gecikebilir.',
    'Точные будильники отключены — уведомления могут опаздывать.',
  ],
  'allowExact': ['Allow exact alarms', 'Takyk duýduryşlara rugsat ber', 'Tam zamanlı alarmlara izin ver', 'Разрешить точные будильники'],
  'methodMwl': ['Muslim World League', 'Musulman Dünýä Ligasy', 'Müslüman Dünya Birliği', 'Всемирная исламская лига'],
  'methodEgyptian': ['Egyptian General Authority', 'Müsür umumy edarasy', 'Mısır Genel Kurumu', 'Египетское управление'],
  'methodKarachi': ['University of Islamic Sciences, Karachi', 'Karaçi Yslam ylymlary uniwersiteti', 'Karaçi İslami İlimler Üniversitesi', 'Университет исламских наук, Карачи'],
  'methodUmmAlQura': ['Umm al-Qura, Makkah', 'Umm al-Kura, Mekge', 'Ümmü\'l-Kura, Mekke', 'Умм аль-Кура, Мекка'],
  'methodDubai': ['Dubai', 'Dubaý', 'Dubai', 'Дубай'],
  'methodMoonSighting': ['Moonsighting Committee', 'Aý görüş komiteti', 'Hilal Gözlem Komitesi', 'Комитет наблюдения луны'],
  'methodNorthAmerica': ['ISNA (North America)', 'ISNA (Demirgazyk Amerika)', 'ISNA (Kuzey Amerika)', 'ISNA (Северная Америка)'],
  'methodKuwait': ['Kuwait', 'Kuweýt', 'Kuveyt', 'Кувейт'],
  'methodQatar': ['Qatar', 'Katar', 'Katar', 'Катар'],
  'methodSingapore': ['Singapore', 'Singapur', 'Singapur', 'Сингапур'],
  'methodTurkey': ['Diyanet (Turkey)', 'Diýanet (Türkiýe)', 'Diyanet (Türkiye)', 'Диянет (Турция)'],
  'methodTehran': ['Tehran', 'Tähran', 'Tahran', 'Тегеран'],
  'widgetsHelpTitle': ['Home-screen widgets', 'Baş ekran widžetleri', 'Ana ekran widget\'ları', 'Виджеты на главном экране'],
  'widgetsHelpIos': [
    'Touch and hold an empty area of the Home Screen, tap +, search for Waqt and choose the small, medium or lock-screen widget.',
    '?Baş ekranyň boş ýerine basyp saklaň, + basyň, Waqt gözläň we kiçi, orta ýa-da gulp ekrany widžetini saýlaň.',
    'Ana ekranda boş bir alana basılı tutun, + simgesine dokunun, Waqt\'ı arayın ve küçük, orta ya da kilit ekranı widget\'ını seçin.',
    'Нажмите и удерживайте пустое место на экране «Домой», нажмите +, найдите Waqt и выберите малый, средний виджет или виджет экрана блокировки.',
  ],
  'widgetsHelpAndroid': [
    'Touch and hold an empty area of the home screen, tap Widgets, find Waqt and drag the widget onto the screen. Its button marks the current prayer.',
    '?Baş ekranyň boş ýerine basyp saklaň, Widžetler basyň, Waqt tapyň we widžeti ekrana süýräň. Onuň düwmesi häzirki namazy belleýär.',
    'Ana ekranda boş bir alana basılı tutun, Widget\'lar\'a dokunun, Waqt\'ı bulun ve widget\'ı ekrana sürükleyin. Düğmesi mevcut namazı işaretler.',
    'Нажмите и удерживайте пустое место, выберите «Виджеты», найдите Waqt и перетащите виджет. Его кнопка отмечает текущий намаз.',
  ],
  'widgetsHelpData': [
    'Widgets show the next seven days of times even if you don\'t open the app.',
    '?Widžetler programmany açmasaňyz hem indiki ýedi günüň wagtlaryny görkezýär.',
    'Widget\'lar uygulamayı açmasanız da sonraki yedi günün vakitlerini gösterir.',
    'Виджеты показывают время на семь дней вперёд, даже если приложение не открыто.',
  ],

  // ------------------------------------------------------------- location
  'locationTitle': ['Location', 'Ýerleşýän ýeri', 'Konum', 'Местоположение'],
  'locationUseCurrent': ['Use my location', 'Meniň ýerimi ulan', 'Konumumu kullan', 'Моё местоположение'],
  'locationSearch': ['Search a city', 'Şäher gözle', 'Şehir ara', 'Найти город'],
  'locationCoordinates': ['Enter coordinates', 'Koordinatlary girizmek', 'Koordinat gir', 'Ввести координаты'],
  'locationLatitude': ['Latitude', 'Giňlik', 'Enlem', 'Широта'],
  'locationLongitude': ['Longitude', 'Uzaklyk', 'Boylam', 'Долгота'],
  'locationName': ['Place name', 'Ýeriň ady', 'Yer adı', 'Название места'],
  'locationLocating': ['Finding you…', 'Ýeriňiz kesgitlenýär…', 'Konumunuz bulunuyor…', 'Определяем местоположение…'],
  'locationDenied': [
    'Location permission was denied. Choose a city instead.',
    '?Ýer rugsady berilmedi. Ýerine şäher saýlaň.',
    'Konum izni verilmedi. Bunun yerine bir şehir seçin.',
    'Доступ к геолокации запрещён. Выберите город.',
  ],
  'locationFailed': [
    'Couldn\'t get your location. Choose a city instead.',
    '?Ýeriňizi kesgitläp bolmady. Şäher saýlaň.',
    'Konumunuz alınamadı. Bir şehir seçin.',
    'Не удалось определить местоположение. Выберите город.',
  ],
  'locationNearby': ['Near {city}', '{city} golaýynda', '{city} yakınında', 'Рядом с {city}'],
  'locationInvalid': ['Enter a valid latitude and longitude.', 'Dogry giňlik we uzaklyk giriziň.', 'Geçerli enlem ve boylam girin.', 'Введите корректные широту и долготу.'],
  'locationPrivacy': [
    'Your location is used only to calculate prayer times and the Qibla. It never leaves this phone.',
    '?Ýeriňiz diňe namaz wagtlaryny we Kyblany hasaplamak üçin ulanylýar. Ol bu telefondan çykmaýar.',
    'Konumunuz yalnızca namaz vakitlerini ve kıbleyi hesaplamak için kullanılır. Bu telefondan asla çıkmaz.',
    'Местоположение используется только для расчёта времени намаза и Киблы и не покидает телефон.',
  ],

  // ------------------------------------------------------------ onboarding
  'obGreeting': ['As-salāmu ʿalaykum', 'Essalawmaleýkim', 'Esselâmü aleyküm', 'Ассаляму алейкум'],
  'obLanguageTitle': ['Choose your language', 'Diliňizi saýlaň', 'Dilinizi seçin', 'Выберите язык'],
  'obLanguageSub': ['You can change it later in Settings.', 'Soňra Sazlamalarda üýtgedip bilersiňiz.', 'Daha sonra Ayarlar\'dan değiştirebilirsiniz.', 'Позже можно изменить в настройках.'],
  'obLocationTitle': ['Where do you pray?', 'Siz nirede namaz okaýarsyňyz?', 'Nerede namaz kılıyorsunuz?', 'Где вы молитесь?'],
  'obMethodLine': ['{method} · {madhab} Asr', '{method} · {madhab} ikindi', '{method} · {madhab} ikindi', '{method} · аср {madhab}'],
  'obAdvanced': ['Advanced', 'Giňişleýin', 'Gelişmiş', 'Дополнительно'],
  'obNotifTitle': ['Never miss a prayer', 'Namazy hiç wagt sypdyrmaň', 'Hiçbir namazı kaçırmayın', 'Не пропускайте намаз'],
  'obNotifBody': [
    'Get a gentle alert at each prayer time. Choose adhan, silent or off for each prayer later.',
    '?Her namaz wagtynda ýumşak duýduryş alyň. Soňra her namaz üçin azan, sessiz ýa-da öçük saýlaň.',
    'Her namaz vaktinde nazik bir bildirim alın. Daha sonra her namaz için ezan, sessiz veya kapalı seçin.',
    'Получайте мягкое уведомление в каждый намаз. Позже выберите азан, тихо или выкл.',
  ],
  'obAllowNotif': ['Allow notifications', 'Bildirişlere rugsat ber', 'Bildirimlere izin ver', 'Разрешить уведомления'],
  'obNotifAllowed': ['Notifications are on', 'Bildirişler açyk', 'Bildirimler açık', 'Уведомления включены'],
  'obBatteryTitle': ['Keep alerts on time', 'Duýduryşlar wagtynda bolsun', 'Bildirimler zamanında gelsin', 'Чтобы уведомления приходили вовремя'],
  'obBatteryBody': [
    'Some Android phones pause apps to save battery. Set Waqt to "Unrestricted" in battery settings so the adhan is never late.',
    '?Käbir Android telefonlar batareýany tygşytlamak üçin programmalary saklaýar. Azan gijä galmazlygy üçin Waqt-y batareýa sazlamalarynda «Çäklendirilmedik» ediň.',
    'Bazı Android telefonlar pil tasarrufu için uygulamaları durdurur. Ezanın gecikmemesi için pil ayarlarında Waqt\'ı "Kısıtlamasız" yapın.',
    'Некоторые Android-телефоны ограничивают приложения ради экономии батареи. Установите для Waqt режим «Без ограничений», чтобы азан не опаздывал.',
  ],
  'obOpenBattery': ['Open battery settings', 'Batareýa sazlamalaryny aç', 'Pil ayarlarını aç', 'Открыть настройки батареи'],
  'obStart': ['Start', 'Başla', 'Başla', 'Начать'],
  'obPrivacy': [
    'No account. No ads. Everything stays on this phone.',
    '?Hasap ýok. Mahabat ýok. Hemme zat şu telefonda.',
    'Hesap yok. Reklam yok. Her şey bu telefonda kalır.',
    'Без аккаунта. Без рекламы. Всё остаётся на телефоне.',
  ],

  // --------------------------------------------------------- notifications
  'notifPrayerTitle': ['{prayer} · {time}', '{prayer} · {time}', '{prayer} · {time}', '{prayer} · {time}'],
  'notifPrayerBody': ['It\'s time for {prayer} in {place}.', '?{place}: {prayer} namazynyň wagty geldi.', '{place}: {prayer} vakti girdi.', '{place}: время намаза {prayer}.'],
  'notifRemindTitle': ['Reminder · {prayer}', 'Ýatlatma · {prayer}', 'Hatırlatma · {prayer}', 'Напоминание · {prayer}'],
  'notifRemindBody': ['You asked to be reminded to pray {prayer}.', '?{prayer} namazyny ýatlatmagy haýyş etdiňiz.', '{prayer} namazını hatırlatmamı istediniz.', 'Вы просили напомнить о намазе {prayer}.'],
  'notifMorningBody': ['A few minutes of remembrance to start the day.', '?Güne birnäçe minutlyk zikir bilen başlaň.', 'Güne birkaç dakikalık zikirle başlayın.', 'Несколько минут зикра в начале дня.'],
  'notifEveningBody': ['A few minutes of remembrance before evening.', '?Agşamdan öň birnäçe minutlyk zikir.', 'Akşamdan önce birkaç dakikalık zikir.', 'Несколько минут зикра перед вечером.'],
  'notifSuhoorTitle': ['Suhoor ends at {time}', 'Sähri {time}-da gutarýar', 'Sahur {time} bitiyor', 'Сухур до {time}'],
  'notifSuhoorBody': ['{min} minutes until Fajr.', 'Ertire {min} minut galdy.', 'Sabaha {min} dakika kaldı.', 'До фаджра {min} мин.'],
  'notifIftarTitle': ['Iftar time', 'Agyz açmak wagty', 'İftar vakti', 'Время ифтара'],
  'notifIftarBody': ['Maghrib has come in {place}. May Allah accept your fast.', '?{place}: agşam girdi. Alla orazaňyzy kabul etsin.', '{place}: akşam vakti girdi. Allah orucunuzu kabul etsin.', '{place}: наступил магриб. Да примет Аллах ваш пост.'],
  'chanAdhan': ['Prayer times · adhan', 'Namaz wagtlary · azan', 'Namaz vakitleri · ezan', 'Время намаза · азан'],
  'chanStandard': ['Prayer times · standard sound', 'Namaz wagtlary · adaty ses', 'Namaz vakitleri · standart ses', 'Время намаза · обычный звук'],
  'chanReminders': ['Reminders', 'Ýatlatmalar', 'Hatırlatmalar', 'Напоминания'],
};

/// Descriptions for the template (context for translators).
const Map<String, String> descriptions = {
  'homeIn': 'Word before the countdown on the hero card ("in 1h 12m"). Empty if the language puts it after.',
  'homeInAfter': 'Word after the countdown for languages that put it after the number ("1 sa 12 dk sonra").',
  'qadaLeft': 'Two lines next to the huge qada number.',
  'unitH': 'Hour unit shown next to the big hero countdown.',
  'unitM': 'Minute unit shown next to the big hero countdown.',
};

void main() {
  final outDir = Directory('lib/core/l10n')..createSync(recursive: true);
  for (var i = 0; i < langs.length; i++) {
    final lang = langs[i];
    final out = <String, Object>{'@@locale': lang};
    s.forEach((key, values) {
      if (values.length != langs.length) {
        throw StateError('$key has ${values.length} translations');
      }
      var text = values[i];
      final review = text.startsWith('?');
      if (review) text = text.substring(1);
      out[key] = text;
      if (lang == 'en') {
        final meta = <String, Object>{};
        if (descriptions[key] != null) meta['description'] = descriptions[key]!;
        final placeholders = <String, Object>{};
        for (final m in intPlaceholder.allMatches(text)) {
          placeholders[m.group(1)!] = {'type': 'int'};
        }
        for (final m in selectPlaceholder.allMatches(text)) {
          placeholders[m.group(1)!] = {'type': 'String'};
        }
        // Simple {name} placeholders outside plural/select bodies.
        final stripped = _stripSelectBodies(text);
        for (final m in simplePlaceholder.allMatches(stripped)) {
          placeholders.putIfAbsent(m.group(1)!, () => {'type': 'String'});
        }
        if (placeholders.isNotEmpty) meta['placeholders'] = placeholders;
        if (meta.isNotEmpty) out['@$key'] = meta;
      } else if (review) {
        out['@$key'] = {'description': 'REVIEW'};
      }
    });
    final file = File('${outDir.path}/app_$lang.arb');
    file.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(out)}\n');
    print('wrote ${file.path} (${s.length} keys)');
  }
}

/// Removes `{x, plural, ...}` / `{x, select, ...}` blocks so only top-level
/// `{name}` placeholders remain. (No message uses a non-plural placeholder
/// inside a plural body; add it to the top level if one ever does.)
String _stripSelectBodies(String text) {
  final buf = StringBuffer();
  var depth = 0;
  var inIcu = false;
  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (ch == '{') {
      final rest = text.substring(i);
      if (depth == 0 && RegExp(r'^\{\w+, (plural|select)').hasMatch(rest)) {
        inIcu = true;
      }
      depth++;
      if (!inIcu) buf.write(ch);
    } else if (ch == '}') {
      depth--;
      if (!inIcu) buf.write(ch);
      if (depth == 0) inIcu = false;
    } else if (!inIcu) {
      buf.write(ch);
    }
  }
  return buf.toString();
}
