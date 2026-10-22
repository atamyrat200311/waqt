import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/data/db/app_database.dart';
import 'package:waqt/data/repositories/adhkar_repository.dart';
import 'package:waqt/data/repositories/expense_repository.dart';
import 'package:waqt/data/repositories/fast_repository.dart';
import 'package:waqt/data/repositories/income_repository.dart';
import 'package:waqt/data/repositories/prayer_repository.dart';
import 'package:waqt/data/repositories/task_repository.dart';
import 'package:waqt/data/settings/app_settings.dart';
import 'package:waqt/data/settings/settings_repository.dart';

import 'helpers/test_db.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = memoryDb());
  tearDown(() => db.close());

  group('ExpenseRepository', () {
    test('stores integer minor units and summarises sadaqa', () async {
      final repo = ExpenseRepository(db);
      final day = DateTime(2026, 10, 4, 12);
      await repo.add(
        amountMinor: 22000,
        currency: 'TMT',
        category: ExpenseCategory.groceries,
        occurredAt: day,
      );
      await repo.add(
        amountMinor: 2000,
        currency: 'TMT',
        category: ExpenseCategory.sadaqa,
        occurredAt: day,
      );
      await repo.add(
        amountMinor: 999,
        currency: 'TMT',
        category: ExpenseCategory.food,
        occurredAt: day.add(const Duration(days: 1)),
      );

      final today = await repo
          .watchBetween(DateTime(2026, 10, 4), DateTime(2026, 10, 5))
          .first;
      final sum = ExpenseSummary.of(today);
      expect(sum.totalMinor, 24000);
      expect(sum.count, 2);
      expect(sum.sadaqaMinor, 2000);
    });

    test('stores and summarises a custom category', () async {
      final repo = ExpenseRepository(db);
      final day = DateTime(2026, 10, 4, 12);
      await repo.add(
        amountMinor: 3500,
        currency: 'TMT',
        category: ExpenseCategory.other,
        customCategory: 'Coffee',
        occurredAt: day,
      );

      final item =
          (await repo
                  .watchBetween(DateTime(2026, 10, 4), DateTime(2026, 10, 5))
                  .first)
              .single;
      expect(item.customCategory, 'Coffee');
      expect(item.category, ExpenseCategory.other);
      expect(ExpenseSummary.of([item]).byCustomCategory, {'Coffee': 3500});
    });

    test('rejects zero amounts', () {
      final repo = ExpenseRepository(db);
      expect(
        () => repo.add(
          amountMinor: 0,
          currency: 'TMT',
          category: ExpenseCategory.other,
          occurredAt: DateTime(2026),
        ),
        throwsArgumentError,
      );
    });
  });

  group('IncomeRepository', () {
    test('stores integer minor units and summarises sources', () async {
      final repo = IncomeRepository(db);
      final day = DateTime(2026, 10, 4, 12);
      await repo.add(
        amountMinor: 500000,
        currency: 'TMT',
        category: IncomeCategory.salary,
        occurredAt: day,
      );
      await repo.add(
        amountMinor: 50000,
        currency: 'TMT',
        category: IncomeCategory.gift,
        occurredAt: day,
      );
      await repo.add(
        amountMinor: 20000,
        currency: 'TMT',
        category: IncomeCategory.other,
        customCategory: 'Freelance',
        occurredAt: day,
      );

      final today = await repo
          .watchBetween(DateTime(2026, 10, 4), DateTime(2026, 10, 5))
          .first;
      final sum = IncomeSummary.of(today);
      expect(sum.totalMinor, 570000);
      expect(sum.count, 3);
      expect(sum.byCategory[IncomeCategory.salary], 500000);
      expect(sum.byCategory[IncomeCategory.gift], 50000);
      expect(sum.byCustomCategory['Freelance'], 20000);
    });

    test('rejects zero or negative amounts', () {
      final repo = IncomeRepository(db);
      expect(
        () => repo.add(
          amountMinor: 0,
          currency: 'TMT',
          category: IncomeCategory.salary,
          occurredAt: DateTime(2026),
        ),
        throwsArgumentError,
      );
      expect(
        () => repo.add(
          amountMinor: -100,
          currency: 'TMT',
          category: IncomeCategory.salary,
          occurredAt: DateTime(2026),
        ),
        throwsArgumentError,
      );
    });
  });

  group('TaskRepository', () {
    test('overdue tasks can be moved to today keeping their window', () async {
      final repo = TaskRepository(db);
      const yesterday = DayKey('2026-10-03');
      const today = DayKey('2026-10-04');
      final a = await repo.add('Pay bill', yesterday, TaskWindow.beforeDhuhr);
      final b = await repo.add('Done already', yesterday, TaskWindow.afterAsr);
      await repo.setDone(b, true);

      final overdue = await repo.watchOverdue(today).first;
      expect(overdue.map((t) => t.id), [a]);

      await repo.moveTo([a], today);
      final todays = await repo.watchDay(today).first;
      expect(todays.single.window, TaskWindow.beforeDhuhr);
      expect(await repo.watchOverdue(today).first, isEmpty);
    });

    test('sort order increments within a window', () async {
      final repo = TaskRepository(db);
      const day = DayKey('2026-10-04');
      await repo.add('one', day, TaskWindow.afterAsr);
      await repo.add('two', day, TaskWindow.afterAsr);
      final tasks = await repo.watchDay(day).first;
      expect(tasks.map((t) => t.sortOrder), [0, 1]);
    });

    test('planning metadata is saved and can be edited', () async {
      final repo = TaskRepository(db);
      const day = DayKey('2026-10-04');
      final id = await repo.add(
        'Read Quran',
        day,
        TaskWindow.afterFajr,
        area: TaskArea.akhirah,
        priority: TaskPriority.high,
        plannedMinute: 6 * 60 + 30,
        note: 'Two pages',
      );

      var task = (await repo.watchDay(day).first).single;
      expect(task.area, TaskArea.akhirah);
      expect(task.priority, TaskPriority.high);
      expect(task.plannedMinute, 390);
      expect(task.note, 'Two pages');

      await repo.update(
        id,
        title: 'Call family',
        day: day,
        window: TaskWindow.afterMaghrib,
        area: TaskArea.dunya,
        priority: TaskPriority.normal,
      );
      task = (await repo.watchDay(day).first).single;
      expect(task.title, 'Call family');
      expect(task.area, TaskArea.dunya);
      expect(task.plannedMinute, isNull);
      expect(task.note, isNull);
    });
  });

  test('PrayerRepository undoes the latest make-up', () async {
    final repo = PrayerRepository(db);
    await repo.addOlder({Prayer.fajr: 2});
    await repo.makeUp(Prayer.fajr);
    expect((await repo.getQadaCounts())[Prayer.fajr], 1);
    expect(await repo.watchMadeUpTotal().first, 1);
    await repo.undoMakeUp(Prayer.fajr);
    expect((await repo.getQadaCounts())[Prayer.fajr], 2);
    expect(await repo.watchMadeUpTotal().first, 0);
  });

  test('AdhkarRepository upserts per (date, set, item)', () async {
    final repo = AdhkarRepository(db);
    const day = DayKey('2026-10-04');
    await repo.setCount(day, AdhkarSet.evening, 'e1', 1);
    await repo.setCount(day, AdhkarSet.evening, 'e1', 3);
    expect(await repo.watchDay(day, AdhkarSet.evening).first, {'e1': 3});
  });

  test('FastRepository set and clear', () async {
    final repo = FastRepository(db);
    const day = DayKey('2026-10-05');
    await repo.set(day, FastType.monThu, FastStatus.fasted);
    expect(
      (await repo.watchRange(day, day).first)[day]?.status,
      FastStatus.fasted,
    );
    await repo.set(day, FastType.monThu, null);
    expect(await repo.watchRange(day, day).first, isEmpty);
  });

  test('FastRepository qada remaining, addOlder, madeUpTotal and lastMadeUpDate', () async {
    final repo = FastRepository(db);
    expect(await repo.watchQadaRemaining().first, 0);
    expect(await repo.watchMadeUpTotal().first, 0);
    expect(await repo.watchLastMadeUpDate().first, isNull);

    // Set remaining debt
    await repo.setQadaRemaining(10);
    expect(await repo.watchQadaRemaining().first, 10);

    // Add older missed fasts
    await repo.addOlder(5);
    expect(await repo.watchQadaRemaining().first, 15);

    // Keep a qada fast on a day
    const day = DayKey('2026-10-18');
    await repo.set(day, FastType.qada, FastStatus.fasted);
    expect(await repo.watchQadaRemaining().first, 14);
    expect(await repo.watchMadeUpTotal().first, 1);
    expect(await repo.watchLastMadeUpDate().first, day);
  });

  group('SettingsRepository', () {
    test('round-trips every field through JSON', () async {
      final repo = SettingsRepository(MemoryStore());
      const s = AppSettings(
        calcMethod: CalcMethod.turkey,
        madhab: AsrMadhab.standard,
        offsets: {Prayer.fajr: 2, Prayer.isha: -3},
        alerts: {Prayer.dhuhr: AlertType.off},
        location: SavedLocation(
          latitude: 41.0,
          longitude: 29.0,
          name: 'Istanbul',
          timezone: 'Europe/Istanbul',
        ),
        language: 'ru',
        currency: 'TRY',
        expenseCategories: ['Coffee', 'School'],
        hijriAdjustment: -1,
        ramadanMode: RamadanMode.on,
        periodMode: true,
        periodSince: '2026-10-01',
        theme: AppThemeMode.dark,
        onboardingDone: true,
        adhkarReminders: true,
      );
      await repo.save(s);
      final back = await repo.load();
      expect(back.toJson(), s.toJson());
      expect(back.offsetFor(Prayer.fajr), 2);
      expect(back.alertFor(Prayer.asr), AppSettings.defaultAlert);
    });

    test('defaults: MWL + Hanafi, TMT, Ashgabat fallback', () async {
      final s = await SettingsRepository(MemoryStore()).load();
      expect(s.calcMethod, CalcMethod.muslimWorldLeague);
      expect(s.madhab, AsrMadhab.hanafi);
      expect(s.currency, 'TMT');
      expect(s.effectiveLocation.name, 'Ashgabat');
    });

    test(
      'corrupt JSON falls back to defaults; out-of-range values are clamped',
      () async {
        final store = MemoryStore({'waqt.settings.v1': '{not json'});
        expect(
          (await SettingsRepository(store).load()).onboardingDone,
          isFalse,
        );
        store.data['waqt.settings.v1'] =
            '{"hijriAdjustment": 9, "offsets": {"fajr": 99}}';
        final s = await SettingsRepository(store).load();
        expect(s.hijriAdjustment, 2);
        expect(s.offsetFor(Prayer.fajr), 30);
      },
    );
  });
}
