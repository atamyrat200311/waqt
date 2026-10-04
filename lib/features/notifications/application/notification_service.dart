import 'dart:async';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/dates.dart';
import '../../../data/db/enums.dart';
import '../../../data/settings/app_settings.dart';
import '../../calendar/domain/hijri_service.dart';
import '../../prayer/application/prayer_providers.dart';
import '../../prayer/domain/prayer_engine.dart';
import '../../ramadan/domain/ramadan.dart';
import '../domain/notification_plan.dart';

/// Android channels. Channel sound is fixed once created, so adhan and
/// "silent" (system default sound, see CLAUDE.md conflict #2) are separate.
abstract final class Channels {
  static const adhan = 'waqt.prayer.adhan.v1';
  static const standard = 'waqt.prayer.standard.v1';
  static const reminders = 'waqt.reminders.v1';
}

/// Name of the bundled adhan sound: `res/raw/adhan.*` on Android and
/// `ios/Runner/adhan.wav` (added to the Runner target) on iOS.
const _androidAdhan = 'adhan';
const _iosAdhan = 'adhan.wav';

/// Permission state shown in Settings / onboarding.
class NotificationPermissions {
  const NotificationPermissions({required this.enabled, required this.exactAlarms});
  final bool enabled;

  /// Android 12+: SCHEDULE_EXACT_ALARM granted. Always true on iOS.
  final bool exactAlarms;
}

/// Wraps flutter_local_notifications. All scheduling decisions are made by
/// the pure [NotificationPlanner]; this class only talks to the platform.
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// Taps on notifications while the app runs (and the launch tap, replayed
  /// once a listener is attached).
  final _taps = StreamController<NotificationPayload>.broadcast();
  Stream<NotificationPayload> get taps => _taps.stream;
  NotificationPayload? _launchPayload;

  /// The payload that launched the app, consumed once.
  NotificationPayload? takeLaunchPayload() {
    final p = _launchPayload;
    _launchPayload = null;
    return p;
  }

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

  Future<void> init({AppLocalizations? l10n}) async {
    if (_initialized || !_supported) return;
    ensureTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_waqt'),
        // Permission is asked during onboarding, not on first launch.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        final p = NotificationPayload.parse(r.payload);
        if (p != null) _taps.add(p);
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _launchPayload = NotificationPayload.parse(launch!.notificationResponse?.payload);
    }
    await _createChannels(l10n ?? _l10nFor(null));
    _initialized = true;
  }

  Future<void> _createChannels(AppLocalizations l) async {
    final a = _android;
    if (a == null) return;
    await a.createNotificationChannel(AndroidNotificationChannel(
      Channels.adhan,
      l.chanAdhan,
      importance: Importance.high,
      sound: const RawResourceAndroidNotificationSound(_androidAdhan),
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ));
    await a.createNotificationChannel(AndroidNotificationChannel(
      Channels.standard,
      l.chanStandard,
      importance: Importance.high,
    ));
    await a.createNotificationChannel(AndroidNotificationChannel(
      Channels.reminders,
      l.chanReminders,
      importance: Importance.defaultImportance,
    ));
  }

  // ------------------------------------------------------------ permissions

  Future<NotificationPermissions> permissions() async {
    if (!_supported) return const NotificationPermissions(enabled: false, exactAlarms: false);
    final a = _android;
    if (a != null) {
      return NotificationPermissions(
        enabled: await a.areNotificationsEnabled() ?? false,
        exactAlarms: await a.canScheduleExactNotifications() ?? false,
      );
    }
    final opts = await _ios?.checkPermissions();
    return NotificationPermissions(enabled: opts?.isEnabled ?? false, exactAlarms: true);
  }

  /// Asks for notification permission. Returns whether alerts are allowed.
  Future<bool> requestPermission() async {
    if (!_supported) return false;
    final a = _android;
    if (a != null) return await a.requestNotificationsPermission() ?? false;
    return await _ios?.requestPermissions(alert: true, sound: true, badge: false) ?? false;
  }

  /// Android 12+: opens the "Alarms & reminders" screen.
  Future<void> requestExactAlarms() async => _android?.requestExactAlarmsPermission();

  // ------------------------------------------------------------- scheduling

  /// Cancels every planned notification and schedules [plan]. "Remind me"
  /// notifications (ids ≥ [NotificationPlanner.reminderIdBase]) survive.
  Future<void> apply(
    List<PlannedNotification> plan, {
    required AppLocalizations l10n,
    required String placeName,
    required tz.Location location,
    required int suhoorMinutes,
  }) async {
    if (!_supported) return;
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      if (p.id < NotificationPlanner.reminderIdBase) await _plugin.cancel(id: p.id);
    }
    final mode = await _scheduleMode();
    for (final n in plan) {
      final (title, body) = _texts(n, l10n, placeName, location, suhoorMinutes);
      await _plugin.zonedSchedule(
        id: n.id,
        scheduledDate: tz.TZDateTime.from(n.at, location),
        title: title,
        body: body,
        payload: n.payload,
        androidScheduleMode: mode,
        notificationDetails: _details(n),
      );
    }
  }

  /// "Remind me in 15 min" from the mark sheet.
  Future<DateTime> remindIn(
    Prayer prayer,
    DayKey day, {
    required AppLocalizations l10n,
    Duration after = const Duration(minutes: 15),
    DateTime? now,
  }) async {
    final at = (now ?? DateTime.now()).add(after);
    if (!_supported) return at;
    final pending = await _plugin.pendingNotificationRequests();
    final used = pending.map((p) => p.id).where((id) => id >= NotificationPlanner.reminderIdBase).toSet();
    var id = NotificationPlanner.reminderIdBase;
    while (used.contains(id)) {
      id++;
    }
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: tz.TZDateTime.from(at, tz.UTC),
      title: l10n.notifRemindTitle(l10n.prayer(prayer)),
      body: l10n.notifRemindBody(l10n.prayer(prayer)),
      payload: 'mark:${prayer.name}:${day.value}',
      androidScheduleMode: await _scheduleMode(),
      notificationDetails: _reminderDetails,
    );
    return at;
  }

  Future<void> cancelAll() async {
    if (_supported) await _plugin.cancelAll();
  }

  Future<AndroidScheduleMode> _scheduleMode() async {
    final exact = await _android?.canScheduleExactNotifications() ?? true;
    return exact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  static const _reminderDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      Channels.reminders,
      'Reminders',
      importance: Importance.defaultImportance,
      category: AndroidNotificationCategory.reminder,
    ),
    iOS: DarwinNotificationDetails(presentSound: true),
  );

  NotificationDetails _details(PlannedNotification n) {
    final isPrayer = n.kind == NotificationKind.prayer || n.kind == NotificationKind.iftar;
    if (!isPrayer) return _reminderDetails;
    final adhan = n.alert == AlertType.adhan;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        adhan ? Channels.adhan : Channels.standard,
        adhan ? 'Prayer times · adhan' : 'Prayer times · standard sound',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        sound: adhan ? const RawResourceAndroidNotificationSound(_androidAdhan) : null,
      ),
      iOS: DarwinNotificationDetails(
        presentSound: true,
        sound: adhan ? _iosAdhan : null,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  (String, String) _texts(
    PlannedNotification n,
    AppLocalizations l,
    String place,
    tz.Location location,
    int suhoorMinutes,
  ) {
    final time = hhmm(tz.TZDateTime.from(n.at, location));
    return switch (n.kind) {
      NotificationKind.prayer => (
          l.notifPrayerTitle(l.prayer(n.prayer!), time),
          l.notifPrayerBody(l.prayer(n.prayer!), place),
        ),
      NotificationKind.iftar => (l.notifIftarTitle, l.notifIftarBody(place)),
      NotificationKind.suhoor => (
          l.notifSuhoorTitle(hhmm(tz.TZDateTime.from(n.at, location).add(Duration(minutes: suhoorMinutes)))),
          l.notifSuhoorBody('$suhoorMinutes'),
        ),
      NotificationKind.taraweeh => (l.homeTaraweeh, l.homeTaraweehSub(time)),
      NotificationKind.adhkarMorning => (l.adhkarMorning, l.notifMorningBody),
      NotificationKind.adhkarEvening => (l.adhkarEvening, l.notifEveningBody),
    };
  }
}

