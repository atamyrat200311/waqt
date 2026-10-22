import SwiftUI
import WatchKit

/// One item of assets/adhkar/adhkar.json (bundled into the watch app).
struct AdhkarItem: Decodable, Identifiable {
  let id: String
  let ar: String
  let translit: String?
  let text: [String: String]
  let count: Int
  let source: String?
}

enum AdhkarCatalog {
  private struct File: Decodable { let sets: [String: [AdhkarItem]] }

  static let sets: [String: [AdhkarItem]] = {
    guard let url = Bundle.main.url(forResource: "adhkar", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let file = try? JSONDecoder().decode(File.self, from: data)
    else { return [:] }
    return file.sets
  }()
}

struct AdhkarView: View {
  @EnvironmentObject private var store: WatchStore
  let set: String
  @State private var page: String?

  private var items: [AdhkarItem] { AdhkarCatalog.sets[set] ?? [] }

  var body: some View {
    let items = self.items
    let done = items.filter { store.adhkarCount(set: set, item: $0.id) >= $0.count }.count
    TabView(selection: $page) {
      ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
        AdhkarPage(set: set, item: item, index: index, total: items.count) {
          // Item finished: move on after a beat.
          let next = index + 1 < items.count ? items[index + 1].id : "done"
          Task {
            try? await Task.sleep(nanoseconds: 450_000_000)
            withAnimation { page = next }
          }
        }
        .tag(Optional(item.id))
      }
      VStack(spacing: 8) {
        Image(systemName: done == items.count ? "checkmark.seal.fill" : "circle.dashed")
          .font(.system(size: 34))
          .foregroundStyle(Color.wBrass)
        Text(done == items.count ? store.t("adhkarSetDone", "May Allah accept it from you.") : "\(done) / \(items.count)")
          .font(.system(.body, design: .serif))
          .multilineTextAlignment(.center)
      }
      .tag(Optional("done"))
    }
    .tabViewStyle(.verticalPage)
    .navigationTitle(set == "evening" ? store.t("evening", "Evening adhkar") : store.t("morning", "Morning adhkar"))
    .containerBackground(Color.wHero.gradient, for: .navigation)
    .onAppear {
      // Open at the first unfinished item.
      page = items.first { store.adhkarCount(set: set, item: $0.id) < $0.count }?.id ?? "done"
    }
    .onDisappear { store.flushAdhkar() }
  }
}

private struct AdhkarPage: View {
  @EnvironmentObject private var store: WatchStore
  let set: String
  let item: AdhkarItem
  let index: Int
  let total: Int
  let onFinished: () -> Void

  var body: some View {
    let count = store.adhkarCount(set: set, item: item.id)
    let finished = count >= item.count
    ScrollView {
      VStack(alignment: .leading, spacing: 8) {
        Text(
          store.t("posOf", "{pos} of {total}")
            .replacingOccurrences(of: "{pos}", with: "\(index + 1)")
            .replacingOccurrences(of: "{total}", with: "\(total)")
        )
        .font(.caption2.weight(.semibold))
        .foregroundStyle(Color.wMuted)

        Text(item.ar)
          .font(.custom("Amiri", size: item.ar.count > 60 ? 18 : 22))
          .lineSpacing(6)
          .multilineTextAlignment(.trailing)
          .environment(\.layoutDirection, .rightToLeft)
          .frame(maxWidth: .infinity, alignment: .trailing)

        if let meaning = item.text[store.language] ?? item.text["en"] {
          Text(meaning)
            .font(.footnote)
            .foregroundStyle(Color.wMuted)
        }
        if let source = item.source, !source.isEmpty {
          Text(source).font(.caption2).foregroundStyle(Color.wMuted.opacity(0.7))
        }

        Button {
          guard !finished else { return }
          let n = count + 1
          store.setAdhkar(set: set, item: item.id, count: n)
          if n >= item.count {
            WKInterfaceDevice.current().play(.success)
            onFinished()
          } else {
            WKInterfaceDevice.current().play(.click)
          }
        } label: {
          HStack {
            Image(systemName: finished ? "checkmark.circle.fill" : "hand.tap.fill")
            Text(finished ? store.t("adhkarComplete", "Complete") : "\(count) / \(item.count)")
              .monospacedDigit()
          }
          .frame(maxWidth: .infinity)
        }
        .tint(finished ? Color.wBrass : Color.wMint)
        .accessibilityHint(store.t("tapToCount", "Tap to count"))
        .padding(.top, 4)
      }
    }
  }
}
