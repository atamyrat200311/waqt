// Storage shared by the Waqt watch app and its complications (App Group
// "group.tm.ofis.waqt" on the watch). The phone's payload arrives through
// WatchConnectivity (WatchStore); marks made on the watch are kept here as
// overrides until the phone acknowledges them.

import Foundation
import SwiftUI

let watchPayloadKey = "waqt_watch"
let watchOverridesKey = "waqt_watch_overrides"
let watchAckKey = "waqt_watch_ack"

/// A mark made on the watch that the phone has not confirmed yet.
struct MarkOverride: Codable, Equatable {
  let day: String
  /// Index into the five prayers (fajr … isha).
  let prayer: Int
  /// "onTime" | "congregation" | "late" | "" (cleared).
  let status: String
  /// Epoch milliseconds; also the event id sent to the phone.
  let at: Int64

  /// The widget payload's coarse state for this override.
  var mark: String { status.isEmpty ? "" : "done" }
}

enum WatchData {
  static var defaults: UserDefaults { UserDefaults(suiteName: waqtAppGroup) ?? .standard }

  static func payload() -> WPayload? { WPayload.load(key: watchPayloadKey) }

  static func overrides() -> [MarkOverride] {
    guard let data = defaults.data(forKey: watchOverridesKey) else { return [] }
    return (try? JSONDecoder().decode([MarkOverride].self, from: data)) ?? []
  }

  static func save(overrides: [MarkOverride]) {
    defaults.set(try? JSONEncoder().encode(overrides), forKey: watchOverridesKey)
  }

  /// Marks for one day: the phone's (known only for the payload's today)
  /// with the watch's pending overrides on top.
  static func marks(for day: WDay, in p: WPayload, overrides: [MarkOverride]) -> [String] {
    var m = day.d == (p.today ?? p.days.first?.d) ? day.m : Array(repeating: "", count: 5)
    for o in overrides.sorted(by: { $0.at < $1.at }) where o.day == day.d && (0..<5).contains(o.prayer) {
      m[o.prayer] = o.mark
    }
    return m
  }

  /// The payload's days run out: the phone app has not been opened for a month.
  static func isStale(_ p: WPayload, now: Date = Date()) -> Bool {
    guard let last = p.days.last else { return true }
    return Int(now.timeIntervalSince1970) > last.t[4] + 6 * 3600
  }
}

// MARK: - Look

extension Color {
  /// Dark-theme tokens (the watch is always dark).
  static let wHero = Color(red: 0x14 / 255, green: 0x3F / 255, blue: 0x32 / 255)
  static let wHeroDeep = Color(red: 0x0A / 255, green: 0x24 / 255, blue: 0x1C / 255)
  static let wInk = Color(red: 0xF0 / 255, green: 0xEC / 255, blue: 0xE3 / 255)
  static let wMuted = Color(red: 0xA3 / 255, green: 0xAF / 255, blue: 0xA8 / 255)
  static let wMint = Color(red: 0x6C / 255, green: 0xC9 / 255, blue: 0xA1 / 255)
  static let wBrass = Color(red: 0xE0 / 255, green: 0xBD / 255, blue: 0x78 / 255)
}

/// SF Symbol for a prayer index (nil = sunrise).
func prayerSymbol(_ index: Int?) -> String {
  switch index {
  case 0: "sunrise.fill"
  case 1: "sun.max.fill"
  case 2: "sun.haze.fill"
  case 3: "sunset.fill"
  case 4: "moon.stars.fill"
  default: "sun.horizon.fill"
  }
}

private let hhmmFormatter: DateFormatter = {
  let f = DateFormatter()
  f.dateFormat = "HH:mm"
  f.locale = Locale(identifier: "en_US_POSIX")
  return f
}()

func hhmm(_ date: Date) -> String { hhmmFormatter.string(from: date) }
func hhmm(epoch: Int) -> String { hhmm(Date(timeIntervalSince1970: TimeInterval(epoch))) }
