// Waqt watch-face complications and Smart Stack widgets (WidgetKit).
//
// Reads the payload the watch app stored (WatchData, key "waqt_watch") plus
// marks made on the watch. Countdowns and progress rings use WidgetKit's
// live timer views, so entries are only needed when the next prayer changes.

import SwiftUI
import WidgetKit

struct WEntry: TimelineEntry {
  let date: Date
  let payload: WPayload?
  let overrides: [MarkOverride]
  var relevance: TimelineEntryRelevance?

  var snapshot: Snapshot? { payload.map { Snapshot($0, at: date) } }

  var marks: [String] {
    guard let p = payload, let s = snapshot else { return Array(repeating: "", count: 5) }
    return WatchData.marks(for: s.day, in: p, overrides: overrides)
  }
}

struct WProvider: TimelineProvider {
  func placeholder(in context: Context) -> WEntry { WEntry(date: Date(), payload: nil, overrides: []) }

  func getSnapshot(in context: Context, completion: @escaping (WEntry) -> Void) {
    completion(WEntry(date: Date(), payload: WatchData.payload(), overrides: WatchData.overrides()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<WEntry>) -> Void) {
    let payload = WatchData.payload()
    let overrides = WatchData.overrides()
    let now = Date()
    var dates = [now]
    if let p = payload {
      dates += p.boundaries.filter { $0 > now && $0 < now.addingTimeInterval(36 * 3600) }
    }
    let entries = dates.sorted().map { date -> WEntry in
      var e = WEntry(date: date, payload: payload, overrides: overrides)
      // Smart Stack: rise as a prayer approaches and while its window is fresh.
      if let s = e.snapshot {
        let toNext = s.nextAt.timeIntervalSince(date)
        let sinceStart = date.timeIntervalSince(s.since)
        let score: Float = toNext < 30 * 60 ? 1 : (sinceStart < 20 * 60 ? 0.8 : 0.2)
        e.relevance = TimelineEntryRelevance(score: score, duration: min(toNext, 30 * 60))
      }
      return e
    }
    completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(12 * 3600))))
  }
}

private func strings(_ p: WPayload?, _ key: String, _ fallback: String) -> String {
  guard let s = p?.w?[key], !s.isEmpty else { return fallback }
  return s
}

// MARK: - Next prayer

struct NextPrayerView: View {
  @Environment(\.widgetFamily) private var family
  let entry: WEntry

  var body: some View {
    if let s = entry.snapshot, let p = entry.payload {
      switch family {
      case .accessoryCircular: circular(s)
      case .accessoryCorner: corner(s)
      case .accessoryInline: inline(s)
      default: rectangular(s, p)
      }
    } else {
      Image(systemName: "moon.stars.fill").widgetAccentable()
    }
  }

  private func range(_ s: Snapshot) -> ClosedRange<Date> {
    s.since...max(s.since.addingTimeInterval(1), s.nextAt)
  }

  private func circular(_ s: Snapshot) -> some View {
    ProgressView(timerInterval: range(s), countsDown: false) {
      EmptyView()
    } currentValueLabel: {
      VStack(spacing: 0) {
        Image(systemName: prayerSymbol(s.next)).font(.system(size: 12)).widgetAccentable()
        Text(hhmm(s.nextAt))
          .font(.system(size: 13, weight: .semibold, design: .rounded))
          .monospacedDigit()
          .minimumScaleFactor(0.6)
      }
    }
    .progressViewStyle(.circular)
    .widgetLabel(s.nextName)
  }

  private func corner(_ s: Snapshot) -> some View {
    Image(systemName: prayerSymbol(s.next))
      .font(.system(size: 20))
      .widgetAccentable()
      .widgetLabel {
        ProgressView(timerInterval: range(s), countsDown: false) {
          EmptyView()
        } currentValueLabel: {
          Text("\(s.nextName) \(hhmm(s.nextAt))")
        }
      }
  }

  private func inline(_ s: Snapshot) -> some View {
    Label("\(s.nextName) \(hhmm(s.nextAt))", systemImage: prayerSymbol(s.next))
  }

  private func rectangular(_ s: Snapshot, _ p: WPayload) -> some View {
    VStack(alignment: .leading, spacing: 1) {
      HStack(spacing: 4) {
        Image(systemName: prayerSymbol(s.next)).widgetAccentable()
        Text(s.nextName).font(.headline).widgetAccentable().lineLimit(1)
        Spacer(minLength: 0)
        Text(hhmm(s.nextAt))
          .font(.system(.headline, design: .rounded))
          .monospacedDigit()
      }
      Text(timerInterval: entry.date...max(entry.date, s.nextAt), countsDown: true)
        .font(.system(.title3, design: .rounded).weight(.semibold))
        .monospacedDigit()
        .lineLimit(1)
      ProgressView(timerInterval: range(s), countsDown: false) {
        EmptyView()
      } currentValueLabel: {
        EmptyView()
      }
      .tint(Color.wBrass)
      Text(p.place).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
    }
  }
}

