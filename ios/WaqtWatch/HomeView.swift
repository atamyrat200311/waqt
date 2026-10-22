import SwiftUI

/// The prayer to mark in the sheet.
struct MarkTarget: Identifiable {
  let day: String
  let prayer: Int
  let name: String
  let time: Date
  let mark: String
  var id: String { "\(day)-\(prayer)" }
}

struct HomeView: View {
  @EnvironmentObject private var store: WatchStore
  @State private var marking: MarkTarget?

  var body: some View {
    TimelineView(.everyMinute) { context in
      if let p = store.payload {
        PrayerList(payload: p, now: context.date, marking: $marking)
      } else {
        SyncHintView()
      }
    }
    .navigationTitle("Waqt")
    .containerBackground(Color.wHero.gradient, for: .navigation)
    .sheet(item: $marking) { MarkSheet(target: $0) }
  }
}

private struct PrayerList: View {
  @EnvironmentObject private var store: WatchStore
  let payload: WPayload
  let now: Date
  @Binding var marking: MarkTarget?

  var body: some View {
    let s = Snapshot(payload, at: now)
    let marks = store.marks(for: s.day)
    let done = marks.filter { $0 == "done" }.count
    List {
      HeroView(payload: payload, snapshot: s, marks: marks, now: now, marking: $marking)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 6, trailing: 4))

      if WatchData.isStale(payload, now: now) {
        Label(store.openPhoneHint, systemImage: "iphone")
          .font(.footnote)
          .foregroundStyle(Color.wBrass)
      }

      Section {
        ForEach(events(s.day), id: \.self) { slot in
          if let i = slot {
            prayerRow(i, snapshot: s, marks: marks)
          } else {
            sunriseRow(s.day)
          }
        }
      } header: {
        Text("\(store.t("today", "Today")) · \(s.day.hijri)")
      }

      Section {
        HStack(spacing: 8) {
          Gauge(value: Double(done), in: 0...5) {
            EmptyView()
          } currentValueLabel: {
            Text("\(done)").font(.system(.body, design: .rounded).weight(.semibold))
          }
          .gaugeStyle(.accessoryCircularCapacity)
          .tint(Color.wBrass)
          .scaleEffect(0.8)
          .frame(width: 40, height: 40)
          VStack(alignment: .leading, spacing: 2) {
            Text(
              store.t("prayedOf", "{done} of {total} prayed")
                .replacingOccurrences(of: "{done}", with: "\(done)")
                .replacingOccurrences(of: "{total}", with: "5")
            )
            .font(.footnote.weight(.semibold))
            if let streak = payload.w?["streak"], !streak.isEmpty {
              Label(streak, systemImage: "flame.fill")
                .font(.caption2)
                .foregroundStyle(Color.wBrass)
            }
          }
        }
      }

      Section {
        NavigationLink(value: Route.tasbih) {
          Label(store.t("tasbih", "Tasbih"), systemImage: "circle.hexagongrid.fill")
        }
        NavigationLink(value: Route.qibla) {
          Label(store.t("qibla", "Qibla"), systemImage: "location.north.line.fill")
        }
        NavigationLink(value: Route.adhkar("morning")) {
          Label(store.t("morning", "Morning adhkar"), systemImage: "sun.max.fill")
        }
        NavigationLink(value: Route.adhkar("evening")) {
          Label(store.t("evening", "Evening adhkar"), systemImage: "moon.stars.fill")
        }
        NavigationLink(value: Route.week) {
          Label(store.t("timetable", "Timetable"), systemImage: "calendar")
        }
      } footer: {
        Label(payload.place, systemImage: "location.fill")
          .font(.caption2)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(.top, 6)
      }
    }
  }

  /// Fajr, sunrise (nil), Dhuhr … Isha in time order.
  private func events(_ day: WDay) -> [Int?] { [0, nil, 1, 2, 3, 4] }

  private func prayerRow(_ i: Int, snapshot s: Snapshot, marks: [String]) -> some View {
    let time = Date(timeIntervalSince1970: TimeInterval(s.day.t[i]))
    let started = now >= time
    let isNow = s.current == i
    return Button {
      marking = MarkTarget(day: s.day.d, prayer: i, name: payload.names[i], time: time, mark: marks[i])
    } label: {
      HStack(spacing: 8) {
        Image(systemName: prayerSymbol(i))
          .font(.system(size: 13))
          .foregroundStyle(isNow ? Color.wBrass : Color.wMuted)
          .frame(width: 18)
        Text(payload.names[i])
          .font(.body.weight(isNow ? .semibold : .regular))
          .lineLimit(1)
          .minimumScaleFactor(0.8)
        Spacer(minLength: 4)
        Text(hhmm(time))
          .font(.system(.body, design: .rounded))
          .monospacedDigit()
          .foregroundStyle(started ? Color.wInk : Color.wMuted)
        StatusMark(mark: marks[i], isNow: isNow, started: started)
      }
    }
    .disabled(!started)
    .listRowBackground(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(isNow ? Color.wMint.opacity(0.22) : Color.white.opacity(0.08))
    )
    .accessibilityElement(children: .combine)
    .accessibilityValue(statusLabel(marks[i], isNow: isNow))
  }

  private func sunriseRow(_ day: WDay) -> some View {
    HStack(spacing: 8) {
      Image(systemName: "sun.horizon.fill")
        .font(.system(size: 13))
        .foregroundStyle(Color.wMuted)
        .frame(width: 18)
      Text(payload.sunrise ?? "Sunrise").foregroundStyle(Color.wMuted).lineLimit(1)
      Spacer(minLength: 4)
      Text(hhmm(epoch: day.sunrise))
        .font(.system(.body, design: .rounded))
        .monospacedDigit()
        .foregroundStyle(Color.wMuted)
      Color.clear.frame(width: 20, height: 20)
    }
    .listRowBackground(Color.clear)
  }

  private func statusLabel(_ mark: String, isNow: Bool) -> String {
    switch mark {
    case "done": store.t("done", "marked")
    case "missed": store.t("missed", "missed")
    case "excused": store.t("excused", "excused")
    default: isNow ? store.t("now", "now") : ""
    }
  }
}

