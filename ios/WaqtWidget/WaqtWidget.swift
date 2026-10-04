// Waqt home-screen and lock-screen widgets (WidgetKit).
//
// Reads the JSON written by lib/features/widgets/domain/widget_payload.dart
// (key "waqt_widget") from the App Group "group.tm.ofis.waqt" via home_widget.
// Everything else (next prayer, open window, countdown) is derived here from
// the 7 days of prayer times, so the widget stays right without the app.
//
// Setup (Xcode, once): File ▸ New ▸ Target ▸ Widget Extension, name "WaqtWidget",
// no Live Activity / configuration intent; delete the generated Swift file and add
// this folder's files to the target; add the App Group capability
// (group.tm.ofis.waqt) to both Runner and WaqtWidget. See CLAUDE.md "Widgets".

import SwiftUI
import WidgetKit

private let appGroup = "group.tm.ofis.waqt"
private let dataKey = "waqt_widget"
private let prayerIds = ["fajr", "dhuhr", "asr", "maghrib", "isha"]

// MARK: - Payload

struct WDay: Decodable {
  let d: String
  let hijri: String
  let t: [Int]
  let sunrise: Int
  let m: [String]
}

struct WStrings: Decodable {
  let next: String
  let `in`: String
  let inAfter: String
  let h: String
  let m: String
  let windowOpen: String
  let mark: String
  let marked: String
}

struct WPayload: Decodable {
  let v: Int
  let place: String
  let names: [String]
  let s: WStrings
  let days: [WDay]

  static func load() -> WPayload? {
    guard let json = UserDefaults(suiteName: appGroup)?.string(forKey: dataKey),
      let data = json.data(using: .utf8)
    else { return nil }
    return try? JSONDecoder().decode(WPayload.self, from: data)
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
  let next: Int
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
    var next = 0
    var nextAt = nextFajr
    var previous = day.t[0]
    outer: for i in idx..<p.days.count {
      for k in 0..<5 {
        if p.days[i].t[k] > n {
          next = k
          nextAt = p.days[i].t[k]
          break outer
        }
        previous = p.days[i].t[k]
      }
    }
    self.dayIndex = idx
    self.current = current
    self.next = next
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

  /// Tap target: open the mark sheet for the open, unmarked prayer.
  var url: URL {
    if let c = current, marks[c].isEmpty {
      return URL(string: "waqt://today?homeWidget&mark=\(prayerIds[c])&day=\(day.d)")!
    }
    return URL(string: "waqt://today?homeWidget")!
  }
}

private func hhmm(_ epoch: Int) -> String {
  let f = DateFormatter()
  f.dateFormat = "HH:mm"
  f.locale = Locale(identifier: "en_US_POSIX")
  return f.string(from: Date(timeIntervalSince1970: TimeInterval(epoch)))
}

// MARK: - Colours (design tokens)

private extension Color {
  init(light: UInt32, dark: UInt32) {
    self.init(
      UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light) })
  }
  static let wBg = Color(light: 0xF7F4EE, dark: 0x121D18)
  static let wInk = Color(light: 0x14201B, dark: 0xF0ECE3)
  static let wMuted = Color(light: 0x56635C, dark: 0xA3AFA8)
  static let wAccent = Color(light: 0x0F4C3A, dark: 0x6CC9A1)
  static let wHero = Color(light: 0x0F4C3A, dark: 0x143F32)
  static let wOnHero = Color(light: 0xF7F4EE, dark: 0xF0ECE3)
  static let wBrass = Color(light: 0xB88A3E, dark: 0xE0BD78)
}

private extension UIColor {
  convenience init(hex: UInt32) {
    self.init(
      red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
      blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
  }
}

private func serif(_ size: CGFloat) -> Font { .system(size: size, design: .serif) }

// MARK: - Timeline

struct Entry: TimelineEntry {
  let date: Date
  let payload: WPayload?
}

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> Entry { Entry(date: Date(), payload: nil) }

  func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
    completion(Entry(date: Date(), payload: WPayload.load()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let payload = WPayload.load()
    let now = Date()
    let minute = Date(timeIntervalSince1970: floor(now.timeIntervalSince1970 / 60) * 60)
    // One entry per minute for 3 hours (countdown), plus every state change for a day.
    var dates = (0..<180).map { minute.addingTimeInterval(TimeInterval($0 * 60)) }
    if let p = payload {
      dates += p.boundaries.filter { $0 > now && $0 < now.addingTimeInterval(24 * 3600) }
    }
    let entries = Set(dates).sorted().map { Entry(date: $0, payload: payload) }
    completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(3 * 3600))))
  }
}

// MARK: - Views

struct SmallView: View {
  let entry: Entry
  var body: some View {
    if let p = entry.payload {
      let s = Snapshot(p, at: entry.date)
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 6) {
          Circle().fill(Color.wBrass).frame(width: 7, height: 7)
            .overlay(Circle().stroke(Color.wBrass.opacity(0.3), lineWidth: 3))
          Text(p.s.next.uppercased()).font(.system(size: 11, weight: .bold)).kerning(0.9)
            .foregroundColor(Color.wOnHero.opacity(0.74))
        }
        Text(p.names[s.next]).font(serif(26)).foregroundColor(.wOnHero).padding(.top, 8)
        Text(hhmm(Int(s.nextAt.timeIntervalSince1970))).font(.system(size: 14))
          .foregroundColor(Color.wOnHero.opacity(0.74)).padding(.top, 3)
        Spacer(minLength: 0)
        Text(s.countdown(p.s, now: entry.date)).font(serif(32)).kerning(-1)
          .foregroundColor(.wOnHero).minimumScaleFactor(0.6).lineLimit(1)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .widgetURL(s.url)
    } else {
      Text("Waqt").font(serif(24)).foregroundColor(.wOnHero)
    }
  }
}