struct NextPrayerWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "WaqtNextPrayer", provider: WProvider()) { entry in
      NextPrayerView(entry: entry)
        .containerBackground(Color.wHero.gradient, for: .widget)
        .widgetURL(URL(string: "waqtwatch://today"))
    }
    .configurationDisplayName("Waqt")
    .description("Next prayer and countdown")
    .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
  }
}

// MARK: - Today's prayers

struct TodayView: View {
  @Environment(\.widgetFamily) private var family
  let entry: WEntry

  var body: some View {
    let marks = entry.marks
    let done = marks.filter { $0 == "done" }.count
    switch family {
    case .accessoryCircular:
      Gauge(value: Double(done), in: 0...5) {
        Image(systemName: "checkmark")
      } currentValueLabel: {
        Text("\(done)/5").font(.system(size: 14, weight: .semibold, design: .rounded))
      }
      .gaugeStyle(.accessoryCircularCapacity)
      .tint(Color.wBrass)
    default:
      VStack(alignment: .leading, spacing: 4) {
        Text(
          strings(entry.payload, "prayedOf", "{done} of {total} prayed")
            .replacingOccurrences(of: "{done}", with: "\(done)")
            .replacingOccurrences(of: "{total}", with: "5")
        )
        .font(.headline)
        .widgetAccentable()
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        HStack(spacing: 5) {
          ForEach(0..<5, id: \.self) { i in
            let current = entry.snapshot?.current == i
            ZStack {
              if marks[i] == "done" {
                Circle().fill(Color.wBrass)
                Image(systemName: "checkmark").font(.system(size: 8, weight: .heavy)).foregroundStyle(Color.wHeroDeep)
              } else {
                Circle().stroke(current ? Color.wBrass : Color.secondary, lineWidth: current ? 2 : 1.2)
              }
            }
            .frame(width: 18, height: 18)
          }
        }
        if let s = entry.snapshot {
          Text("\(s.nextName) \(hhmm(s.nextAt))").font(.caption2).foregroundStyle(.secondary)
        }
      }
    }
  }
}

struct TodayWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "WaqtToday", provider: WProvider()) { entry in
      TodayView(entry: entry)
        .containerBackground(Color.wHero.gradient, for: .widget)
        .widgetURL(URL(string: "waqtwatch://today"))
    }
    .configurationDisplayName("Waqt · Today")
    .description("Prayers marked today")
    .supportedFamilies([.accessoryCircular, .accessoryRectangular])
  }
}

// MARK: - Launchers

struct LauncherView: View {
  @Environment(\.widgetFamily) private var family
  let symbol: String
  let label: String
  var rotation: Double = 0

  var body: some View {
    let icon = Image(systemName: symbol)
      .font(.system(size: family == .accessoryCorner ? 20 : 22, weight: .semibold))
      .rotationEffect(.degrees(rotation))
      .widgetAccentable()
    if family == .accessoryCorner {
      icon.widgetLabel(label)
    } else {
      ZStack {
        AccessoryWidgetBackground()
        icon
      }
      .widgetLabel(label)
    }
  }
}

struct TasbihWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "WaqtTasbih", provider: WProvider()) { entry in
      LauncherView(symbol: "circle.hexagongrid.fill", label: strings(entry.payload, "tasbih", "Tasbih"))
        .containerBackground(Color.wHero.gradient, for: .widget)
        .widgetURL(URL(string: "waqtwatch://tasbih"))
    }
    .configurationDisplayName("Waqt · Tasbih")
    .description("Open the tasbih counter")
    .supportedFamilies([.accessoryCircular, .accessoryCorner])
  }
}

struct QiblaWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "WaqtQibla", provider: WProvider()) { entry in
      // Static arrow at the Qibla bearing from north; tap for the live compass.
      LauncherView(
        symbol: "location.north.fill", label: strings(entry.payload, "qibla", "Qibla"),
        rotation: entry.payload?.qibla ?? 0)
        .containerBackground(Color.wHero.gradient, for: .widget)
        .widgetURL(URL(string: "waqtwatch://qibla"))
    }
    .configurationDisplayName("Waqt · Qibla")
    .description("Open the Qibla compass")
    .supportedFamilies([.accessoryCircular, .accessoryCorner])
  }
}

@main
struct WaqtWatchWidgets: WidgetBundle {
  var body: some Widget {
    NextPrayerWidget()
    TodayWidget()
    TasbihWidget()
    QiblaWidget()
  }
}
