import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/prayer_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../domain/period_mode.dart';
import 'prayer_providers.dart';

/// While period mode is on, marks passed prayers as `excused` when the app
/// opens and as each prayer time arrives. Watched once from the app root.
final periodModeSyncProvider = Provider<void>((ref) {
  var busy = false;

  Future<void> sync() async {
    final s = ref.read(settingsProvider);
    if (!s.periodMode || busy) return;
    busy = true;
    try {
      final engine = ref.read(prayerEngineProvider);
      final now = ref.read(prayerNowProvider).now;
      final today = DayKey.fromDate(engine.localDate(now));
      final since = s.periodSince == null ? today : DayKey(s.periodSince!);
      final repo = ref.read(prayerRepositoryProvider);
      final logs = await repo.getRange(since, today);
      final marked = <DayKey, Set<Prayer>>{};
      for (final l in logs) {
        (marked[l.day] ??= {}).add(l.prayer);
      }
      final items = prayersToExcuse(engine: engine, since: since, now: now, marked: marked);
      if (items.isNotEmpty) await repo.markMany(items, PrayerStatus.excused);
    } on Object catch (e) {
      debugPrint('Period mode sync failed: $e');
    } finally {
      busy = false;
    }
  }

  ref.listen(settingsProvider.select((s) => s.periodMode), (_, _) => sync(), fireImmediately: true);
  // Re-check when a prayer time passes (next prayer changes).
  ref.listen(prayerNowProvider.select((n) => (n.next.prayer, n.next.time)), (_, _) => sync());
});
