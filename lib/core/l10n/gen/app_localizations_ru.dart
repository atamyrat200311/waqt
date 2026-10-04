// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Waqt';

  @override
  String get tabToday => 'Сегодня';

  @override
  String get tabTools => 'Инструменты';

  @override
  String get tabMe => 'Я';

  @override
  String get add => 'Добавить';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get done => 'Готово';

  @override
  String get close => 'Закрыть';

  @override
  String get back => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get skip => 'Пропустить';

  @override
  String get continueLabel => 'Продолжить';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get edit => 'Изменить';

  @override
  String get delete => 'Удалить';

  @override
  String get undo => 'Отменить';

  @override
  String get reset => 'Сброс';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get pickDate => 'Выбрать дату';

  @override
  String listAnd(String a, String b) {
    return '$a и $b';
  }

  @override
  String get errorGeneric => 'Что-то пошло не так.';

  @override
  String get tryAgain => 'Повторить';

  @override
  String get prayerFajr => 'Фаджр';

  @override
  String get prayerSunrise => 'Восход';

  @override
  String get prayerDhuhr => 'Зухр';

  @override
  String get prayerAsr => 'Аср';

  @override
  String get prayerMaghrib => 'Магриб';

  @override
  String get prayerIsha => 'Иша';

  @override
  String weekdayName(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'понедельник',
      'tue': 'вторник',
      'wed': 'среда',
      'thu': 'четверг',
      'fri': 'пятница',
      'sat': 'суббота',
      'other': 'воскресенье',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Пн',
      'tue': 'Вт',
      'wed': 'Ср',
      'thu': 'Чт',
      'fri': 'Пт',
      'sat': 'Сб',
      'other': 'Вс',
    });
    return '$_temp0';
  }

  @override
  String weekdayInitial(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'П',
      'tue': 'В',
      'wed': 'С',
      'thu': 'Ч',
      'fri': 'П',
      'sat': 'С',
      'other': 'В',
    });
    return '$_temp0';
  }

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'января',
      'feb': 'февраля',
      'mar': 'марта',
      'apr': 'апреля',
      'may': 'мая',
      'jun': 'июня',
      'jul': 'июля',
      'aug': 'августа',
      'sep': 'сентября',
      'oct': 'октября',
      'nov': 'ноября',
      'other': 'декабря',
    });
    return '$_temp0';
  }

  @override
  String monthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'янв',
      'feb': 'фев',
      'mar': 'мар',
      'apr': 'апр',
      'may': 'мая',
      'jun': 'июн',
      'jul': 'июл',
      'aug': 'авг',
      'sep': 'сен',
      'oct': 'окт',
      'nov': 'ноя',
      'other': 'дек',
    });
    return '$_temp0';
  }

  @override
  String monthStandalone(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'Январь',
      'feb': 'Февраль',
      'mar': 'Март',
      'apr': 'Апрель',
      'may': 'Май',
      'jun': 'Июнь',
      'jul': 'Июль',
      'aug': 'Август',
      'sep': 'Сентябрь',
      'oct': 'Октябрь',
      'nov': 'Ноябрь',
      'other': 'Декабрь',
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
    return '$weekday, $day $month';
  }

  @override
  String hijriMonth(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Мухаррам',
      'm2': 'Сафар',
      'm3': 'Раби аль-авваль',
      'm4': 'Раби ас-сани',
      'm5': 'Джумада аль-уля',
      'm6': 'Джумада ас-сани',
      'm7': 'Раджаб',
      'm8': 'Шаабан',
      'm9': 'Рамадан',
      'm10': 'Шавваль',
      'm11': 'Зуль-када',
      'other': 'Зуль-хиджа',
    });
    return '$_temp0';
  }

  @override
  String hijriMonthLong(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Мухаррам',
      'm2': 'Сафар',
      'm3': 'Раби аль-авваль',
      'm4': 'Раби ас-сани',
      'm5': 'Джумада аль-уля',
      'm6': 'Джумада ас-сани',
      'm7': 'Раджаб',
      'm8': 'Шаабан',
      'm9': 'Рамадан',
      'm10': 'Шавваль',
      'm11': 'Зуль-када',
      'other': 'Зуль-хиджа',
    });
    return '$_temp0';
  }

  @override
  String hijriDate(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get unitH => 'ч';

  @override
  String get unitM => 'м';

  @override
  String get unitS => 'с';

  @override
  String durationHM(String h, String m) {
    return '$h ч $m мин';
  }

  @override
  String durationM(String m) {
    return '$m мин';
  }

  @override
  String minutesShort(String m) {
    return '$m мин';
  }

  @override
  String inDuration(String d) {
    return 'через $d';
  }

  @override
  String daysCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n дня',
      many: '$n дней',
      few: '$n дня',
      one: '$n день',
    );
    return '$_temp0';
  }

  @override
  String daysUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'дня',
      many: 'дней',
      few: 'дня',
      one: 'день',
    );
    return '$_temp0';
  }

  @override
  String eventCountdown(int days, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'через $days дня',
      many: 'через $days дней',
      few: 'через $days дня',
      one: 'завтра',
      zero: 'сегодня',
    );
    return '$name $_temp0';
  }

  @override
  String get homeNextPrayer => 'Следующий намаз';

  @override
  String get homeIn => 'через';

  @override
  String get homeInAfter => '';

  @override
  String get homeRamadanKicker => 'Рамадан · Ифтар';

  @override
  String get homeIftar => 'Ифтар';

  @override
  String homeMaghribAt(String time) {
    return 'Магриб $time';
  }

  @override
  String homeSuhoorLine(String time, String n, String total) {
    return 'Сухур до $time · Пост $n из $total';
  }

  @override
  String homeAfterIshaKicker(String time) {
    return 'После иши · $time';
  }

  @override
  String get homeYourDay => 'Ваш день';

  @override
  String get homeUpNext => 'Далее';

  @override
  String get homeStart => 'Начать';

  @override
  String get homeMarkDone => 'Готово';

  @override
  String homeAdhkarAfter(String window, String min) {
    return '$window · $min мин';
  }

  @override
  String get homeTaraweeh => 'Таравих';

  @override
  String homeTaraweehSub(String time) {
    return 'В мечети · напоминание $time';
  }

  @override
  String get homeSpentToday => 'Потрачено сегодня';

  @override
  String homeInclSadaqa(String amount) {
    return 'вкл. $amount садака';
  }

  @override
  String get homeTasks => 'Задачи';

  @override
  String homeTasksOf(String total) {
    return 'из $total';
  }

  @override
  String homeQadaRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось $count када',
      many: 'Осталось $count када',
      few: 'Осталось $count када',
      one: 'Осталась $count када',
    );
    return '$_temp0';
  }

  @override
  String get homeMakeUp => 'Восполнить';

  @override
  String homeUnmarkedTitle(String prayers) {
    return 'Вчера не отмечены: $prayers';
  }

  @override
  String get homeUnmarkedBody =>
      'Ничего не добавится в када, пока вы не решите.';

  @override
  String get homeUnmarkedAllPrayed => 'Все совершены';

  @override
  String get homeAddExpense => 'Добавить расход';

  @override
  String get homeSetLocation => 'Указать место';

  @override
  String get markClosedAtSunrise => 'закончилось с восходом';

  @override
  String markClosedAt(String time) {
    return 'закончилось в $time';
  }

  @override
  String markLeft(String d) {
    return 'осталось $d';
  }

  @override
  String markOpensAt(String time) {
    return 'начнётся в $time';
  }

  @override
  String get markOnTime => 'Совершён вовремя';

  @override
  String markOnTimeSub(String prayer) {
    return 'В пределах времени $prayer';
  }

  @override
  String get markCongregation => 'В джамаате';

  @override
  String get markCongregationSub => 'С джамаатом, вовремя';

  @override
  String get markLate => 'Совершён с опозданием';

  @override
  String get markLateSub => 'После окончания времени';

  @override
  String get markMissed => 'Пропущен, добавить в када';

  @override
  String get markMissedSub => 'Вы подтвердите перед добавлением';

  @override
  String get markExcused => 'Освобождён';

  @override
  String get markExcusedSub =>
      'Режим «особые дни» — без када, серия сохраняется';

  @override
  String markConfirmTitle(String prayer) {
    return 'Добавить 1 $prayer в када?';
  }

  @override
  String get markConfirmBody =>
      'Восполнить можно в любое время. Ничего не добавится без подтверждения.';

  @override
  String get markAddToQada => 'Добавить в када';

  @override
  String get markAdded => 'Добавлено в када. Восполните, когда сможете.';

  @override
  String get markRemind => 'Напомнить через 15 мин';

  @override
  String markReminderSet(String time) {
    return 'Напоминание на $time';
  }

  @override
  String get markClear => 'Снять отметку';

  @override
  String get markNotStarted => 'Время этого намаза ещё не наступило.';

  @override
  String get qadaTitle => 'Када';

  @override
  String get qadaLeft => 'намазов\nк восполнению';

  @override
  String qadaMadeUpSince(String count) {
    return 'С начала вы восполнили $count';
  }

  @override
  String get qadaThisWeek => 'На этой неделе';

  @override
  String qadaWeekMadeUp(String count) {
    return 'восполнено: $count';
  }

  @override
  String get qadaMadeUp => 'Восполнил';

  @override
  String get qadaAllDone => 'Всё';

  @override
  String get qadaAddOlder => 'Добавить старые пропуски';

  @override
  String get qadaTip =>
      'Достаточно по одному. Многие совершают одну када с каждым намазом.';

  @override
  String get qadaAddOlderTitle => 'Старые пропуски';

  @override
  String get qadaAddOlderBody =>
      'Укажите, сколько каждого намаза осталось. Они добавятся к текущим.';

  @override
  String qadaAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавить $count в када',
      zero: 'Добавить в када',
    );
    return '$_temp0';
  }

  @override
  String get qadaEmpty =>
      'Када нет. Если есть старые пропуски, добавьте их здесь.';

  @override
  String get expenseAdd => 'Новый расход';

  @override
  String get expenseAddNote => 'Добавить заметку';

  @override
  String get expenseNoteHint => 'Заметка';

  @override
  String get catGroceries => 'Продукты';

  @override
  String get catTransport => 'Транспорт';

  @override
  String get catFood => 'Еда';

  @override
  String get catBills => 'Счета';

  @override
  String get catSadaqa => 'Садака';

  @override
  String get catOther => 'Другое';

  @override
  String expenseSave(String amount, String currency) {
    return 'Сохранить $amount $currency';
  }

  @override
  String expenseSaveSadaqa(String amount, String currency) {
    return 'Сохранить $amount $currency как садаку';
  }

  @override
  String get expenseEnterAmount => 'Введите сумму';

  @override
  String get expenseSaved => 'Сохранено';

  @override
  String get expenseTodayList => 'Записи за сегодня';

  @override
  String get expenseDeleted => 'Расход удалён';

  @override
  String get tasksTitle => 'Задачи';

  @override
  String tasksDoneOf(String done, String total) {
    return 'Готово $done из $total';
  }

  @override
  String get tasksAddHint => 'Новая задача…';

  @override
  String get tasksAddA11y => 'Добавить задачу';

  @override
  String get winBeforeFajr => 'До фаджра';

  @override
  String get winAfterFajr => 'После фаджра';

  @override
  String get winBeforeDhuhr => 'До зухра';

  @override
  String get winAfterDhuhr => 'После зухра';

  @override
  String get winAfterAsr => 'После асра';

  @override
  String get winAfterMaghrib => 'После магриба';

  @override
  String get winAfterIsha => 'После иши';

  @override
  String get winAnytime => 'В любое время';

  @override
  String winUntil(String time) {
    return 'до $time';
  }

  @override
  String winFrom(String time) {
    return 'с $time';
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
      other: '$count незавершённых задачи',
      many: '$count незавершённых задач',
      few: '$count незавершённые задачи',
      one: '$count незавершённая задача',
    );
    return '$_temp0';
  }

  @override
  String get tasksMoveToday => 'Перенести на сегодня';

  @override
  String get tasksEmpty => 'Пока пусто. Добавьте задачу к времени намаза.';

  @override
  String get tasksDeleted => 'Задача удалена';

  @override
  String get tasksAllDone => 'На сегодня всё';

  @override
  String get adhkarMorning => 'Утренние азкары';

  @override
  String get adhkarEvening => 'Вечерние азкары';

  @override
  String adhkarPosOf(String pos, String total) {
    return '$pos из $total';
  }

  @override
  String adhkarRecite(String n) {
    return 'Читать $n×';
  }

  @override
  String get adhkarComplete => 'Готово';

  @override
  String adhkarOf(String n) {
    return '/ $n';
  }

  @override
  String get adhkarNext => 'Далее';

  @override
  String get adhkarNextDhikr => 'Следующий зикр';

  @override
  String get adhkarFinish => 'Завершить';

  @override
  String get adhkarPrev => 'Предыдущий зикр';

  @override
  String get adhkarTapToCount => 'Нажмите для счёта';

  @override
  String get adhkarSetDone => 'Да примет Аллах.';

  @override
  String get adhkarTranslationNote => 'Перевод приблизительный.';

  @override
  String get calendarTitle => 'Календарь хиджры';

  @override
  String calendarRange(String year, String start, String end) {
    return '$year · $start – $end';
  }

  @override
  String get calendarWhiteDays => 'Белые дни 13–15';

  @override
  String get calendarMonThu => 'Посты Пн и Чт';

  @override
  String get calendarUpcoming => 'Ближайшие';

  @override
  String get calendarMoonNote =>
      'Даты могут сдвинуться на день в зависимости от наблюдения луны.';

  @override
  String get calendarPrevMonth => 'Предыдущий месяц';

  @override
  String get calendarNextMonth => 'Следующий месяц';

  @override
  String calendarEveningOf(String date) {
    return 'вечер $date';
  }

  @override
  String get evRajab => 'Начало Раджаба';

  @override
  String get evMiraj => 'Ночь Мирадж';

  @override
  String get evBaraah => 'Ночь Бараат';

  @override
  String get evRamadan => 'Начало Рамадана';

  @override
  String get evQadr => 'Ночь Предопределения';

  @override
  String get evEidFitr => 'Ураза-байрам';

  @override
  String get evArafah => 'День Арафа';

  @override
  String get evEidAdha => 'Курбан-байрам';

  @override
  String get evNewYear => 'Исламский Новый год';

  @override
  String get evAshura => 'Ашура';

  @override
  String get evMawlid => 'Мавлид';

  @override
  String get evLastTen => 'Начало последних десяти ночей';

  @override
  String fastLogTitle(String date) {
    return 'Пост · $date';
  }

  @override
  String get fastFasted => 'Постился';

  @override
  String get fastMissed => 'Пропущен';

  @override
  String get fastExcused => 'Освобождён';

  @override
  String get fastClear => 'Очистить';

  @override
  String get fastTypeRamadan => 'Пост Рамадана';

  @override
  String get fastTypeMonThu => 'Пост в Пн/Чт';

  @override
  String get fastTypeWhiteDays => 'Пост белого дня';

  @override
  String get fastTypeOther => 'Добровольный пост';

  @override
  String get ramadanTitle => 'Рамадан';

  @override
  String get ramadanMode => 'Режим Рамадана';

  @override
  String get ramadanAuto => 'Автоматически';

  @override
  String get ramadanOn => 'Вкл';

  @override
  String get ramadanOff => 'Выкл';

  @override
  String ramadanInDays(String days) {
    return 'через $days дн.';
  }

  @override
  String ramadanDayOf(String n, String total) {
    return 'День $n из $total';
  }

  @override
  String get ramadanSuhoorReminder => 'Напоминание о сухуре';

  @override
  String ramadanSuhoorBefore(String min) {
    return 'За $min мин до фаджра';
  }

  @override
  String get ramadanIftarReminder => 'Ифтар в магриб';

  @override
  String get ramadanTaraweehReminder => 'Напоминание о таравихе';

  @override
  String get ramadanFasts => 'Посты в этот Рамадан';

  @override
  String get ramadanTodayFast => 'Сегодняшний пост';

  @override
  String get ramadanNotNow => 'Режим Рамадана включится сам 1 Рамадана.';

  @override
  String get toolsTitle => 'Инструменты';

  @override
  String get qibla => 'Кибла';

  @override
  String get qiblaTurn => 'Поворачивайтесь, пока стрелка не укажет вверх';

  @override
  String get qiblaFacing => 'Вы смотрите на Киблу';

  @override
  String get qiblaCalibrate =>
      'Нужна калибровка — поводите телефоном восьмёркой.';

  @override
  String qiblaNoSensor(String deg) {
    return 'На устройстве нет компаса. Кибла — $deg° по часовой от севера.';
  }

  @override
  String qiblaFromNorth(String deg) {
    return '$deg° от севера';
  }

  @override
  String qiblaDistance(String km) {
    return 'До Мекки $km км';
  }

  @override
  String get qiblaOpen => 'Открыть компас';

  @override
  String get tasbih => 'Тасбих';

  @override
  String tasbihOf(String n) {
    return 'из $n';
  }

  @override
  String tasbihComplete(String n) {
    return 'Готово · $n';
  }

  @override
  String get tasbihTapAgain => 'Нажмите, чтобы начать снова';

  @override
  String get tasbihCustom => 'Свой тасбих';

  @override
  String get tasbihPreset => 'Тасбих после намаза (33 · 33 · 34)';

  @override
  String get tasbihPhrase => 'Фраза';

  @override
  String get tasbihGoal => 'Цель';

  @override
  String get tasbihCount => 'Счёт';

  @override
  String get tasbihTapA11y => 'Отсчитать один';

  @override
  String get toolsAdhkar => 'Азкары';

  @override
  String get toolsMorningDue => 'Пора утренних';

  @override
  String get toolsEveningDue => 'Пора вечерних';

  @override
  String get toolsAdhkarDone => 'Сегодня готово';

  @override
  String get toolsCalendar => 'Календарь хиджры';

  @override
  String get toolsRamadan => 'Рамадан';

  @override
  String toolsRamadanNow(String n) {
    return 'День $n';
  }

  @override
  String get meTitle => 'Я';

  @override
  String get meAll5 => 'Все 5 намазов';

  @override
  String meDaysInRow(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'дня подряд',
      many: 'дней подряд',
      few: 'дня подряд',
      one: 'день подряд',
    );
    return '$_temp0';
  }

  @override
  String get me2WeeksAgo => '2 недели назад';

  @override
  String meBest(String n) {
    return 'Рекорд: $n дн.';
  }

  @override
  String get meOnTime => 'Вовремя';

  @override
  String get meThisMonth => 'в этом месяце';

  @override
  String get meAdhkarStreak => 'Серия азкаров';

  @override
  String get meDays => 'дн.';

  @override
  String get meMorningEvening => 'утро и вечер';

  @override
  String get meConsistency => 'Постоянство';

  @override
  String get meFasts => 'Посты в этом месяце';

  @override
  String get meFastsNone => 'Пока не отмечено';

  @override
  String meFastMonThu(String n) {
    return '$n Пн/Чт';
  }

  @override
  String meFastWhite(String n) {
    return '$n белых дн.';
  }

  @override
  String meFastRamadan(String n) {
    return '$n Рамадан';
  }

  @override
  String meFastOther(String n) {
    return '$n добровольных';
  }

  @override
  String get meSadaqa => 'Садака';

  @override
  String get meSpending => 'Расходы';

  @override
  String get meNoSpending => 'В этом месяце расходов пока нет.';

  @override
  String get meNoPrayerData =>
      'Отмечайте намазы на вкладке «Сегодня», чтобы видеть статистику.';

  @override
  String get meSettingsA11y => 'Настройки';

  @override
  String get tipFajrTitle => 'Фаджр — самый тихий.';

  @override
  String get tipFajrBody =>
      'Будильник за десять минут до азана и вода у кровати помогают многим.';

  @override
  String get tipDhuhrTitle => 'Зухр теряется на работе.';

  @override
  String get tipDhuhrBody =>
      'Забронируйте десять минут в календаре сразу после азана.';

  @override
  String get tipAsrTitle => 'Аср легко пропустить.';

  @override
  String get tipAsrBody => 'Молитесь сразу, до дневных дел.';

  @override
  String get tipMaghribTitle => 'Время магриба короткое.';

  @override
  String get tipMaghribBody => 'Сначала намаз, потом стол.';

  @override
  String get tipIshaTitle => 'Иша уходит на поздний час.';

  @override
  String get tipIshaBody => 'Совершите его до чая и экранов, потом отдыхайте.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get secPrayerTimes => 'Время намаза';

  @override
  String get calcMethod => 'Метод расчёта';

  @override
  String get asr => 'Аср';

  @override
  String get asrStandard => 'Стандарт';

  @override
  String get asrHanafi => 'Ханафи';

  @override
  String get matchMosque => 'Как в моей мечети';

  @override
  String get matchMosqueSub => 'Сдвинуть время по её расписанию';

  @override
  String get perPrayerOffsets => 'Настроить каждый намаз';

  @override
  String offsetMinutes(String value) {
    return '$value мин';
  }

  @override
  String get secAlerts => 'Уведомления';

  @override
  String get alertAdhan => 'Азан';

  @override
  String get alertSilent => 'Тихо';

  @override
  String get alertOff => 'Выкл';

  @override
  String get secGeneral => 'Общие';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Системный';

  @override
  String get currency => 'Валюта';

  @override
  String get location => 'Местоположение';

  @override
  String get periodMode => 'Особые дни';

  @override
  String get periodModeSub =>
      'Приостанавливает уведомления. Серии сохраняются.';

  @override
  String get appearance => 'Оформление';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeAuto => 'Авто';

  @override
  String get widgets => 'Виджеты';

  @override
  String get privacyNote =>
      'Без аккаунта и рекламы. Всё остаётся на этом телефоне.';

  @override
  String versionLabel(String version) {
    return 'Waqt $version';
  }

  @override
  String get hijriAdjust => 'Дата хиджры';

  @override
  String get hijriAdjustSub => 'По местному наблюдению луны';

  @override
  String get hijriAdjustNone => 'Без поправки';

  @override
  String get adhkarReminders => 'Напоминания об азкарах';

  @override
  String get adhkarRemindersSub => 'Утром после фаджра, вечером после асра';

  @override
  String get secRamadan => 'Рамадан';

  @override
  String get secNotifications => 'Уведомления';

  @override
  String get notifPermissionOff =>
      'Уведомления для Waqt выключены. Включите их в настройках системы.';

  @override
  String get exactAlarmOff =>
      'Точные будильники отключены — уведомления могут опаздывать.';

  @override
  String get allowExact => 'Разрешить точные будильники';

  @override
  String get methodMwl => 'Всемирная исламская лига';

  @override
  String get methodEgyptian => 'Египетское управление';

  @override
  String get methodKarachi => 'Университет исламских наук, Карачи';

  @override
  String get methodUmmAlQura => 'Умм аль-Кура, Мекка';

  @override
  String get methodDubai => 'Дубай';

  @override
  String get methodMoonSighting => 'Комитет наблюдения луны';

  @override
  String get methodNorthAmerica => 'ISNA (Северная Америка)';

  @override
  String get methodKuwait => 'Кувейт';

  @override
  String get methodQatar => 'Катар';

  @override
  String get methodSingapore => 'Сингапур';

  @override
  String get methodTurkey => 'Диянет (Турция)';

  @override
  String get methodTehran => 'Тегеран';

  @override
  String get widgetsHelpTitle => 'Виджеты на главном экране';

  @override
  String get widgetsHelpIos =>
      'Нажмите и удерживайте пустое место на экране «Домой», нажмите +, найдите Waqt и выберите малый, средний виджет или виджет экрана блокировки.';

  @override
  String get widgetsHelpAndroid =>
      'Нажмите и удерживайте пустое место, выберите «Виджеты», найдите Waqt и перетащите виджет. Его кнопка отмечает текущий намаз.';

  @override
  String get widgetsHelpData =>
      'Виджеты показывают время на семь дней вперёд, даже если приложение не открыто.';

  @override
  String get widgetNext => 'Далее';

  @override
  String widgetWindowOpen(String prayer) {
    return '$prayer · время наступило';
  }

  @override
  String get widgetMarkPrayed => 'Отметить как совершённый';

  @override
  String widgetMarked(String prayer) {
    return '$prayer отмечен';
  }

  @override
  String get locationTitle => 'Местоположение';

  @override
  String get locationUseCurrent => 'Моё местоположение';

  @override
  String get locationSearch => 'Найти город';

  @override
  String get locationCoordinates => 'Ввести координаты';

  @override
  String get locationLatitude => 'Широта';

  @override
  String get locationLongitude => 'Долгота';

  @override
  String get locationName => 'Название места';

  @override
  String get locationLocating => 'Определяем местоположение…';

  @override
  String get locationDenied => 'Доступ к геолокации запрещён. Выберите город.';

  @override
  String get locationFailed =>
      'Не удалось определить местоположение. Выберите город.';

  @override
  String locationNearby(String city) {
    return 'Рядом с $city';
  }

  @override
  String get locationInvalid => 'Введите корректные широту и долготу.';

  @override
  String get locationPrivacy =>
      'Местоположение используется только для расчёта времени намаза и Киблы и не покидает телефон.';

  @override
  String get obGreeting => 'Ассаляму алейкум';

  @override
  String get obLanguageTitle => 'Выберите язык';

  @override
  String get obLanguageSub => 'Позже можно изменить в настройках.';

  @override
  String get obLocationTitle => 'Где вы молитесь?';

  @override
  String obMethodLine(String method, String madhab) {
    return '$method · аср $madhab';
  }

  @override
  String get obAdvanced => 'Дополнительно';

  @override
  String get obNotifTitle => 'Не пропускайте намаз';

  @override
  String get obNotifBody =>
      'Получайте мягкое уведомление в каждый намаз. Позже выберите азан, тихо или выкл.';

  @override
  String get obAllowNotif => 'Разрешить уведомления';

  @override
  String get obNotifAllowed => 'Уведомления включены';

  @override
  String get obBatteryTitle => 'Чтобы уведомления приходили вовремя';

  @override
  String get obBatteryBody =>
      'Некоторые Android-телефоны ограничивают приложения ради экономии батареи. Установите для Waqt режим «Без ограничений», чтобы азан не опаздывал.';

  @override
  String get obOpenBattery => 'Открыть настройки батареи';

  @override
  String get obStart => 'Начать';

  @override
  String get obPrivacy =>
      'Без аккаунта. Без рекламы. Всё остаётся на телефоне.';

  @override
  String notifPrayerTitle(String prayer, String time) {
    return '$prayer · $time';
  }

  @override
  String notifPrayerBody(String prayer, String place) {
    return '$place: время намаза $prayer.';
  }

  @override
  String notifRemindTitle(String prayer) {
    return 'Напоминание · $prayer';
  }

  @override
  String notifRemindBody(String prayer) {
    return 'Вы просили напомнить о намазе $prayer.';
  }

  @override
  String get notifMorningBody => 'Несколько минут зикра в начале дня.';

  @override
  String get notifEveningBody => 'Несколько минут зикра перед вечером.';

  @override
  String notifSuhoorTitle(String time) {
    return 'Сухур до $time';
  }

  @override
  String notifSuhoorBody(String min) {
    return 'До фаджра $min мин.';
  }

  @override
  String get notifIftarTitle => 'Время ифтара';

  @override
  String notifIftarBody(String place) {
    return '$place: наступил магриб. Да примет Аллах ваш пост.';
  }

  @override
  String get chanAdhan => 'Время намаза · азан';

  @override
  String get chanStandard => 'Время намаза · обычный звук';

  @override
  String get chanReminders => 'Напоминания';
}
