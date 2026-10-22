import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock.dart';
import '../../../data/db/enums.dart';
import '../../../data/repositories/adhkar_repository.dart';
import '../../../data/repositories/prayer_repository.dart';
import '../../../data/repositories/tasbih_repository.dart';
import '../../../data/settings/settings_controller.dart';
import '../../adhkar/application/adhkar_providers.dart';
import '../../me/application/me_providers.dart';
import '../../notifications/application/notification_service.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../today/application/today_providers.dart';
import '../domain/watch_payload.dart';

/// Native side: ios/Runner/WatchBridge.swift (WatchConnectivity).
const _channel = MethodChannel('tm.ofis.waqt/watch');

bool get _supportsWatch => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// Pairing state reported by WatchConnectivity (Settings ▸ Widgets).
typedef WatchStatus = ({bool paired, bool installed});

final watchStatusProvider = FutureProvider.autoDispose<WatchStatus?>((ref) async {
  if (!_supportsWatch) return null;
  ref.watch(appLifecycleProvider);
  try {
    final m = await _channel.invokeMapMethod<String, Object?>('status');
    if (m == null) return null;
    return (paired: m['paired'] == true, installed: m['installed'] == true);
  } on Object {
    return null;
  }
});

/// Keeps the Apple Watch app in sync while the phone app runs: pushes a
/// 30-day payload whenever times, marks, streak or adhkar progress change,
/// and applies what the user did on the watch (marks, tasbih, adhkar).
final watchSyncProvider = Provider<void>((ref) {
  if (!_supportsWatch) return;
  // A new day rebuilds the provider, so the adhkar listeners follow it.
  final today = ref.watch(todayKeyProvider);
  Timer? debounce;
  var draining = false;

  void push() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 900), () {
      final s = ref.read(settingsProvider);
      final l10n = l10nForSettings(s);
      final loc = s.effectiveLocation;
      final payload = buildWatchPayload(
        engine: ref.read(prayerEngineProvider),
        hijri: ref.read(hijriServiceProvider),
        l10n: l10n,
        language: ref.read(appLanguageProvider),
        placeName: displayPlaceName(loc.name, l10n),
        latitude: loc.latitude,
        longitude: loc.longitude,
        now: ref.read(clockProvider)(),
        todayMarks: ref.read(todayMarksProvider).value ?? const {},
        streak: ref.read(streakProvider)?.current ?? 0,
        adhkarCounts: {
          for (final set in AdhkarSet.values) set: ref.read(adhkarCountsProvider((today, set))).value ?? const {},
        },
      );
      unawaited(
        _channel.invokeMethod<void>('sync', jsonEncode(payload)).catchError((Object e) {
          debugPrint('Watch sync unavailable: $e');
        }),
      );
    });
  }

  Future<void> apply(WatchEvent e) async {
    switch (e) {
      case WatchMark():
        if (!e.isAllowed(ref.read(prayerEngineProvider), ref.read(clockProvider)())) return;
        await ref.read(prayerRepositoryProvider).mark(e.day, e.prayer, e.status, now: e.at);
      case WatchTasbih():
        await ref.read(tasbihRepositoryProvider).addSession(e.phrase, e.count, e.goal, now: e.at);
      case WatchAdhkar():
        await ref.read(adhkarRepositoryProvider).setCount(e.day, e.set, e.itemId, e.count);
    }
  }

  Future<void> drain() async {
    if (draining) return;
    draining = true;
    try {
      final raw = await _channel.invokeListMethod<Object?>('drain') ?? const [];
      final events = raw.map(WatchEvent.tryParse).nonNulls.toList()..sort((a, b) => a.at.compareTo(b.at));
      for (final e in events) {
        try {
          await apply(e);
        } on Object catch (err) {
          debugPrint('Watch event dropped: $err');
        }
      }
      // Tasbih sessions change nothing the payload shows, but the watch
      // still needs the new acknowledgement to drop its pending marks.
      if (raw.isNotEmpty) push();
    } on Object catch (e) {
      debugPrint('Watch drain unavailable: $e');
    } finally {
      draining = false;
    }
  }

  _channel.setMethodCallHandler((call) async {
    if (call.method == 'events') await drain();
    return null;
  });

  ref.listen(prayerEngineProvider, (_, _) => push());
  ref.listen(todayMarksProvider, (_, _) => push());
  ref.listen(streakProvider.select((s) => s?.current), (_, _) => push());
  ref.listen(adhkarCountsProvider((today, AdhkarSet.morning)), (_, _) => push());
  ref.listen(adhkarCountsProvider((today, AdhkarSet.evening)), (_, _) => push());
  ref.listen(
    settingsProvider.select((s) => (s.language, s.hijriAdjustment, s.location)),
    (_, _) => push(),
    fireImmediately: true,
  );
  ref.listen(appLifecycleProvider, (_, s) {
    if (s == AppLifecycleState.resumed) unawaited(drain());
  });
  unawaited(drain());

  ref.onDispose(() {
    debounce?.cancel();
    _channel.setMethodCallHandler(null);
  });
});
