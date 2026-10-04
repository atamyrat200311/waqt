import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/adhkar_repository.dart';
import '../../prayer/application/prayer_providers.dart';
import '../domain/adhkar.dart';

final adhkarCatalogProvider = FutureProvider<AdhkarCatalog>((ref) async {
  final json = await rootBundle.loadString('assets/adhkar/adhkar.json');
  return AdhkarCatalog.fromJsonString(json);
});

/// itemId → count for a set on a day.
final adhkarCountsProvider =
    StreamProvider.family<Map<String, int>, (DayKey, AdhkarSet)>((ref, key) {
  return ref.watch(adhkarRepositoryProvider).watchDay(key.$1, key.$2);
});

/// Today's progress for a set (empty while the catalog loads).
final adhkarTodayProvider = Provider.family<AdhkarProgress, AdhkarSet>((ref, set) {
  final day = ref.watch(todayKeyProvider);
  final catalog = ref.watch(adhkarCatalogProvider).value ?? AdhkarCatalog.empty;
  final counts = ref.watch(adhkarCountsProvider((day, set))).value ?? const {};
  return AdhkarProgress(catalog.items(set), counts);
});
