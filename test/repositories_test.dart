import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/core/utils/dates.dart';
import 'package:waqt/data/db/app_database.dart';
import 'package:waqt/data/repositories/adhkar_repository.dart';
import 'package:waqt/data/repositories/expense_repository.dart';
import 'package:waqt/data/repositories/fast_repository.dart';
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
      await repo.add(amountMinor: 22000, currency: 'TMT', category: ExpenseCategory.groceries, occurredAt: day);
      await repo.add(amountMinor: 2000, currency: 'TMT', category: ExpenseCategory.sadaqa, occurredAt: day);
      await repo.add(amountMinor: 999, currency: 'TMT', category: ExpenseCategory.food, occurredAt: day.add(const Duration(days: 1)));

      final today = await repo.watchBetween(DateTime(2026, 10, 4), DateTime(2026, 10, 5)).first;
      final sum = ExpenseSummary.of(today);
      expect(sum.totalMinor, 24000);
      expect(sum.count, 2);
      expect(sum.sadaqaMinor, 2000);
    });

    test('rejects zero amounts', () {
      final repo = ExpenseRepository(db);
      expect(
        () => repo.add(amountMinor: 0, currency: 'TMT', category: ExpenseCategory.other, occurredAt: DateTime(2026)),
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
    expect((await repo.watchRange(day, day).first)[day]?.status, FastStatus.fasted);
    await repo.set(day, FastType.monThu, null);
    expect(await repo.watchRange(day, day).first, isEmpty);
  });

  group('SettingsRepository', () {
    test('round-trips every field through JSON', () async {
      final repo = SettingsRepository(MemoryStore());
      const s = AppSettings(
        calcMethod: CalcMethod.turkey,
        madhab: AsrMadhab.standard,
        offsets: {Prayer.fajr: 2, Prayer.isha: -3},
        alerts: {Prayer.dhuhr: AlertType.off},
        location: SavedLocation(latitude: 41.0, longitude: 29.0, name: 'Istanbul', timezone: 'Europe/Istanbul'),
        language: 'ru',
        currency: 'TRY',
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

    test('corrupt JSON falls back to defaults; out-of-range values are clamped', () async {
      final store = MemoryStore({'waqt.settings.v1': '{not json'});
      expect((await SettingsRepository(store).load()).onboardingDone, isFalse);
      store.data['waqt.settings.v1'] = '{"hijriAdjustment": 9, "offsets": {"fajr": 99}}';
      final s = await SettingsRepository(store).load();
      expect(s.hijriAdjustment, 2);
      expect(s.offsetFor(Prayer.fajr), 30);
    });
  });
}
