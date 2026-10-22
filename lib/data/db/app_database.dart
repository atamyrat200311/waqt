import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'enums.dart';
import 'tables.dart';

export 'enums.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    PrayerLogs,
    QadaCounts,
    QadaEvents,
    Expenses,
    Incomes,
    Tasks,
    AdhkarProgress,
    Fasts,
    QadaFastBalances,
    TasbihSessions,
    Bookmarks,
    QuranReads,
    HifzItems,
    Habits,
    HabitLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Bump and add a step in [migration] for every schema change.
  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_prayer_logs_date ON prayer_logs(date)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_expenses_occurred ON expenses(occurred_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_incomes_occurred ON incomes(occurred_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_tasks_date ON tasks(date)',
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v2: Quran, hadith bookmarks, memorization and habits.
        await m.createTable(bookmarks);
        await m.createTable(quranReads);
        await m.createTable(hifzItems);
        await m.createTable(habits);
        await m.createTable(habitLogs);
      }
      if (from < 3) {
        // v3: user-defined expense category saved on each expense.
        await m.addColumn(expenses, expenses.customCategory);
      }
      if (from < 4) {
        // v4: income tracking.
        await m.createTable(incomes);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_incomes_occurred ON incomes(occurred_at)',
        );
      }
      if (from < 5) {
        // v5: daily planning metadata. Defaults preserve existing tasks.
        await m.addColumn(tasks, tasks.area);
        await m.addColumn(tasks, tasks.priority);
        await m.addColumn(tasks, tasks.plannedMinute);
        await m.addColumn(tasks, tasks.note);
      }
      if (from < 6) {
        // v6: exact, manually editable balance for legacy qada fasts.
        await m.createTable(qadaFastBalances);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Shared across isolates (widget actions and background work run in their
  /// own isolates) so writes there reach the app's live queries.
  static QueryExecutor _openConnection() => driftDatabase(
    name: 'waqt',
    native: const DriftNativeOptions(shareAcrossIsolates: true),
  );
}
