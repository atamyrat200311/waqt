import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'enums.dart';
import 'tables.dart';

export 'enums.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  PrayerLogs,
  QadaCounts,
  QadaEvents,
  Expenses,
  Tasks,
  AdhkarProgress,
  Fasts,
  TasbihSessions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// Bump and add a step in [migration] for every schema change.
  @override
  int get schemaVersion => 1;

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
          await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_date ON tasks(date)');
        },
        onUpgrade: (m, from, to) async {
          // v1 is the first schema. Future steps go here, e.g.
          // if (from < 2) await m.addColumn(tasks, tasks.someNewColumn);
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() => driftDatabase(name: 'waqt');
}
