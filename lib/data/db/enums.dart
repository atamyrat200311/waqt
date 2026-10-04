/// Domain enums shared by the database, repositories and pure-Dart logic.
/// Stored in SQLite by `name` (text), so renaming a value is a migration.
library;

enum Prayer {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha;

  static Prayer? tryParse(String? s) {
    for (final p in values) {
      if (p.name == s) return p;
    }
    return null;
  }
}

enum PrayerStatus {
  onTime,
  congregation,
  late,
  missed,
  excused;

  /// The prayer was performed (in any form).
  bool get isPrayed => this == onTime || this == congregation || this == late;

  /// Prayed within its window.
  bool get isOnTime => this == onTime || this == congregation;
}

enum QadaSource { missedMarked, manualAdd, madeUp }

enum ExpenseCategory { groceries, transport, food, bills, sadaqa, other }

/// Task windows in display order.
enum TaskWindow {
  beforeFajr,
  afterFajr,
  beforeDhuhr,
  afterDhuhr,
  afterAsr,
  afterMaghrib,
  afterIsha,
  anytime,
}

enum AdhkarSet { morning, evening }

enum FastType { ramadan, monThu, whiteDays, other }

enum FastStatus { fasted, missed, excused }

/// Notification style per prayer. See CLAUDE.md conflict #2 for "silent".
enum AlertType { adhan, silent, off }

enum RamadanMode { auto, on, off }

enum AppThemeMode { system, light, dark }

enum AsrMadhab { standard, hanafi }

/// Mirrors adhan's CalculationMethod, minus `other`.
enum CalcMethod {
  muslimWorldLeague,
  egyptian,
  karachi,
  ummAlQura,
  dubai,
  moonSightingCommittee,
  northAmerica,
  kuwait,
  qatar,
  singapore,
  turkey,
  tehran,
}

T enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null) return fallback;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}