struct MediumView: View {
  let entry: Entry
  var body: some View {
    if let p = entry.payload {
      let s = Snapshot(p, at: entry.date)
      VStack(spacing: 0) {
        HStack(alignment: .firstTextBaseline) {
          Text("\(p.place) · \(s.day.hijri)").font(.system(size: 13, weight: .semibold))
            .foregroundColor(.wMuted).lineLimit(1)
          Spacer()
          Text("\(p.names[s.next]) \(s.inCountdown(p.s, now: entry.date))")
            .font(.system(size: 13, weight: .bold)).foregroundColor(.wAccent).lineLimit(1)
        }
        .padding(.horizontal, 4)
        Spacer(minLength: 0)
        HStack(spacing: 4) {
          ForEach(0..<5, id: \.self) { i in
            let highlighted = i == s.next && s.dayIndex == 0 && s.nextAt.timeIntervalSince(entry.date) < 24 * 3600
            VStack(spacing: 4) {
              mark(i, s: s, onHero: highlighted)
              Text(p.names[i]).font(.system(size: 12, weight: highlighted ? .bold : .semibold))
                .lineLimit(1).minimumScaleFactor(0.7)
              Text(hhmm(s.day.t[i])).font(serif(17))
            }
            .foregroundColor(highlighted ? .wOnHero : (s.marks[i] == "done" || i == s.current ? .wInk : .wMuted))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(highlighted ? Color.wHero : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
          }
        }
      }
      .widgetURL(s.url)
    } else {
      Text("Waqt").font(serif(24)).foregroundColor(.wInk)
    }
  }

  @ViewBuilder
  func mark(_ i: Int, s: Snapshot, onHero: Bool) -> some View {
    if s.marks[i] == "done" {
      Circle().fill(Color.wBrass).frame(width: 18, height: 18)
        .overlay(Image(systemName: "checkmark").font(.system(size: 9, weight: .heavy)).foregroundColor(.wHero))
    } else if i == s.current {
      Circle().stroke(Color.wBrass, lineWidth: 2).frame(width: 18, height: 18)
    } else {
      Circle().stroke(style: StrokeStyle(lineWidth: 1.5, dash: [2.5, 2.5]))
        .foregroundColor(onHero ? Color.wOnHero.opacity(0.7) : Color.wMuted.opacity(0.7))
        .frame(width: 18, height: 18)
    }
  }
}

@available(iOSApplicationExtension 16.0, *)
struct LockRectangularView: View {
  let entry: Entry
  var body: some View {
    if let p = entry.payload {
      let s = Snapshot(p, at: entry.date)
      let total = s.nextAt.timeIntervalSince(s.since)
      let done = total > 0 ? min(1, max(0, entry.date.timeIntervalSince(s.since) / total)) : 0
      VStack(alignment: .leading, spacing: 1) {
        HStack(spacing: 6) {
          Text(p.names[s.next]).font(.system(size: 15, weight: .bold))
          Text(hhmm(Int(s.nextAt.timeIntervalSince1970))).font(.system(size: 15, weight: .medium)).opacity(0.8)
        }
        Text(s.inCountdown(p.s, now: entry.date)).font(.system(size: 20, weight: .bold)).lineLimit(1)
          .minimumScaleFactor(0.7)
        ProgressView(value: done).tint(.primary)
      }
      .widgetURL(s.url)
    } else {
      Text("Waqt")
    }
  }
}

struct WaqtWidgetEntryView: View {
  @Environment(\.widgetFamily) var family
  let entry: Entry

  var body: some View {
    switch family {
    case .systemSmall:
      SmallView(entry: entry).widgetBackground(.wHero)
    case .systemMedium:
      MediumView(entry: entry).widgetBackground(.wBg)
    default:
      if #available(iOSApplicationExtension 16.0, *) {
        LockRectangularView(entry: entry).widgetBackground(.clear)
      } else {
        MediumView(entry: entry).widgetBackground(.wBg)
      }
    }
  }
}

private extension View {
  /// iOS 17 needs containerBackground; earlier versions use a plain background.
  @ViewBuilder
  func widgetBackground(_ color: Color) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      containerBackground(for: .widget) { color }
    } else {
      padding().background(color)
    }
  }
}

@main
struct WaqtWidget: Widget {
  let kind = "WaqtWidget"

  private var families: [WidgetFamily] {
    if #available(iOSApplicationExtension 16.0, *) {
      return [.systemSmall, .systemMedium, .accessoryRectangular]
    }
    return [.systemSmall, .systemMedium]
  }

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      WaqtWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Waqt")
    .description("Next prayer and today's times.")
    .supportedFamilies(families)
  }
}
