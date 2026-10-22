import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../data/settings/settings_controller.dart';
import '../../notifications/application/notification_service.dart';
import '../../prayer/application/prayer_providers.dart';

const _channel = MethodChannel('tm.ofis.waqt/live_activity');

bool get _supportsLiveActivity =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// Keeps iOS's prayer Live Activity pointed at the next prayer. ActivityKit's
/// timer continues counting while Flutter is suspended, including on Dynamic
/// Island and the Lock Screen.
final liveActivitySyncProvider = Provider<void>((ref) {
  if (!_supportsLiveActivity) return;
  int? lastTarget;
  String? lastLanguage;
  String? lastPlace;

  void sync() {
    final now = ref.read(prayerNowProvider);
    final settings = ref.read(settingsProvider);
    final l10n = l10nForSettings(settings);
    final target = now.next.time.millisecondsSinceEpoch;
    final language = settings.language;
    final place = displayPlaceName(settings.effectiveLocation.name, l10n);
    if (target == lastTarget && language == lastLanguage && place == lastPlace) {
      return;
    }
    lastTarget = target;
    lastLanguage = language;
    lastPlace = place;
    unawaited(
      _channel
          .invokeMethod<void>('syncNextPrayer', {
            'title': l10n.widgetNext,
            'prayer': l10n.prayer(now.next.prayer),
            'prayerId': now.next.prayer.name,
            'place': place,
            'targetMs': target,
          })
          .catchError((Object e) {
            debugPrint('Live Activity sync unavailable: $e');
          }),
    );
  }

  ref.listen(prayerNowProvider, (_, _) => sync(), fireImmediately: true);
  ref.listen(
    settingsProvider.select((s) => (s.language, s.location)),
    (_, _) => sync(),
  );
});
