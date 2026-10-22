import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/settings/settings_controller.dart';
import '../../notifications/application/notification_service.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../today/application/today_providers.dart';

/// Native side: ios/Runner/QuickActions.swift.
const _channel = MethodChannel('tm.ofis.waqt/quick_actions');

bool get _supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// One Home Screen quick action (touch and hold the app icon).
typedef QuickAction = ({String type, String title, String? subtitle, String icon});

/// The actions for this moment: mark the open prayer, continue the Quran,
/// Qibla, and the adhkar of the time of day (morning until Asr).
List<QuickAction> quickActionsFor({
  required AppLocalizations l,
  required Prayer? openPrayer,
  required bool eveningAdhkar,
}) => [
  (
    type: 'mark',
    title: l.widgetMarkPrayed,
    subtitle: openPrayer == null ? null : l.prayer(openPrayer),
    icon: 'checkmark.circle',
  ),
  (type: 'quran', title: l.quranContinue, subtitle: null, icon: 'book'),
  (type: 'qibla', title: l.qibla, subtitle: null, icon: 'location.north.line'),
  (
    type: 'adhkar',
    title: eveningAdhkar ? l.adhkarEvening : l.adhkarMorning,
    subtitle: null,
    icon: eveningAdhkar ? 'moon.stars' : 'sun.max',
  ),
];

final quickActionsProvider = Provider<void>((ref) {
  if (!_supported) return;
  String? last;

  ({Prayer? open, String? openDay, bool evening}) moment() {
    final engine = ref.read(prayerEngineProvider);
    final now = ref.read(clockProvider)();
    final window = engine.currentWindow(now);
    final today = ref.read(todayKeyProvider);
    final marks = ref.read(todayMarksProvider).value ?? const {};
    final unmarked = window != null && !(DayKey.fromDate(window.day) == today && marks[window.prayer] != null);
    return (
      open: unmarked ? window.prayer : null,
      openDay: unmarked ? DayKey.fromDate(window.day).value : null,
      evening: !now.isBefore(engine.day(engine.localDate(now))[Prayer.asr]),
    );
  }

  void publish() {
    final m = moment();
    final items = quickActionsFor(
      l: l10nForSettings(ref.read(settingsProvider)),
      openPrayer: m.open,
      eveningAdhkar: m.evening,
    );
    final encoded = [
      for (final a in items) {'type': a.type, 'title': a.title, 'subtitle': ?a.subtitle, 'icon': a.icon},
    ];
    final key = encoded.toString();
    if (key == last) return;
    last = key;
    unawaited(_channel.invokeMethod<void>('set', encoded).catchError((Object _) {}));
  }

  void open(String type) {
    final router = ref.read(appRouterProvider);
    final m = moment();
    switch (type) {
      case 'mark':
        router.go(m.open != null ? Routes.markPrayer(m.open!.name, m.openDay!) : Routes.today);
      case 'quran':
        // Open over the Quran tab so swiping back lands somewhere sensible.
        router.go(Routes.quran);
        unawaited(router.push(Routes.read(ref.read(settingsProvider).quranLastRead ?? 0)));
      case 'qibla':
        router.go(Routes.qiblaFull);
      case 'adhkar':
        router.go(Routes.today);
        unawaited(router.push(Routes.adhkar(m.evening ? AdhkarSet.evening.name : AdhkarSet.morning.name)));
    }
  }

  _channel.setMethodCallHandler((call) async {
    if (call.method == 'action' && call.arguments is String) open(call.arguments as String);
    return null;
  });
  unawaited(
    _channel.invokeMethod<String>('initial').then((t) {
      if (t != null) open(t);
    }, onError: (Object _) {}),
  );

  ref.listen(prayerNowProvider, (_, _) => publish());
  ref.listen(todayMarksProvider, (_, _) => publish());
  ref.listen(settingsProvider.select((s) => s.language), (_, _) => publish(), fireImmediately: true);
  ref.onDispose(() => _channel.setMethodCallHandler(null));
});
