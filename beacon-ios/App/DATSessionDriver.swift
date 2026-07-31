// DATSessionDriver — the ONLY file that touches MWDATCore. Wraps the real SDK
// behind BeaconGlassCore.GlassesSessionDriving so the state machine (and its
// checks) never depend on hardware. Compiled by the Xcode app target, not the
// package — add MWDATCore via SPM: https://github.com/facebook/meta-wearables-dat-ios
//
// SDK 0.8.0 notes encoded here (from Meta's skills + changelog):
//  - AutoDeviceSelector populates from devicesStream() ASYNCHRONOUSLY: create it
//    early (at init), not immediately before createSession, or you can throw
//    DeviceSessionError.noEligibleDevice on a race.
//  - DeviceSession.start() is synchronous in 0.8.0.
//  - Keep listener tokens alive — dropping an AnyListenerToken silently
//    unsubscribes.

import Foundation
import MWDATCore
import BeaconGlassCore

final class DATSessionDriver: GlassesSessionDriving, @unchecked Sendable {
  private let wearables: WearablesInterface
  private let selector: AutoDeviceSelector   // created early on purpose (see header)
  private var session: DeviceSession?
  private let lock = NSLock()

  init(wearables: WearablesInterface = Wearables.shared) {
    self.wearables = wearables
    self.selector = AutoDeviceSelector(wearables: wearables)
  }

  func startRegistration() async throws {
    try await wearables.startRegistration()
  }

  func registrationPhases() -> AsyncStream<RegistrationPhase> {
    AsyncStream { continuation in
      continuation.yield(Self.map(wearables.registrationState)) // current value first
      let task = Task {
        for await state in wearables.registrationStateStream() {
          continuation.yield(Self.map(state))
        }
        continuation.finish()
      }
      continuation.onTermination = { _ in task.cancel() }
    }
  }

  func createAndStartSession() async throws {
    let s = try wearables.createSession(deviceSelector: selector)
    lock.lock(); session = s; lock.unlock()
    try s.start() // synchronous in 0.8.0
  }

  func sessionPhases() -> AsyncStream<SessionPhase> {
    AsyncStream { continuation in
      lock.lock(); let s = session; lock.unlock()
      guard let s else { continuation.finish(); return }
      let task = Task {
        for await state in s.stateStream() {
          continuation.yield(Self.map(state))
        }
        continuation.finish()
      }
      continuation.onTermination = { _ in task.cancel() }
    }
  }

  // MARK: - State mapping

  private static func map(_ state: RegistrationState) -> RegistrationPhase {
    switch state {
    case .registered:  return .registered
    case .registering: return .registering
    case .available:   return .available
    case .unavailable: return .unavailable
    @unknown default:  return .unavailable
    }
  }

  private static func map(_ state: DeviceSessionState) -> SessionPhase {
    switch state {
    case .idle:     return .idle
    case .starting: return .starting
    case .started:  return .started
    case .paused:   return .paused
    case .stopping: return .stopping
    case .stopped:  return .stopped
    @unknown default: return .stopped
    }
  }
}
