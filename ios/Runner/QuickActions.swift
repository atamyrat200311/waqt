import Flutter
import UIKit

/// Home Screen quick actions (touch and hold the app icon).
///
/// Dart sets the items in the app language (`set`), receives taps
/// (`action`), and asks for the one that cold-launched the app (`initial`).
/// Dart side: lib/features/shortcuts/application/quick_actions.dart.
final class QuickActions: NSObject, FlutterSceneLifeCycleDelegate {
  static let shared = QuickActions()

  private var channel: FlutterMethodChannel?
  private var launchAction: String?

  func attach(_ registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tm.ofis.waqt/quick_actions", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return result(nil) }
      switch call.method {
      case "set":
        let items = (call.arguments as? [[String: String]]) ?? []
        UIApplication.shared.shortcutItems = items.compactMap { item in
          guard let type = item["type"], let title = item["title"] else { return nil }
          return UIApplicationShortcutItem(
            type: type,
            localizedTitle: title,
            localizedSubtitle: item["subtitle"],
            icon: item["icon"].map { UIApplicationShortcutIcon(systemImageName: $0) },
            userInfo: nil)
        }
        result(nil)
      case "initial":
        result(self.launchAction)
        self.launchAction = nil
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
    registrar.addSceneDelegate(self)
  }

  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    if let item = connectionOptions?.shortcutItem { launchAction = item.type }
    return false
  }

  func windowScene(
    _ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) -> Bool {
    channel?.invokeMethod("action", arguments: shortcutItem.type)
    completionHandler(true)
    return true
  }
}
