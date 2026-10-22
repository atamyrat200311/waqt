import CoreLocation
import SwiftUI
import WatchKit

/// Compass heading from the watch's magnetometer (Series 5 and later, SE,
/// Ultra). True north when location access is granted, magnetic otherwise.
@MainActor
final class HeadingModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  @Published var heading: Double?
  let available = CLLocationManager.headingAvailable()
  private let manager = CLLocationManager()

  override init() {
    super.init()
    manager.delegate = self
    manager.headingFilter = 1
  }

  func start() {
    guard available else { return }
    if manager.authorizationStatus == .notDetermined { manager.requestWhenInUseAuthorization() }
    manager.startUpdatingHeading()
  }

  func stop() { manager.stopUpdatingHeading() }

  nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    let value = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    Task { @MainActor in self.heading = value }
  }
}

struct QiblaView: View {
  @EnvironmentObject private var store: WatchStore
  @StateObject private var compass = HeadingModel()
  @State private var wasFacing = false

  var body: some View {
    let bearing = store.payload?.qibla ?? 0
    let heading = compass.heading
    // Angle of the Qibla on screen: 0 = straight ahead (top of the watch).
    let relative = heading.map { normalized(bearing - $0) } ?? bearing
    let facing = heading != nil && (relative <= 5 || relative >= 355)

    VStack(spacing: 4) {
      ZStack {
        // Dial turns with the wrist so N stays north.
        ZStack {
          Circle().stroke(Color.white.opacity(0.14), lineWidth: 1.5)
          ForEach(0..<36, id: \.self) { i in
            Capsule()
              .fill(i % 9 == 0 ? Color.wInk : Color.white.opacity(0.3))
              .frame(width: i % 9 == 0 ? 2 : 1, height: i % 9 == 0 ? 8 : 4)
              .offset(y: -62)
              .rotationEffect(.degrees(Double(i) * 10))
          }
          Text("N")
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(Color.wBrass)
            .offset(y: -48)
        }
        .rotationEffect(.degrees(-(heading ?? 0)))

        // Arrow to the Kaaba.
        VStack(spacing: 2) {
          Image(systemName: "cube.fill")
            .font(.system(size: 16))
            .foregroundStyle(facing ? Color.wBrass : Color.wInk)
          Image(systemName: "arrowtriangle.up.fill")
            .font(.system(size: 22))
            .foregroundStyle(facing ? Color.wBrass : Color.wMint)
          Rectangle()
            .fill(facing ? Color.wBrass : Color.wMint)
            .frame(width: 3, height: 26)
          Spacer().frame(height: 52)
        }
        .rotationEffect(.degrees(relative))
        .animation(.easeOut(duration: 0.25), value: relative)

        Circle().fill(facing ? Color.wBrass : Color.wInk).frame(width: 8, height: 8)
      }
      .frame(width: 136, height: 136)
      .accessibilityHidden(true)

      Text(caption(heading: heading, facing: facing, bearing: bearing))
        .font(.footnote.weight(facing ? .semibold : .regular))
        .foregroundStyle(facing ? Color.wBrass : Color.wInk)
        .multilineTextAlignment(.center)
        .lineLimit(3)
        .minimumScaleFactor(0.7)
    }
    .navigationTitle(store.t("qibla", "Qibla"))
    .containerBackground(Color.wHero.gradient, for: .navigation)
    .onAppear { compass.start() }
    .onDisappear { compass.stop() }
    .onChange(of: facing) { _, now in
      if now && !wasFacing { WKInterfaceDevice.current().play(.success) }
      wasFacing = now
    }
  }

  private func normalized(_ angle: Double) -> Double {
    let r = angle.truncatingRemainder(dividingBy: 360)
    return r < 0 ? r + 360 : r
  }

  private func caption(heading: Double?, facing: Bool, bearing: Double) -> String {
    let deg = "\(Int(bearing.rounded()))"
    guard compass.available else {
      return store.t("qiblaNoSensor", "No compass. The Qibla is %s° from true north.")
        .replacingOccurrences(of: "%s", with: deg)
    }
    if heading == nil {
      return store.t("qiblaFromNorth", "%s° from north").replacingOccurrences(of: "%s", with: deg)
    }
    return facing ? store.t("qiblaFacing", "You're facing the Qibla") : store.t("qiblaTurn", "Turn until the arrow points up")
  }
}
