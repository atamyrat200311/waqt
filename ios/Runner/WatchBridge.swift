import Flutter
import Foundation
import WatchConnectivity

/// iPhone end of the Apple Watch link (WatchConnectivity).
///
/// Dart → watch: `sync(json)` stores the payload and sends it as the
/// application context (latest wins, delivered in the background).
/// Watch → Dart: events (marks, tasbih, adhkar) are queued in UserDefaults —
/// the watch can wake this app while Flutter is not running — and handed to
/// Dart by `drain`. The context carries `ack` (newest drained event) so the
/// watch can drop the marks the phone has applied.
/// Dart side: lib/features/watch/application/watch_sync.dart.
final class WatchBridge: NSObject, WCSessionDelegate {
  static let shared = WatchBridge()

  private let defaults = UserDefaults.standard
  private let pendingKey = "waqt_watch_pending"
  private let seenKey = "waqt_watch_seen"
  private let payloadKey = "waqt_watch_payload"
  private let ackKey = "waqt_watch_ack"
  private var channel: FlutterMethodChannel?

  private var ack: Int64 {
    get { (defaults.object(forKey: ackKey) as? NSNumber)?.int64Value ?? 0 }
    set { defaults.set(NSNumber(value: newValue), forKey: ackKey) }
  }

  func activate() {
    guard WCSession.isSupported() else { return }
    WCSession.default.delegate = self
    WCSession.default.activate()
  }

  func attach(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "tm.ofis.waqt/watch", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result) ?? result(nil)
    }
    self.channel = channel
  }

  private func handle(_ call: FlutterMethodCall, result: FlutterResult) {
    switch call.method {
    case "sync":
      guard let json = call.arguments as? String else {
        result(FlutterError(code: "args", message: "payload JSON expected", details: nil))
        return
      }
      defaults.set(json, forKey: payloadKey)
      pushContext()
      result(nil)
    case "drain":
      let events = pending
      if !events.isEmpty {
        let newest = events.compactMap { ($0["at"] as? NSNumber)?.int64Value }.max() ?? 0
        ack = max(ack, newest)
        defaults.removeObject(forKey: pendingKey)
      }
      result(events)
    case "status":
      let s = WCSession.isSupported() ? WCSession.default : nil
      let active = s?.activationState == .activated
      result([
        "paired": active && (s?.isPaired ?? false),
        "installed": active && (s?.isWatchAppInstalled ?? false),
      ])
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private var pending: [[String: Any]] {
    defaults.array(forKey: pendingKey) as? [[String: Any]] ?? []
  }

  private func pushContext() {
    guard WCSession.isSupported() else { return }
    let s = WCSession.default
    guard s.activationState == .activated, s.isPaired, s.isWatchAppInstalled,
      let json = defaults.string(forKey: payloadKey)
    else { return }
    do {
      try s.updateApplicationContext(["payload": json, "ack": NSNumber(value: ack)])
    } catch {
      NSLog("Waqt watch context not sent: %@", String(describing: error))
    }
  }

  /// Queues one watch event (main thread), skipping duplicates — the watch
  /// may deliver the same event by message and by queued transfer.
  private func enqueue(_ event: [String: Any]) {
    guard let type = event["t"] as? String, type != "hello",
      let at = (event["at"] as? NSNumber)?.int64Value
    else { return }
    let id = "\(type)-\(event["p"] ?? event["item"] ?? "")-\(at)"
    var seen = defaults.stringArray(forKey: seenKey) ?? []
    guard !seen.contains(id) else { return }
    seen.append(id)
    defaults.set(Array(seen.suffix(300)), forKey: seenKey)
    var events = pending
    events.append(event)
    defaults.set(events, forKey: pendingKey)
    channel?.invokeMethod("events", arguments: nil)
  }

  // MARK: WCSessionDelegate

  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    DispatchQueue.main.async { self.pushContext() }
  }

  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {
    // Switching to another watch: activate the session for the new one.
    WCSession.default.activate()
  }

  func sessionWatchStateDidChange(_ session: WCSession) {
    DispatchQueue.main.async { self.pushContext() }
  }

  func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
    DispatchQueue.main.async { self.enqueue(userInfo) }
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    DispatchQueue.main.async { self.enqueue(message) }
  }

  func session(
    _ session: WCSession, didReceiveMessage message: [String: Any],
    replyHandler: @escaping ([String: Any]) -> Void
  ) {
    DispatchQueue.main.async {
      if message["t"] as? String == "hello" {
        replyHandler([
          "payload": self.defaults.string(forKey: self.payloadKey) ?? "",
          "ack": NSNumber(value: self.ack),
        ])
      } else {
        self.enqueue(message)
        replyHandler([:])
      }
    }
  }
}
