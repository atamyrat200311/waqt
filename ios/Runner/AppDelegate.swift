import Flutter
import UIKit
import ActivityKit
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
    // Apple Watch link; may receive watch events before Flutter starts.
    WatchBridge.shared.activate()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let watch = engineBridge.pluginRegistry.registrar(forPlugin: "WaqtWatch") {
      WatchBridge.shared.attach(watch.messenger())
    }
    if let shortcuts = engineBridge.pluginRegistry.registrar(forPlugin: "WaqtQuickActions") {
      QuickActions.shared.attach(shortcuts)
    }
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "WaqtLiveActivity") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "tm.ofis.waqt/live_activity",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "syncNextPrayer",
        let args = call.arguments as? [String: Any],
        let title = args["title"] as? String,
        let prayer = args["prayer"] as? String,
        let prayerId = args["prayerId"] as? String,
        let place = args["place"] as? String,
        let targetMs = args["targetMs"] as? NSNumber
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      if #available(iOS 16.1, *) {
        PrayerLiveActivityController.sync(
          title: title,
          prayer: prayer,
          prayerId: prayerId,
          place: place,
          target: Date(timeIntervalSince1970: targetMs.doubleValue / 1000)
        )
        result(nil)
      } else {
        result(nil)
      }
    }
  }
}

@available(iOS 16.1, *)
private enum PrayerLiveActivityController {
  static func sync(title: String, prayer: String, prayerId: String, place: String, target: Date) {
    guard ActivityAuthorizationInfo().areActivitiesEnabled, target > Date() else { return }
    let state = PrayerActivityAttributes.ContentState(
      prayerName: prayer,
      prayerId: prayerId,
      place: place,
      target: target
    )
    Task {
      let current = Activity<PrayerActivityAttributes>.activities
      if current.isEmpty {
        do {
          _ = try Activity.request(
            attributes: PrayerActivityAttributes(title: title),
            contentState: state,
            pushType: nil
          )
        } catch {
          NSLog("Waqt Live Activity could not start: %@", String(describing: error))
        }
      } else {
        for activity in current {
          await activity.update(using: state)
        }
      }
    }
  }
}
