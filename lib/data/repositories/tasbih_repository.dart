import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../db/database_provider.dart';

class TasbihRepository {
  TasbihRepository(this._db);

  final AppDatabase _db;

  /// Saves a finished or reset session (ignored when nothing was counted).
  Future<void> addSession(String phrase, int count, int goal, {DateTime? now}) async {
    if (count <= 0) return;
    await _db.into(_db.tasbihSessions).insert(TasbihSessionsCompanion.insert(
          phrase: phrase,
          count: count,
          goal: goal,
          createdAt: now ?? DateTime.now(),
        ));
  }
}

final tasbihRepositoryProvider =
    Provider<TasbihRepository>((ref) => TasbihRepository(ref.watch(databaseProvider)));
