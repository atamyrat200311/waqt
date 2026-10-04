import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../db/database_provider.dart';

class Expense {
  const Expense({
    required this.id,
    required this.amountMinor,
    required this.currency,
    required this.category,
    required this.occurredAt,
    this.note,
  });

  final int id;
  final int amountMinor;
  final String currency;
  final ExpenseCategory category;
  final String? note;
  final DateTime occurredAt;
}

/// Totals for a period, per currency is not needed: expenses are summed in
/// the user's currency (switching currency later does not convert history).
class ExpenseSummary {
  const ExpenseSummary({required this.totalMinor, required this.count, required this.byCategory});

  final int totalMinor;
  final int count;
  final Map<ExpenseCategory, int> byCategory;

  int get sadaqaMinor => byCategory[ExpenseCategory.sadaqa] ?? 0;

  static ExpenseSummary of(Iterable<Expense> items) {
    var total = 0;
    var n = 0;
    final by = <ExpenseCategory, int>{};
    for (final e in items) {
      total += e.amountMinor;
      n++;
      by[e.category] = (by[e.category] ?? 0) + e.amountMinor;
    }
    return ExpenseSummary(totalMinor: total, count: n, byCategory: by);
  }

  static const empty = ExpenseSummary(totalMinor: 0, count: 0, byCategory: {});
}

class ExpenseRepository {
  ExpenseRepository(this._db);

  final AppDatabase _db;

  Future<int> add({
    required int amountMinor,
    required String currency,
    required ExpenseCategory category,
    required DateTime occurredAt,
    String? note,
  }) {
    if (amountMinor <= 0) throw ArgumentError.value(amountMinor, 'amountMinor', 'must be > 0');
    final trimmed = note?.trim();
    return _db.into(_db.expenses).insert(ExpensesCompanion.insert(
          amountMinor: amountMinor,
          currency: Value(currency),
          category: category,
          note: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
          occurredAt: occurredAt,
        ));
  }

  Future<void> delete(int id) => (_db.delete(_db.expenses)..where((t) => t.id.equals(id))).go();

  /// Re-insert after an undo.
  Future<void> restore(Expense e) => _db.into(_db.expenses).insert(ExpensesCompanion.insert(
        id: Value(e.id),
        amountMinor: e.amountMinor,
        currency: Value(e.currency),
        category: e.category,
        note: Value(e.note),
        occurredAt: e.occurredAt,
      ));

  /// Expenses with occurredAt in [from, toExclusive), newest first.
  Stream<List<Expense>> watchBetween(DateTime from, DateTime toExclusive) {
    final q = _db.select(_db.expenses)
      ..where((t) =>
          t.occurredAt.isBiggerOrEqualValue(from) & t.occurredAt.isSmallerThanValue(toExclusive))
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);
    return q.watch().map((rows) => rows.map(_toExpense).toList());
  }

  Expense _toExpense(ExpenseRow r) => Expense(
        id: r.id,
        amountMinor: r.amountMinor,
        currency: r.currency,
        category: r.category,
        note: r.note,
        occurredAt: r.occurredAt,
      );
}

final expenseRepositoryProvider =
    Provider<ExpenseRepository>((ref) => ExpenseRepository(ref.watch(databaseProvider)));
