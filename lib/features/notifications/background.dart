import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../data/settings/settings_repository.dart';
import '../widgets/application/widget_sync.dart';
import 'application/notification_service.dart';

/// Must match `AppDelegate.rescheduleTaskId` and
/// `BGTaskSchedulerPermittedIdentifiers` in ios/Runner/Info.plist.
const kRescheduleTaskId = 'tm.ofis.waqt.reschedule';

/// Entry point of the workmanager isolate. Keeps the 7-day notification
/// window topped up even if the app is not opened for days.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, input) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await runBackgroundRefresh();
      return true;
    } on Object catch (e, s) {
      debugPrint('Waqt background task failed: $e\n$s');
      return false;
    }
  });
}

/// Reschedules notifications from the persisted settings and refreshes the
/// home-screen widgets' 7-day data.
Future<void> runBackgroundRefresh() async {
  final settings = await SettingsRepository(SharedPrefsStore()).load();
  if (!settings.onboardingDone) return;
  await rescheduleNotifications(NotificationService(), settings);
  await refreshWidgetsFromDisk();
}

/// Registers the periodic task (Android: every 6 h; iOS registers it natively
/// in AppDelegate and the OS chooses when to run it).
Future<void> initBackgroundWork() async {
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }
  try {
    await Workmanager().initialize(callbackDispatcher);
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Workmanager().registerPeriodicTask(
        kRescheduleTaskId,
        kRescheduleTaskId,
        frequency: const Duration(hours: 6),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
    }
  } on Object catch (e) {
    debugPrint('Workmanager unavailable: $e');
  }
}
