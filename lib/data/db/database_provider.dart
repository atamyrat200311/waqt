import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// One database per app process. Overridden with an in-memory DB in tests.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
