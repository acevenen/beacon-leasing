// BeaconSessionController — the registration → connect → session slice as a
// testable state machine. Mirrors the DAT SDK's observed states (the device
// owns transitions; the app only reacts) so the DAT adapter is a thin mapping.
//
// DAT rules encoded here (from Meta's session-lifecycle guidance):
//  - Never restart while the device reports `paused`; wait for started/stopped.
//  - `stopped` is terminal: a NEW session must be created to go live again.
//  - Registration must reach `.registered` before any session is created.

import Foundation

// MARK: - Phases (mirror DAT SDK states)

/// Mirrors MWDATCore.RegistrationState.
public enum RegistrationPhase: Equatable, Sendable {
  case unavailable
  case available
  case registering
  case registered
}

/// Mirrors MWDATCore DeviceSession states.
public enum SessionPhase: Equatable, Sendable {
  case idle
  case starting
  case started
  case paused
  case stopping
  case stopped
}

// MARK: - Driver seam

/// The seam where MWDATCore plugs in. The production implementation
/// (App/DATSessionDriver.swift) wraps Wearables.shared; tests use a fake.
public protocol GlassesSessionDriving: Sendable {
  /// Kicks off registration (deeplinks to Meta AI in production).
  func startRegistration() async throws
  /// Stream of registration phases, current value first.
  func registrationPhases() -> AsyncStream<RegistrationPhase>
  /// Creates a fresh device session and starts it. Called at most once per
  /// live attempt; a new call is only legal after `stopped`.
  func createAndStartSession() async throws
  /// Stream of session phases for the most recently created session.
  func sessionPhases() -> AsyncStream<SessionPhase>
}

// MARK: - Controller state

public enum BeaconControllerState: Equatable, Sendable {
  case idle
  case registering
  case registered
  case connecting          // session created, waiting for `.started`
  case live                // session `.started`
  case pausedByDevice      // device suspended us; do NOT restart
  case ended               // session `.stopped` (terminal; restart() allowed)
  case failed(String)
}

// MARK: - Controller

public actor BeaconSessionController {
  private let driver: any GlassesSessionDriving
  private var driveTask: Task<Void, Never>?

  public private(set) var state: BeaconControllerState = .idle {
    didSet { continuations.values.forEach { $0.yield(state) } }
  }
  private var continuations: [UUID: AsyncStream<BeaconControllerState>.Continuation] = [:]

  public init(driver: any GlassesSessionDriving) {
    self.driver = driver
  }

  /// Observe controller state; yields the current state immediately.
  public func states() -> AsyncStream<BeaconControllerState> {
    AsyncStream { continuation in
      let id = UUID()
      continuation.yield(state)
      continuations[id] = continuation
      continuation.onTermination = { _ in
        Task { await self.removeContinuation(id) }
      }
    }
  }

  private func removeContinuation(_ id: UUID) {
    continuations[id] = nil
  }

  /// Begin the full slice: register → wait for `.registered` → create+start
  /// session → wait for `.started`. Safe to call once; ignored while a drive
  /// is already in flight or live.
  public func begin() {
    switch state {
    case .idle, .ended, .failed:
      break // allowed entry points
    default:
      return // already driving, live, or paused — never double-drive
    }
    state = .registering
    driveTask = Task { await drive() }
  }

  /// Restart after a terminal `ended`/`failed`. No-op from any other state
  /// (in particular: never restarts from `pausedByDevice`).
  public func restart() {
    guard state == .ended || isFailed else { return }
    begin()
  }

  private var isFailed: Bool {
    if case .failed = state { return true }
    return false
  }

  private func drive() async {
    // Phase 1 — registration.
    do {
      var needsStart = true
      for await phase in driver.registrationPhases() {
        switch phase {
        case .registered:
          state = .registered
          needsStart = false
        case .available where needsStart:
          needsStart = false
          try await driver.startRegistration()
        case .registering:
          state = .registering
        case .unavailable:
          state = .failed("Registration unavailable — is the Meta AI app installed and Developer Mode on?")
          return
        default:
          break
        }
        if state == .registered { break }
      }
    } catch {
      state = .failed("Registration failed: \(error)")
      return
    }
    guard state == .registered else {
      state = .failed("Registration stream ended before reaching registered")
      return
    }

    // Phase 2 — session. The device owns transitions from here.
    do {
      state = .connecting
      try await driver.createAndStartSession()
    } catch {
      state = .failed("Could not start device session: \(error)")
      return
    }

    for await phase in driver.sessionPhases() {
      switch phase {
      case .started:
        state = .live
      case .paused:
        // Hold. Deliberately no restart here — device may resume on its own.
        state = .pausedByDevice
      case .stopped:
        // Terminal: resources released; a fresh session is required.
        state = .ended
        return
      case .idle, .starting, .stopping:
        break
      }
    }
    // Stream ended without a terminal state — treat as ended.
    if state != .ended { state = .ended }
  }
}
