import 'package:drift/drift.dart';

import 'enums.dart';

/// Dates are `yyyy-MM-dd` text (see DayKey). Enums are stored by name.

@DataClassName('PrayerLogRow')
class PrayerLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text().withLength(min: 10, max: 10)();
  TextColumn get prayer => textEnum<Prayer>()();
  TextColumn get status => textEnum<PrayerStatus>()();
  DateTimeColumn get markedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {date, prayer},
      ];
}

@DataClassName('QadaCountRow')
class QadaCounts extends Table {
  TextColumn get prayer => textEnum<Prayer>()();
  // ignore: recursive_getters
  IntColumn get remaining => integer().withDefault(const Constant(0)).check(remaining.isBiggerOrEqualValue(0))();

  @override
  Set<Column> get primaryKey => {prayer};
}

@DataClassName('QadaEventRow')
class QadaEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get prayer => textEnum<Prayer>()();

  /// +1 added, −1 made up (or an undo of a "missed" mark).
  IntColumn get delta => integer()();
  TextColumn get source => textEnum<QadaSource>()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('ExpenseRow')
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Minor units (1/100). Never floats.
  // ignore: recursive_getters
  IntColumn get amountMinor => integer().check(amountMinor.isBiggerThanValue(0))();
  TextColumn get currency => text().withDefault(const Constant('TMT'))();
  TextColumn get category => textEnum<ExpenseCategory>()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
}

@DataClassName('TaskRow')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 500)();
  TextColumn get date => text().withLength(min: 10, max: 10)();
  TextColumn get window => textEnum<TaskWindow>()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  DateTimeColumn get doneAt => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('AdhkarProgressRow')
class AdhkarProgress extends Table {
  TextColumn get date => text().withLength(min: 10, max: 10)();
  TextColumn get setId => textEnum<AdhkarSet>()();
  TextColumn get itemId => text()();
  IntColumn get count => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date, setId, itemId};
}

@DataClassName('FastRow')
class Fasts extends Table {
  TextColumn get date => text().withLength(min: 10, max: 10)();
  TextColumn get type => textEnum<FastType>()();
  TextColumn get status => textEnum<FastStatus>()();

  @override
  Set<Column> get primaryKey => {date};
}

@DataClassName('TasbihSessionRow')
class TasbihSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get phrase => text()();
  IntColumn get count => integer()();
  IntColumn get goal => integer()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('BookmarkRow')
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => textEnum<BookmarkKind>()();
  TextColumn get ref => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {kind, ref},
      ];
}

/// One row per ayah read on a day (global ayah index 0…6235). Drives the
/// reading streak, daily goal and khatm progress.
@DataClassName('QuranReadRow')
class QuranReads extends Table {
  TextColumn get date => text().withLength(min: 10, max: 10)();
  IntColumn get ayah => integer()();

  @override
  Set<Column> get primaryKey => {date, ayah};
}

/// Surahs on the memorization ladder.
@DataClassName('HifzRow')
class HifzItems extends Table {
  IntColumn get surah => integer()();
  TextColumn get status => textEnum<HifzStatus>()();

  /// Index into the review ladder (1-3-7-14-30-90 days).
  IntColumn get step => integer().withDefault(const Constant(0))();

  /// `yyyy-MM-dd` of the next review.
  TextColumn get nextReview => text().withLength(min: 10, max: 10)();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {surah};
}

@DataClassName('HabitRow')
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 120)();

  /// Icon key from the habit icon palette (see habits feature).
  TextColumn get icon => text().withDefault(const Constant('star'))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('HabitLogRow')
class HabitLogs extends Table {
  IntColumn get habitId => integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  TextColumn get date => text().withLength(min: 10, max: 10)();

  @override
  Set<Column> get primaryKey => {habitId, date};
}
