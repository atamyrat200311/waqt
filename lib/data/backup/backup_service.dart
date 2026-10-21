import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../settings/app_settings.dart';

/// Whole-app backup as one JSON document: settings + every table. Nothing
/// leaves the device unless the user shares the file themselves.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  static const format = 'waqt-backup';
  static const version = 1;

  /// Tables in insert order (habit logs after habits for the foreign key).
  List<TableInfo<Table, Object?>> get _tables => [
        _db.prayerLogs,
        _db.qadaCounts,
        _db.qadaEvents,
        _db.expenses,
        _db.incomes,
        _db.tasks,
        _db.adhkarProgress,
        _db.fasts,
        _db.tasbihSessions,
        _db.bookmarks,
        _db.quranReads,
        _db.hifzItems,
        _db.habits,
        _db.habitLogs,
      ];

  Future<String> export(AppSettings settings, {DateTime? now}) async {
    final tables = <String, Object?>{};
    for (final t in _tables) {
      final rows = await _db.select(t).get();
      tables[t.actualTableName] = [for (final r in rows) (r as DataClass).toJson()];
    }
    return jsonEncode({
      'format': format,
      'version': version,
      'exportedAt': (now ?? DateTime.now()).toUtc().toIso8601String(),
      'settings': settings.toJson(),
      'tables': tables,
    });
  }

  /// Validates and returns the settings in [raw] without touching data.
  static AppSettings? peekSettings(String raw) {
    try {
      final j = jsonDecode(raw);
      if (j is! Map<String, Object?> || j['format'] != format) return null;
      final s = j['settings'];
      return s is Map<String, Object?> ? AppSettings.fromJson(s) : const AppSettings();
    } on FormatException {
      return null;
    }
  }

  /// Replaces all data with the backup (one transaction; on any error the
  /// existing data is kept). Returns the backup's settings.
  Future<AppSettings> restore(String raw) async {
    final j = jsonDecode(raw);
    if (j is! Map<String, Object?> || j['format'] != format) {
      throw const FormatException('Not a Waqt backup');
    }
    final tables = (j['tables'] as Map?)?.cast<String, Object?>() ?? const {};
    await _db.transaction(() async {
      for (final t in _tables.reversed) {
        await _db.delete(t).go();
      }
      for (final t in _tables) {
        final rows = (tables[t.actualTableName] as List?) ?? const [];
        if (rows.isEmpty) continue;
        await _db.batch((b) {
          b.insertAll(t, [
            for (final r in rows.cast<Map<String, Object?>>()) _fromJson(t, r),
          ]);
        });
      }
    });
    final s = j['settings'];
    return s is Map<String, Object?> ? AppSettings.fromJson(s) : const AppSettings();
  }

  Insertable<Object?> _fromJson(TableInfo<Table, Object?> t, Map<String, Object?> r) {
    final m = r.cast<String, dynamic>();
    return switch (t.actualTableName) {
      'prayer_logs' => PrayerLogRow.fromJson(m),
      'qada_counts' => QadaCountRow.fromJson(m),
      'qada_events' => QadaEventRow.fromJson(m),
      'expenses' => ExpenseRow.fromJson(m),
      'incomes' => IncomeRow.fromJson(m),
      'tasks' => TaskRow.fromJson(m),
      'adhkar_progress' => AdhkarProgressRow.fromJson(m),
      'fasts' => FastRow.fromJson(m),
      'tasbih_sessions' => TasbihSessionRow.fromJson(m),
      'bookmarks' => BookmarkRow.fromJson(m),
      'quran_reads' => QuranReadRow.fromJson(m),
      'hifz_items' => HifzRow.fromJson(m),
      'habits' => HabitRow.fromJson(m),
      'habit_logs' => HabitLogRow.fromJson(m),
      final n => throw FormatException('Unknown table $n'),
    } as Insertable<Object?>;
  }
}
