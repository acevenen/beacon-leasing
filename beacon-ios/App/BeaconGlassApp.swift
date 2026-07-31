// BeaconGlassApp — minimal SwiftUI shell for the DAT slice:
// configure → register → connect → session live, driven by BeaconSessionController.
// Add to an Xcode iOS App target (iOS 17+) with BeaconGlassCore (local package)
// and meta-wearables-dat-ios (SPM) as dependencies.

import SwiftUI
import MWDATCore
import BeaconGlassCore

@main
struct BeaconGlassApp: App {
  init() {
    do { try Wearables.configure() }        // once, at launch — before anything else
    catch { assertionFailure("Wearables SDK failed to configure: \(error)") }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .onOpenURL { url in                  // Meta AI registration callback
          Task { _ = try? await Wearables.shared.handleUrl(url) }
        }
    }
  }
}

struct ContentView: View {
  @State private var controllerState: BeaconControllerState = .idle
  @State private var controller = BeaconSessionController(driver: DATSessionDriver())

  var body: some View {
    VStack(spacing: 16) {
      Text("BEACON").font(.system(.title, design: .monospaced)).bold()
      Text(label(for: controllerState))
        .font(.system(.body, design: .monospaced))
        .foregroundStyle(color(for: controllerState))

      switch controllerState {
      case .idle, .ended, .failed:
        Button("Connect glasses") {
          Task { await controller.begin() }
        }
        .buttonStyle(.borderedProminent)
      case .pausedByDevice:
        Text("Device paused the session — waiting for it to resume…")
          .font(.footnote).foregroundStyle(.secondary)
      default:
        ProgressView()
      }
    }
    .padding()
    .task {
      for await state in await controller.states() {
        controllerState = state
      }
    }
  }

  private func label(for state: BeaconControllerState) -> String {
    switch state {
    case .idle:            return "READY"
    case .registering:     return "REGISTERING WITH META AI…"
    case .registered:      return "REGISTERED"
    case .connecting:      return "CONNECTING TO GLASSES…"
    case .live:            return "SESSION LIVE"
    case .pausedByDevice:  return "PAUSED BY DEVICE"
    case .ended:           return "SESSION ENDED"
    case .failed(let why): return "FAILED: \(why)"
    }
  }

  private func color(for state: BeaconControllerState) -> Color {
    switch state {
    case .live: return .green
    case .failed: return .red
    case .pausedByDevice: return .orange
    default: return .primary
    }
  }
}
