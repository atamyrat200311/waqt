import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct PrayerActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    let prayerName: String
    /// Stable, non-localized id used to choose the matching SF Symbol.
    /// Optional so an activity created by an older build still decodes.
    let prayerId: String?
    let place: String
    let target: Date
  }

  let title: String
}