/// States differ by shape, as on the phone: done = filled brass check,
/// now = brass ring with a dot, passed = plain ring, upcoming = dashed.
struct StatusMark: View {
  let mark: String
  let isNow: Bool
  let started: Bool

  var body: some View {
    ZStack {
      switch mark {
      case "done":
        Circle().fill(Color.wBrass)
        Image(systemName: "checkmark").font(.system(size: 10, weight: .heavy)).foregroundStyle(Color.wHeroDeep)
      case "missed":
        Circle().stroke(Color.wMuted, lineWidth: 1.5)
        Image(systemName: "xmark").font(.system(size: 9, weight: .bold)).foregroundStyle(Color.wMuted)
      case "excused":
        Circle().stroke(Color.wMuted, lineWidth: 1.5)
        Image(systemName: "minus").font(.system(size: 9, weight: .bold)).foregroundStyle(Color.wMuted)
      default:
        if isNow {
          Circle().stroke(Color.wBrass, lineWidth: 2)
          Circle().fill(Color.wBrass).frame(width: 7, height: 7)
        } else if started {
          Circle().stroke(Color.wMuted, lineWidth: 1.5)
        } else {
          Circle().stroke(Color.wMuted.opacity(0.74), style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
        }
      }
    }
    .frame(width: 20, height: 20)
  }
}

private struct HeroView: View {
  @EnvironmentObject private var store: WatchStore
  @Environment(\.isLuminanceReduced) private var dimmed
  let payload: WPayload
  let snapshot: Snapshot
  let marks: [String]
  let now: Date
  @Binding var marking: MarkTarget?

  var body: some View {
    let s = snapshot
    VStack(alignment: .leading, spacing: 3) {
      HStack(spacing: 5) {
        Image(systemName: prayerSymbol(s.next))
          .foregroundStyle(Color.wBrass)
        Text(payload.s.next.uppercased())
          .font(.system(size: 11, weight: .bold))
          .tracking(0.8)
          .foregroundStyle(Color.wMuted)
        Spacer()
        Text(s.nextName)
          .font(.system(.headline, design: .serif))
          .lineLimit(1)
          .minimumScaleFactor(0.7)
      }
      Text(hhmm(s.nextAt))
        .font(.system(size: 44, weight: .semibold, design: .rounded))
        .monospacedDigit()
        .minimumScaleFactor(0.7)
        .lineLimit(1)
      Text(timerInterval: now...max(now, s.nextAt), countsDown: true)
        .font(.system(.title3, design: .rounded).weight(.medium))
        .monospacedDigit()
        .foregroundStyle(Color.wMint)
      ProgressView(timerInterval: s.since...max(s.since.addingTimeInterval(1), s.nextAt), countsDown: false) {
        EmptyView()
      } currentValueLabel: {
        EmptyView()
      }
      .tint(Color.wBrass)
      .opacity(dimmed ? 0.5 : 1)

      if let c = s.current, marks[c].isEmpty, !dimmed {
        Button {
          marking = MarkTarget(
            day: s.day.d, prayer: c, name: payload.names[c],
            time: Date(timeIntervalSince1970: TimeInterval(s.day.t[c])), mark: "")
        } label: {
          Label(payload.s.mark, systemImage: "checkmark.circle.fill")
            .font(.footnote.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.wBrass)
        .foregroundStyle(Color.wHeroDeep)
        .padding(.top, 4)
      }
    }
    .accessibilityElement(children: .combine)
  }
}

struct MarkSheet: View {
  @EnvironmentObject private var store: WatchStore
  @Environment(\.dismiss) private var dismiss
  let target: MarkTarget

