import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/data/backup/backup_service.dart';
import 'package:waqt/data/db/app_database.dart';
import 'package:waqt/data/repositories/bookmark_repository.dart';
import 'package:waqt/data/repositories/expense_repository.dart';
import 'package:waqt/data/repositories/habit_repository.dart';
import 'package:waqt/data/repositories/income_repository.dart';
import 'package:waqt/data/repositories/prayer_repository.dart';
import 'package:waqt/data/repositories/quran_repository.dart';
import 'package:waqt/data/settings/app_settings.dart';

import 'helpers/test_db.dart';

void main() {
  test('export → restore into a fresh database round-trips everything', () async {
    final a = memoryDb();
    addTearDown(a.close);
    const day = DayKey('2026-10-04');
    await PrayerRepository(a).mark(day, Prayer.fajr, PrayerStatus.onTime);
    await PrayerRepository(a).addOlder({Prayer.asr: 3});
    await ExpenseRepository(a).add(
      amountMinor: 4550,
      currency: 'TMT',
      category: ExpenseCategory.other,
      customCategory: 'Coffee',
      occurredAt: DateTime.utc(2026, 10, 4, 9),
    );
    await IncomeRepository(a).add(
      amountMinor: 150000,
      currency: 'TMT',
      category: IncomeCategory.salary,
      occurredAt: DateTime.utc(2026, 10, 4, 10),
    );
    await BookmarkRepository(a).add(BookmarkKind.ayah, '2:255', note: 'Ayat al-Kursi');
    await QuranRepository(a).markRead(day, [0, 1, 2]);
    final habit = await HabitRepository(a).add('Walk', 'dumbbell');
    await HabitRepository(a).setDone(habit, day, true);

    const settings = AppSettings(
      onboardingDone: true,
      currency: 'USD',
      expenseCategories: ['Coffee'],
      incomeCategories: ['Freelance'],
      quranLastRead: 261,
    );
    final json = await BackupService(a).export(settings);
    expect(BackupService.peekSettings(json)?.currency, 'USD');

    final b = memoryDb();
    addTearDown(b.close);
    await ExpenseRepository(b).add(
      amountMinor: 1,
      currency: 'TMT',
      category: ExpenseCategory.other,
      occurredAt: DateTime.utc(2020),
    );
    final restored = await BackupService(b).restore(json);
    expect(restored.quranLastRead, 261);
    expect(restored.expenseCategories, ['Coffee']);
    expect(restored.incomeCategories, ['Freelance']);
    expect((await b.select(b.expenses).get()).single.amountMinor, 4550);
    expect((await b.select(b.expenses).get()).single.customCategory, 'Coffee');
    expect((await b.select(b.incomes).get()).single.amountMinor, 150000);
    expect((await b.select(b.incomes).get()).single.category, IncomeCategory.salary);
    expect((await b.select(b.prayerLogs).get()).single.status, PrayerStatus.onTime);
    expect((await b.select(b.qadaCounts).get()).firstWhere((r) => r.prayer == Prayer.asr).remaining, 3);
    expect((await b.select(b.bookmarks).get()).single.note, 'Ayat al-Kursi');
    expect(await b.select(b.quranReads).get(), hasLength(3));
    expect((await b.select(b.habitLogs).get()).single.habitId, habit);
  });

  test('rejects files that are not Waqt backups', () async {
    final db = memoryDb();
    addTearDown(db.close);
    expect(BackupService.peekSettings('{"hello":1}'), isNull);
    expect(BackupService.peekSettings('nope'), isNull);
    expect(() => BackupService(db).restore('{"format":"other"}'), throwsFormatException);
  });
}
