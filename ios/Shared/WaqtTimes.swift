// Prayer-time payload shared by the iPhone widgets, the Apple Watch app and
// its complications. Written by lib/features/widgets/domain/widget_payload.dart
// (home-screen widgets, 7 days) and lib/features/watch/domain/watch_payload.dart
// (watch, 30 days + extras). Everything time-dependent — next prayer, open
// window, countdown — is derived here from the stored times.

import Foundation

let waqtAppGroup = "group.tm.ofis.waqt"
let waqtWidgetKey = "waqt_widget"
let waqtPrayerIds = ["fajr", "dhuhr", "asr", "maghrib", "isha"]

struct WDay: Codable {
  let d: String
  let hijri: String
  let t: [Int]
  let sunrise: Int
  let m: [String]
}

struct WStrings: Codable {
  let next: String
  let remaining: String?
  let todayRecord: String?
  let `in`: String
  let inAfter: String
  let h: String
  let m: String
  let windowOpen: String
  let mark: String
  let marked: String
}

struct WPayload: Codable {
  let v: Int
  let place: String
  let sunrise: String?
  let names: [String]
  let s: WStrings
  let days: [WDay]

  // Apple Watch extras (lib/features/watch/domain/watch_payload.dart);
  // absent from the home-screen widget payload.
  let lang: String?
  let today: String?
  /// Qibla bearing, degrees clockwise from true north.
  let qibla: Double?
  let streak: Int?
  let adhkarDay: String?
  let adhkar: [String: [String: Int]]?
  let w: [String: String]?

  /// Reads the JSON the app stored under [key] in the shared App Group.
  static func load(key: String = waqtWidgetKey) -> WPayload? {
    guard let json = UserDefaults(suiteName: waqtAppGroup)?.string(forKey: key) else { return nil }
    return decode(json)
  }

  static func decode(_ json: String) -> WPayload? {
    guard let data = json.data(using: .utf8),
      let p = try? JSONDecoder().decode(WPayload.self, from: data),
      !p.days.isEmpty, p.names.count == 5
    else { return nil }
    return p
  }

  /// Instants where the visible state changes (prayer times and sunrise).
  var boundaries: [Date] {
    days.flatMap { d in (d.t + [d.sunrise]).map { Date(timeIntervalSince1970: TimeInterval($0)) } }
  }
}

/// What to show at one instant.
struct Snapshot {
  let dayIndex: Int
  /// Prayer whose window is open, if any.
  let current: Int?
  /// Prayer index for the next event, or nil when the next event is sunrise.
  let next: Int?
  let nextName: String
  let nextAt: Date
  /// Start of the window the countdown runs in (for the lock-screen bar).
  let since: Date
  let marks: [String]
  let day: WDay

  init(_ p: WPayload, at now: Date) {
    let n = Int(now.timeIntervalSince1970)
    var idx = 0
    for (i, d) in p.days.enumerated() where d.t[0] <= n { idx = i }
    let day = p.days[idx]
    let nextFajr = idx + 1 < p.days.count ? p.days[idx + 1].t[0] : day.t[4] + 6 * 3600
    let ends = [day.sunrise, day.t[2], day.t[3], day.t[4], nextFajr]
    var current: Int?
    if n >= day.t[0] {
      for i in 0..<5 where n >= day.t[i] && n < ends[i] { current = i }
    }
    var next: Int? = 0
    var nextName = p.names[0]
    var nextAt = nextFajr
    var previous = day.t[0]
    outer: for i in idx..<p.days.count {
      var events: [(time: Int, name: String, prayer: Int?)] =
        (0..<5).map { (time: p.days[i].t[$0], name: p.names[$0], prayer: $0) }
      events.append((time: p.days[i].sunrise, name: p.sunrise ?? "Sunrise", prayer: nil))
      events.sort { $0.time < $1.time }
      for event in events {
        if event.time > n {
          next = event.prayer
          nextName = event.name
          nextAt = event.time
          break outer
        }
        previous = event.time
      }
    }
    self.dayIndex = idx
    self.current = current
    self.next = next
    self.nextName = nextName
    self.nextAt = Date(timeIntervalSince1970: TimeInterval(nextAt))
    self.since = Date(timeIntervalSince1970: TimeInterval(previous))
    // Marks are only known for the day the app last wrote (index 0).
    self.marks = idx == 0 ? day.m : Array(repeating: "", count: 5)
    self.day = day
  }

  func countdown(_ s: WStrings, now: Date) -> String {
    let total = max(0, Int(ceil(nextAt.timeIntervalSince(now) / 60)))
    let h = total / 60
    let m = total % 60
    return h > 0 ? "\(h)\(s.h) \(m)\(s.m)" : "\(m)\(s.m)"
  }

  func inCountdown(_ s: WStrings, now: Date) -> String {
    [s.in.isEmpty ? nil : s.in, countdown(s, now: now) + (s.inAfter.isEmpty ? "" : " \(s.inAfter)")]
      .compactMap { $0 }.joined(separator: " ")
  }
}