  var body: some View {
    ScrollView {
      VStack(spacing: 8) {
        Image(systemName: prayerSymbol(target.prayer))
          .font(.title3)
          .foregroundStyle(Color.wBrass)
        Text(target.name)
          .font(.system(.title3, design: .serif))
        Text(hhmm(target.time))
          .font(.system(.footnote, design: .rounded))
          .monospacedDigit()
          .foregroundStyle(Color.wMuted)
          .padding(.bottom, 4)
        option("onTime", fallback: "Prayed on time", icon: "checkmark.circle.fill", prominent: true)
        option("congregation", fallback: "In congregation", icon: "person.3.fill")
        option("late", fallback: "Prayed late", icon: "clock.fill")
        if !target.mark.isEmpty {
          Button(role: .destructive) {
            store.mark(day: target.day, prayer: target.prayer, status: "")
            dismiss()
          } label: {
            Label(store.t("clear", "Clear mark"), systemImage: "arrow.uturn.backward")
          }
        }
      }
    }
    .containerBackground(Color.wHero.gradient, for: .navigation)
  }

  private func option(_ status: String, fallback: String, icon: String, prominent: Bool = false) -> some View {
    Button {
      store.mark(day: target.day, prayer: target.prayer, status: status)
      dismiss()
    } label: {
      Label(store.t(status, fallback), systemImage: icon)
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(2)
        .minimumScaleFactor(0.8)
    }
    .tint(prominent ? Color.wBrass : nil)
  }
}

struct SyncHintView: View {
  @EnvironmentObject private var store: WatchStore

  var body: some View {
    VStack(spacing: 10) {
      Image(systemName: "iphone.and.arrow.forward")
        .font(.system(size: 30))
        .foregroundStyle(Color.wMint)
      Text(store.openPhoneHint)
        .font(.footnote)
        .multilineTextAlignment(.center)
      ProgressView()
    }
    .padding()
    .onAppear { store.requestSync() }
  }
}

/// The next seven days of times (Timetable).
struct WeekView: View {
  @EnvironmentObject private var store: WatchStore

  var body: some View {
    Group {
      if let p = store.payload {
        let start = Snapshot(p, at: Date()).dayIndex
        List {
          ForEach(Array(p.days.dropFirst(start).prefix(7)), id: \.d) { day in
            VStack(alignment: .leading, spacing: 6) {
              HStack {
                Text(weekday(day.d)).font(.headline)
                Spacer()
                Text(day.hijri).font(.caption2).foregroundStyle(Color.wMuted).lineLimit(1)
              }
              Grid(horizontalSpacing: 4, verticalSpacing: 2) {
                GridRow {
                  ForEach(0..<5, id: \.self) { i in
                    Image(systemName: prayerSymbol(i)).font(.system(size: 9)).foregroundStyle(Color.wBrass)
                  }
                }
                GridRow {
                  ForEach(0..<5, id: \.self) { i in
                    Text(hhmm(epoch: day.t[i]))
                      .font(.system(size: 12, design: .rounded))
                      .monospacedDigit()
                      .lineLimit(1)
                      .minimumScaleFactor(0.7)
                  }
                }
              }
            }
            .padding(.vertical, 2)
          }
        }
      } else {
        SyncHintView()
      }
    }
    .navigationTitle(store.t("timetable", "Timetable"))
    .containerBackground(Color.wHero.gradient, for: .navigation)
  }

  private func weekday(_ key: String) -> String {
    let parse = DateFormatter()
    parse.dateFormat = "yyyy-MM-dd"
    parse.locale = Locale(identifier: "en_US_POSIX")
    guard let date = parse.date(from: key) else { return key }
    let out = DateFormatter()
    out.locale = Locale(identifier: store.language)
    out.setLocalizedDateFormatFromTemplate("EEE d MMM")
    return out.string(from: date)
  }
}
