import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../db/database_provider.dart';

class Income {
  const Income({
    required this.id,
    required this.amountMinor,
    required this.currency,
    required this.category,
    required this.occurredAt,
    this.customCategory,
    this.note,
  });

  final int id;
  final int amountMinor;
  final String currency;
  final IncomeCategory category;
  final String? customCategory;
  final String? note;
  final DateTime occurredAt;
}

/// Totals for a period, per currency is not needed: incomes are summed in
/// the user's currency (switching currency later does not convert history).
class IncomeSummary {
  const IncomeSummary({
    required this.totalMinor,
    required this.count,
    required this.byCategory,
    required this.byCustomCategory,
  });

  final int totalMinor;
  final int count;
  final Map<IncomeCategory, int> byCategory;
  final Map<String, int> byCustomCategory;

  static IncomeSummary of(Iterable<Income> items) {
    var total = 0;
    var n = 0;
    final by = <IncomeCategory, int>{};
    final custom = <String, int>{};
    for (final e in items) {
      total += e.amountMinor;
      n++;
      if (e.customCategory case final name?) {
        custom[name] = (custom[name] ?? 0) + e.amountMinor;
      } else {
        by[e.category] = (by[e.category] ?? 0) + e.amountMinor;
      }
    }
    return IncomeSummary(totalMinor: total, count: n, byCategory: by, byCustomCategory: custom);
  }

  static const empty = IncomeSummary(totalMinor: 0, count: 0, byCategory: {}, byCustomCategory: {});
}

class IncomeRepository {
  IncomeRepository(this._db);

  final AppDatabase _db;

  Future<int> add({
    required int amountMinor,
    required String currency,
    required IncomeCategory category,
    required DateTime occurredAt,
    String? customCategory,
    String? note,
  }) {
    if (amountMinor <= 0) throw ArgumentError.value(amountMinor, 'amountMinor', 'must be > 0');
    final custom = customCategory?.trim();
    if (custom != null && (custom.isEmpty || custom.length > 30)) {
      throw ArgumentError.value(customCategory, 'customCategory', 'must be 1–30 characters');
    }
    final trimmed = note?.trim();
    return _db
        .into(_db.incomes)
        .insert(
          IncomesCompanion.insert(
            amountMinor: amountMinor,
            currency: Value(currency),
            category: custom == null ? category : IncomeCategory.other,
            customCategory: Value(custom),
            note: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
            occurredAt: occurredAt,
          ),
        );
  }

  Future<void> delete(int id) => (_db.delete(_db.incomes)..where((t) => t.id.equals(id))).go();

  /// Re-insert after an undo.
  Future<void> restore(Income i) => _db
      .into(_db.incomes)
      .insert(
        IncomesCompanion.insert(
          id: Value(i.id),
          amountMinor: i.amountMinor,
          currency: Value(i.currency),
          category: i.category,
          customCategory: Value(i.customCategory),
          note: Value(i.note),
          occurredAt: i.occurredAt,
        ),
      );

  /// Incomes with occurredAt in [from, toExclusive), newest first.
  Stream<List<Income>> watchBetween(DateTime from, DateTime toExclusive) {
    final q = _db.select(_db.incomes)
      ..where((t) => t.occurredAt.isBiggerOrEqualValue(from) & t.occurredAt.isSmallerThanValue(toExclusive))
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);
    return q.watch().map((rows) => rows.map(_toIncome).toList());
  }

  Income _toIncome(IncomeRow r) => Income(
    id: r.id,
    amountMinor: r.amountMinor,
    currency: r.currency,
    category: r.category,
    customCategory: r.customCategory,
    note: r.note,
    occurredAt: r.occurredAt,
  );
}

final incomeRepositoryProvider = Provider<IncomeRepository>((ref) => IncomeRepository(ref.watch(databaseProvider)));
