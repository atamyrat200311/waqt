// Waqt for Apple Watch: prayer times and countdown, marking prayers, tasbih
// (tap, Digital Crown or double tap), Qibla compass, morning/evening adhkar
// and a week's timetable. Data comes from the iPhone app (30 days ahead),
// so everything works away from the phone.

import SwiftUI

@main
struct WaqtWatchApp: App {
  @StateObject private var store = WatchStore.shared
  @Environment(\.scenePhase) private var phase

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(store)
        .tint(.wMint)
    }
    .onChange(of: phase) { _, p in
      if p != .active { store.flushAdhkar() }
      if p == .active { store.requestSync() }
    }
  }
}

enum Route: Hashable {
  case tasbih, qibla, week
  case adhkar(String)
}

struct RootView: View {
  @EnvironmentObject private var store: WatchStore
  @State private var path: [Route] = []

  var body: some View {
    NavigationStack(path: $path) {
      HomeView()
        .navigationDestination(for: Route.self) { route in
          switch route {
          case .tasbih: TasbihView()
          case .qibla: QiblaView()
          case .week: WeekView()
          case .adhkar(let set): AdhkarView(set: set)
          }
        }
    }
    // Complications open the matching screen: waqtwatch://tasbih …
    .onOpenURL { url in
      switch url.host {
      case "tasbih": path = [.tasbih]
      case "qibla": path = [.qibla]
      case "adhkar": path = [.adhkar(url.pathComponents.last == "evening" ? "evening" : "morning")]
      default: path = []
      }
    }
  }
}
