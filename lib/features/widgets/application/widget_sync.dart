import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../../core/router/app_router.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/prayer_repository.dart';
import '../../../data/settings/app_settings.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../data/settings/settings_repository.dart';
import '../../calendar/domain/hijri_service.dart';
import '../../notifications/application/notification_service.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../prayer/domain/prayer_engine.dart';
import '../../today/application/today_providers.dart';
import '../domain/widget_payload.dart';

/// App Group shared with the iOS widget extension (Runner + WaqtWidget
/// entitlements).
const appGroupId = 'group.tm.ofis.waqt';
const iosWidgetKind = 'WaqtWidget';
const androidWidgetReceiver = 'tm.ofis.waqt.widget.WaqtWidgetReceiver';

bool get _widgetsSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Writes the payload to shared storage and asks the OS to redraw.
Future<void> pushWidgetPayload(
  Map<String, Object?> payload, {
  DateTime? now,
}) async {
  if (!_widgetsSupported) return;
  try {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await HomeWidget.setAppGroupId(appGroupId);
    }
    await HomeWidget.saveWidgetData<String>(widgetDataKey, jsonEncode(payload));
    await HomeWidget.updateWidget(
      iOSName: iosWidgetKind,
      qualifiedAndroidName: androidWidgetReceiver,
    );
    if (defaultTargetPlatform == TargetPlatform.android) {
      await HomeWidget.scheduleWidgetUpdates(
        widgetUpdateTimes(payload, now ?? DateTime.now()),
        qualifiedAndroidName: androidWidgetReceiver,
      );
    }
  } on Object catch (e) {
    debugPrint('Widget update failed: $e');
  }
}

PrayerEngine _engineFor(AppSettings s) {
  final loc = s.effectiveLocation;
  return PrayerEngine(
    PrayerConfig(
      latitude: loc.latitude,
      longitude: loc.longitude,
      location: locationFor(loc.timezone),
      method: s.calcMethod,
      madhab: s.madhab,
      offsets: s.offsets,
    ),
  );
}

/// Rebuilds the widget data straight from disk (background isolates).
Future<void> refreshWidgetsFromDisk({AppDatabase? db, DateTime? now}) async {
  ensureTimeZones();
  final settings = await SettingsRepository(SharedPrefsStore()).load();
  final database = db ?? AppDatabase();
  try {
    final t = now ?? DateTime.now();
    final engine = _engineFor(settings);
    final today = DayKey.fromDate(engine.localDate(t));
    final marks = await PrayerRepository(database).getDay(today);
    final l10n = l10nForSettings(settings);
    await pushWidgetPayload(
      buildWidgetPayload(
        engine: engine,
        hijri: HijriService(adjustment: settings.hijriAdjustment),
        l10n: l10n,
        placeName: displayPlaceName(settings.effectiveLocation.name, l10n),
        now: t,
        todayMarks: marks,
      ),
      now: t,
    );
  } finally {
    if (db == null) await database.close();
  }
}

/// Android widget button ("Mark as prayed"): runs in a background isolate.
/// URI: `waqt://mark?prayer=dhuhr&day=2026-10-04`.
@pragma('vm:entry-point')
Future<void> widgetInteraction(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (uri == null || uri.host != 'mark') return;
  final prayer = Prayer.tryParse(uri.queryParameters['prayer']);
  final day = uri.queryParameters['day'];
  if (prayer == null || day == null) return;
  final db = AppDatabase();
  try {
    final repo = PrayerRepository(db);
    final current = (await repo.getDay(DayKey(day)))[prayer];
    if (current == null) {
      await repo.mark(DayKey(day), prayer, PrayerStatus.onTime);
    }
    await refreshWidgetsFromDisk(db: db);
  } finally {
    await db.close();
  }
}

/// Route for a widget tap URI (`waqt://today?mark=asr&day=…` or `waqt://today`).
String? routeForWidgetUri(Uri? uri) {
  if (uri == null) return null;
  final p = uri.queryParameters['mark'];
  final d = uri.queryParameters['day'];
  if (p != null && d != null && Prayer.tryParse(p) != null) {
    return Routes.markPrayer(p, d);
  }
  return Routes.today;
}

/// Keeps the widgets in sync while the app runs and routes widget taps.
final widgetSyncProvider = Provider<void>((ref) {
  if (!_widgetsSupported) return;
  Timer? debounce;

  void push() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 800), () {
      final s = ref.read(settingsProvider);
      final l10n = l10nForSettings(s);
      final now = ref.read(clockProvider)();
      unawaited(
        pushWidgetPayload(
          buildWidgetPayload(
            engine: ref.read(prayerEngineProvider),
            hijri: ref.read(hijriServiceProvider),
            l10n: l10n,
            placeName: displayPlaceName(s.effectiveLocation.name, l10n),
            now: now,
            todayMarks: ref.read(todayMarksProvider).value ?? const {},
          ),
          now: now,
        ),
      );
    });
  }

  ref.listen(prayerEngineProvider, (_, _) => push());
  ref.listen(todayKeyProvider, (_, _) => push());
  ref.listen(todayMarksProvider, (_, _) => push());
  ref.listen(
    settingsProvider.select((s) => (s.language, s.hijriAdjustment)),
    (_, _) => push(),
    fireImmediately: true,
  );

  void go(Uri? uri) {
    final route = routeForWidgetUri(uri);
    if (route != null) ref.read(appRouterProvider).go(route);
  }

  unawaited(
    HomeWidget.registerInteractivityCallback(
      widgetInteraction,
    ).catchError((Object _) => null),
  );
  unawaited(
    HomeWidget.initiallyLaunchedFromHomeWidget().then(
      go,
      onError: (Object _) {},
    ),
  );
  final sub = HomeWidget.widgetClicked.listen(go, onError: (Object _) {});
  ref.onDispose(() {
    debounce?.cancel();
    sub.cancel();
  });
});
