import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock.dart';
import '../../../data/settings/app_settings.dart';
import '../../../data/settings/settings_controller.dart';
import 'notification_service.dart';

/// Inputs that change what gets scheduled. Anything else in [AppSettings]
/// (theme, currency…) does not trigger a reschedule.
Object _scheduleKey(AppSettings s) => Object.hashAll([
      s.calcMethod,
      s.madhab,
      Object.hashAll(s.offsets.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(s.alerts.entries.map((e) => Object.hash(e.key, e.value))),
      s.effectiveLocation,
      s.language,
      s.hijriAdjustment,
      s.ramadanMode,
      s.periodMode,
      s.onboardingDone,
      s.adhkarReminders,
      s.suhoorReminder,
      s.suhoorMinutes,
      s.iftarReminder,
      s.taraweehReminder,
    ]);

/// Keeps scheduled notifications in sync with settings: reschedules (debounced)
/// when a relevant setting changes and whenever the app comes to the
/// foreground. Watched once from the app root.
final notificationSchedulerProvider = Provider<void>((ref) {
  Timer? debounce;
  var running = false;
  var again = false;

  Future<void> run() async {
    if (running) {
      again = true;
      return;
    }
    running = true;
    try {
      final s = ref.read(settingsProvider);
      if (!s.onboardingDone) return;
      await rescheduleNotifications(
        ref.read(notificationServiceProvider),
        s,
        now: ref.read(clockProvider)(),
      );
    } on Object catch (e) {
      debugPrint('Reschedule failed: $e');
    } finally {
      running = false;
      if (again) {
        again = false;
        unawaited(run());
      }
    }
  }

  void schedule([Duration wait = const Duration(milliseconds: 600)]) {
    debounce?.cancel();
    debounce = Timer(wait, run);
  }

  ref.listen(settingsProvider.select(_scheduleKey), (_, _) => schedule(), fireImmediately: true);
  ref.listen(appLifecycleProvider, (prev, next) {
    if (next == AppLifecycleState.resumed && prev != AppLifecycleState.resumed) schedule();
  });
  ref.onDispose(() => debounce?.cancel());
});
