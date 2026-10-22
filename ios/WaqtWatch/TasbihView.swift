import SwiftUI
import WatchKit

/// One phrase of a tasbih sequence (mirrors lib/features/tools/domain/tasbih.dart).
struct Dhikr: Hashable {
  let translit: String
  let arabic: String
  let target: Int
}

enum TasbihMode: String, CaseIterable, Identifiable {
  case preset, istighfar, tahlil, salawat, tasbihHamd
  var id: String { rawValue }

  var phases: [Dhikr] {
    switch self {
    case .preset:
      [
        Dhikr(translit: "SubḥānAllāh", arabic: "سُبْحَانَ اللَّهِ", target: 33),
        Dhikr(translit: "Alḥamdulillāh", arabic: "الْحَمْدُ لِلَّهِ", target: 33),
        Dhikr(translit: "Allāhu akbar", arabic: "اللَّهُ أَكْبَرُ", target: 34),
      ]
    case .istighfar: [Dhikr(translit: "Astaghfirullāh", arabic: "أَسْتَغْفِرُ اللَّهَ", target: 100)]
    case .tahlil: [Dhikr(translit: "Lā ilāha illā-llāh", arabic: "لَا إِلَٰهَ إِلَّا اللَّهُ", target: 100)]
    case .salawat:
      [Dhikr(translit: "Allāhumma ṣalli ʿalā Muḥammad", arabic: "اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ", target: 100)]
    case .tasbihHamd:
      [Dhikr(translit: "SubḥānAllāhi wa biḥamdih", arabic: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ", target: 100)]
    }
  }

  var goal: Int { phases.reduce(0) { $0 + $1.target } }

  /// Session label stored on the phone ("preset" like the phone's counter).
  var label: String { self == .preset ? "preset" : phases[0].translit }
}

struct TasbihView: View {
  @EnvironmentObject private var store: WatchStore
  @AppStorage("tasbih.mode") private var modeRaw = TasbihMode.preset.rawValue
  @AppStorage("tasbih.phase") private var phase = 0
  @AppStorage("tasbih.count") private var count = 0
  @AppStorage("tasbih.complete") private var complete = false
  @State private var crown = 0.0
  @State private var lastCrownStep = 0
  @State private var picking = false
  @State private var bump = false

  private var mode: TasbihMode { TasbihMode(rawValue: modeRaw) ?? .preset }
  private var current: Dhikr { mode.phases[min(phase, mode.phases.count - 1)] }
  private var total: Int {
    complete ? mode.goal : mode.phases.prefix(phase).reduce(0) { $0 + $1.target } + count
  }

  var body: some View {
    Button(action: tap) {
      ZStack {
        Circle()
          .stroke(Color.white.opacity(0.12), lineWidth: 8)
        Circle()
          .trim(from: 0, to: complete ? 1 : CGFloat(count) / CGFloat(current.target))
          .stroke(Color.wBrass, style: StrokeStyle(lineWidth: 8, lineCap: .round))
          .rotationEffect(.degrees(-90))
          .animation(.easeOut(duration: 0.2), value: count)
        VStack(spacing: 2) {
          Text(current.arabic)
            .font(.custom("Amiri", size: 17))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundStyle(Color.wBrass)
          Text(complete ? "\(mode.goal)" : "\(count)")
            .font(.system(size: 46, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .contentTransition(.numericText())
            .scaleEffect(bump ? 1.08 : 1)
          Text(subtitle)
            .font(.caption2)
            .foregroundStyle(Color.wMuted)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        }
        .padding(.horizontal, 16)
      }
      .padding(6)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .modifier(PrimaryHandGesture())
    .focusable(true)
    .digitalCrownRotation(
      $crown, from: -1_000_000, through: 1_000_000, by: 1, sensitivity: .low,
      isContinuous: false, isHapticFeedbackEnabled: false)
    .onChange(of: crown) { _, value in
      // Each forward detent of the crown counts once.
      let step = Int(value.rounded(.down))
      if step > lastCrownStep { tap() }
      lastCrownStep = step
    }
    .accessibilityLabel(current.translit)
    .accessibilityValue(subtitle)
    .accessibilityAddTraits(.isButton)
    .navigationTitle(store.t("tasbih", "Tasbih"))
    .containerBackground(Color.wHero.gradient, for: .navigation)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button { picking = true } label: { Image(systemName: "list.bullet") }
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button(action: reset) { Image(systemName: "arrow.counterclockwise") }
          .disabled(total == 0)
          .accessibilityLabel(store.t("reset", "Reset"))
      }
    }
    .sheet(isPresented: $picking) { modePicker }
  }

  private var subtitle: String {
    if complete {
      return store.t("tasbihComplete", "Complete · %s").replacingOccurrences(of: "%s", with: "\(mode.goal)")
    }
    let of = store.t("tasbihOf", "of %s").replacingOccurrences(of: "%s", with: "\(current.target)")
    return "\(current.translit) · \(of)"
  }

  private func tap() {
    let device = WKInterfaceDevice.current()
    if complete {
      restart()
      device.play(.start)
      return
    }
    count += 1
    if count >= current.target {
      if phase >= mode.phases.count - 1 {
        complete = true
        device.play(.success)
        store.saveTasbih(phrase: mode.label, count: mode.goal, goal: mode.goal)
      } else {
        phase += 1
        count = 0
        device.play(.directionUp)
      }
    } else {
      device.play(.click)
    }
    withAnimation(.spring(response: 0.18, dampingFraction: 0.5)) { bump = true }
    withAnimation(.easeOut(duration: 0.15).delay(0.1)) { bump = false }
  }

  private func reset() {
    if !complete { store.saveTasbih(phrase: mode.label, count: total, goal: mode.goal) }
    restart()
    WKInterfaceDevice.current().play(.retry)
  }

  private func restart() {
    phase = 0
    count = 0
    complete = false
  }

  private var modePicker: some View {
    List(TasbihMode.allCases) { m in
      Button {
        if m != mode {
          if !complete { store.saveTasbih(phrase: mode.label, count: total, goal: mode.goal) }
          modeRaw = m.rawValue
          restart()
        }
        picking = false
      } label: {
        VStack(alignment: .leading, spacing: 2) {
          Text(m == .preset ? store.t("tasbihPreset", "After-prayer tasbih (33 · 33 · 34)") : m.phases[0].translit)
            .font(.footnote.weight(.semibold))
          Text(m == .preset ? "سُبْحَانَ اللَّهِ · الْحَمْدُ لِلَّهِ · اللَّهُ أَكْبَرُ" : m.phases[0].arabic)
            .font(.custom("Amiri", size: 15))
            .foregroundStyle(Color.wBrass)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
          if m != .preset {
            Text(store.t("dhikrFree", "Single dhikr · 100")).font(.caption2).foregroundStyle(Color.wMuted)
          }
        }
      }
      .listRowBackground(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(m == mode ? Color.wMint.opacity(0.25) : Color.white.opacity(0.08)))
    }
    .containerBackground(Color.wHero.gradient, for: .navigation)
  }
}

/// Double tap (Apple Watch Series 9 / Ultra 2 and later) counts, like a tap.
struct PrimaryHandGesture: ViewModifier {
  func body(content: Content) -> some View {
    if #available(watchOS 11.0, *) {
      content.handGestureShortcut(.primaryAction)
    } else {
      content
    }
  }
}
