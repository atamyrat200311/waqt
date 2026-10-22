// The watch app's state: the phone's payload (WatchConnectivity application
// context), marks made on the watch, adhkar progress, and the event queue to
// the phone (ios/Runner/WatchBridge.swift → lib/features/watch/).

import Foundation
import SwiftUI
import WatchConnectivity
import WatchKit
import WidgetKit

@MainActor
final class WatchStore: NSObject, ObservableObject {
  static let shared = WatchStore()

  @Published private(set) var payload: WPayload?
  @Published private(set) var overrides: [MarkOverride]
  /// itemId → count for today's adhkar, per set ("morning" / "evening").
  @Published private(set) var adhkar: [String: [String: Int]] = [:]

  private var adhkarDay = ""
  private var adhkarFlush: Task<Void, Never>?
  private var pendingAdhkar: [String: [String: Any]] = [:]

  private override init() {
    payload = WatchData.payload()
    overrides = WatchData.overrides()
    super.init()
    loadAdhkar()
    if WCSession.isSupported() {
      WCSession.default.delegate = self
      WCSession.default.activate()
    }
  }

  // MARK: Strings

  /// A watch string in the app's language, with an English fallback.
  func t(_ key: String, _ fallback: String) -> String {
    guard let s = payload?.w?[key], !s.isEmpty else { return fallback }
    return s
  }

  var language: String { payload?.lang ?? Locale.current.language.languageCode?.identifier ?? "en" }

  /// Shown before the first sync (no payload yet, so no app strings).
  var openPhoneHint: String {
    switch Locale.current.language.languageCode?.identifier {
    case "tr": "Eşitlemek için iPhone’da Waqt’ı bir kez açın."
    case "ru": "Откройте Waqt на iPhone, чтобы синхронизировать."
    case "tk": "Sinhronlamak üçin iPhone-da Waqt-y bir gezek açyň."
    default: "Open Waqt on your iPhone once to sync."
    }
  }

  // MARK: Prayers

  func marks(for day: WDay) -> [String] {
    guard let p = payload else { return day.m }
    return WatchData.marks(for: day, in: p, overrides: overrides)
  }

  /// Marks (or with "" clears) a prayer and queues it to the phone.
  func mark(day: String, prayer: Int, status: String) {
    let at = Int64(Date().timeIntervalSince1970 * 1000)
    overrides.removeAll { $0.day == day && $0.prayer == prayer }
    overrides.append(MarkOverride(day: day, prayer: prayer, status: status, at: at))
    WatchData.save(overrides: overrides)
    WidgetCenter.shared.reloadAllTimelines()
    send(["t": "mark", "day": day, "p": waqtPrayerIds[prayer], "s": status, "at": at])
    WKInterfaceDevice.current().play(status.isEmpty ? .click : .success)
  }

  // MARK: Tasbih

  func saveTasbih(phrase: String, count: Int, goal: Int) {
    guard count > 0 else { return }
    send([
      "t": "tasbih", "phrase": phrase, "count": count, "goal": goal,
      "at": Int64(Date().timeIntervalSince1970 * 1000),
    ])
  }

  // MARK: Adhkar

  private var todayKey: String {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    f.locale = Locale(identifier: "en_US_POSIX")
    return f.string(from: Date())
  }

  private func loadAdhkar() {
    let today = todayKey
    var counts: [String: [String: Int]] = [:]
    if let p = payload, p.adhkarDay == today { counts = p.adhkar ?? [:] }
    if let saved = UserDefaults.standard.dictionary(forKey: "adhkar") as? [String: Any],
      saved["day"] as? String == today, let local = saved["counts"] as? [String: [String: Int]]
    {
      for (set, items) in local {
        counts[set, default: [:]].merge(items) { max($0, $1) }
      }
    }
    adhkarDay = today
    adhkar = counts
  }

  func adhkarCount(set: String, item: String) -> Int {
    if adhkarDay != todayKey { loadAdhkar() }
    return adhkar[set]?[item] ?? 0
  }

  func setAdhkar(set: String, item: String, count: Int) {
    if adhkarDay != todayKey { loadAdhkar() }
    adhkar[set, default: [:]][item] = count
    UserDefaults.standard.set(["day": adhkarDay, "counts": adhkar], forKey: "adhkar")
    // Taps arrive quickly; send each item's latest count once things settle.
    pendingAdhkar["\(set)/\(item)"] = [
      "t": "adhkar", "day": adhkarDay, "set": set, "item": item, "count": count,
      "at": Int64(Date().timeIntervalSince1970 * 1000),
    ]
    adhkarFlush?.cancel()
    adhkarFlush = Task { [weak self] in
      try? await Task.sleep(nanoseconds: 2_000_000_000)
      guard !Task.isCancelled else { return }
      self?.flushAdhkar()
    }
  }

  func flushAdhkar() {
    adhkarFlush?.cancel()
    for event in pendingAdhkar.values { send(event) }
    pendingAdhkar.removeAll()
  }

  // MARK: Phone link

  private func send(_ event: [String: Any]) {
    guard WCSession.isSupported() else { return }
    let s = WCSession.default
    guard s.activationState == .activated else { return }
    if s.isReachable {
      // Wakes the iPhone app, so the mark lands right away; the queued
      // transfer is the fallback (the phone de-duplicates by "at").
      s.sendMessage(event, replyHandler: nil) { _ in s.transferUserInfo(event) }
    } else {
      s.transferUserInfo(event)
    }
  }

  /// Asks the phone for its latest payload (first launch, or stale data).
  func requestSync() {
    guard WCSession.isSupported() else { return }
    let s = WCSession.default
    guard s.activationState == .activated, s.isReachable else { return }
    s.sendMessage(["t": "hello"], replyHandler: { reply in
      Task { @MainActor in self.receive(reply) }
    }, errorHandler: nil)
  }

  fileprivate func receive(_ context: [String: Any]) {
    if let ack = (context["ack"] as? NSNumber)?.int64Value {
      UserDefaults.standard.set(ack, forKey: watchAckKey)
      let before = overrides
      overrides.removeAll { $0.at <= ack }
      if overrides != before { WatchData.save(overrides: overrides) }
    }
    guard let json = context["payload"] as? String, !json.isEmpty, let p = WPayload.decode(json) else { return }
    WatchData.defaults.set(json, forKey: watchPayloadKey)
    payload = p
    loadAdhkar()
    WidgetCenter.shared.reloadAllTimelines()
  }
}

extension WatchStore: WCSessionDelegate {
  nonisolated func session(
    _ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?
  ) {
    let context = session.receivedApplicationContext
    Task { @MainActor in
      if !context.isEmpty { self.receive(context) }
      if self.payload == nil || WatchData.isStale(self.payload!) { self.requestSync() }
    }
  }

  nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    Task { @MainActor in self.receive(applicationContext) }
  }

  nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
    guard session.isReachable else { return }
    Task { @MainActor in
      if self.payload == nil || !self.overrides.isEmpty { self.requestSync() }
    }
  }
}