/// Strings for a language code (null = device language) without a context.
AppLocalizations _l10nFor(String? language) {
  final code = language ?? PlatformDispatcher.instance.locale.languageCode;
  final supported = AppLocalizations.supportedLocales.map((l) => l.languageCode);
  return lookupAppLocalizations(Locale(supported.contains(code) ? code : 'en'));
}

AppLocalizations l10nForSettings(AppSettings s) => _l10nFor(s.language);

/// Plans and applies notifications for [settings]. Shared by the app and the
/// workmanager isolate.
Future<int> rescheduleNotifications(
  NotificationService service,
  AppSettings settings, {
  DateTime? now,
}) async {
  final loc = settings.effectiveLocation;
  final location = locationFor(loc.timezone);
  final engine = PrayerEngine(PrayerConfig(
    latitude: loc.latitude,
    longitude: loc.longitude,
    location: location,
    method: settings.calcMethod,
    madhab: settings.madhab,
    offsets: settings.offsets,
  ));
  final hijri = HijriService(adjustment: settings.hijriAdjustment);
  final plan = NotificationPlanner.plan(
    engine: engine,
    settings: settings,
    now: now ?? DateTime.now(),
    isRamadan: (d) => isRamadanActive(settings.ramadanMode, hijri, d),
  );
  final l10n = l10nForSettings(settings);
  await service.init(l10n: l10n);
  await service.apply(
    plan,
    l10n: l10n,
    placeName: displayPlaceName(loc.name, l10n),
    location: location,
    suhoorMinutes: settings.suhoorMinutes,
  );
  return plan.length;
}

/// "~Mary" (stored for approximate GPS fixes) → "Near Mary".
String displayPlaceName(String stored, AppLocalizations l) =>
    stored.startsWith('~') ? l.locationNearby(stored.substring(1)) : stored;

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());
