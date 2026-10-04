import Flutter
import UIKit
import flutter_local_notifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Must match `kRescheduleTaskId` in lib/features/notifications/background.dart
  /// and BGTaskSchedulerPermittedIdentifiers in Info.plist.
  static let rescheduleTaskId = "tm.ofis.waqt.reschedule"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Show prayer alerts as banners even while the app is open.
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate

    // Background isolates (notification actions, BGTaskScheduler) need plugins too.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    // Periodic notification rescheduling (iOS decides the exact time; ~every 6 h hint).
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: AppDelegate.rescheduleTaskId,
      earliestBeginInSeconds: NSNumber(value: 6 * 60 * 60)
    )
    // UIScene apps must re-register BG handlers before didFinishLaunching returns.
    WorkmanagerPlugin.registerLaunchHandlers()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
