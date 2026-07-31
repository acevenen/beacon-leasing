// beacon-core-checks — XCTest-free verification of BeaconSessionController.
// Exists because Command Line Tools ship no XCTest; `swift run beacon-core-checks`
// must pass on a bare Mac. Mirrors BeaconGlassCoreTests scenario-for-scenario.

import BeaconGlassCore
import Foundation

// MARK: - Scripted fake (same contract as the XCTest FakeDriver)

final class FakeDriver: GlassesSessionDriving, @unchecked Sendable {
  private let lock = NSLock()
  private var regContinuations: [AsyncStream<RegistrationPhase>.Continuation] = []
  private var sessContinuations: [AsyncStream<SessionPhase>.Continuation] = []
  // Replayed to late subscribers — mirrors the SDK exposing current state, and
  // removes the push-before-subscribe race between harness and drive task.
  private var lastReg: RegistrationPhase?
  private var lastSess: SessionPhase?
  private(set) var startRegistrationCalls = 0
  private(set) var createSessionCalls = 0

  // Synchronous locking helper — NSLock.lock() called directly inside an async
  // function is flagged by the compiler; nesting it in a sync method is fine.
  private func sync<T>(_ body: () -> T) -> T {
    lock.lock(); defer { lock.unlock() }
    return body()
  }

  func startRegistration() async throws {
    sync { startRegistrationCalls += 1 }
    push(registration: .registering)
    push(registration: .registered)
  }
  func registrationPhases() -> AsyncStream<RegistrationPhase> {
    AsyncStream { c in
      self.sync { if let last = self.lastReg { c.yield(last) }; self.regContinuations.append(c) }
    }
  }
  func createAndStartSession() async throws {
    // A new session gets a FRESH state stream — the previous session's terminal
    // .stopped must not leak into it (mirrors real SDK semantics).
    sync { createSessionCalls += 1; lastSess = nil; sessContinuations.removeAll() }
  }
  func sessionPhases() -> AsyncStream<SessionPhase> {
    AsyncStream { c in
      self.sync { if let last = self.lastSess { c.yield(last) }; self.sessContinuations.append(c) }
    }
  }
  func push(registration phase: RegistrationPhase) {
    let cs = sync { lastReg = phase; return regContinuations }
    cs.forEach { $0.yield(phase) }
  }
  func push(session phase: SessionPhase) {
    let cs = sync { lastSess = phase; return sessContinuations }
    cs.forEach { $0.yield(phase) }
  }
}

// MARK: - Tiny harness

var failures = 0
func check(_ name: String, _ condition: Bool) {
  if condition { print("  PASS \(name)") }
  else { failures += 1; print("  FAIL \(name)") }
}

// Stream-based wait raced against a timeout: the stream yields EVERY
// transition (so transient states like .registered are never missed), and the
// racing sleep guarantees we can never block past the deadline.
func waitFor(
  where match: @escaping @Sendable (BeaconControllerState) -> Bool,
  on controller: BeaconSessionController,
  timeout: TimeInterval = 2
) async -> Bool {
  await withTaskGroup(of: Bool.self) { group in
    group.addTask {
      for await state in await controller.states() where match(state) { return true }
      return false
    }
    group.addTask {
      try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
      return false
    }
    let first = await group.next() ?? false
    group.cancelAll()
    return first
  }
}

func waitFor(
  _ target: BeaconControllerState,
  on controller: BeaconSessionController,
  timeout: TimeInterval = 2
) async -> Bool {
  await waitFor(where: { $0 == target }, on: controller, timeout: timeout)
}

func waitForFailure(on controller: BeaconSessionController, timeout: TimeInterval = 2) async -> Bool {
  await waitFor(where: { if case .failed = $0 { return true }; return false }, on: controller, timeout: timeout)
}

// MARK: - Scenarios

await { () async in
  print("scenario: happy path reaches live")
  let driver = FakeDriver()
  let c = BeaconSessionController(driver: driver)
  await c.begin()
  driver.push(registration: .available)
  check("registered", await waitFor(.registered, on: c))
  check("connecting", await waitFor(.connecting, on: c))
  driver.push(session: .starting)
  driver.push(session: .started)
  check("live", await waitFor(.live, on: c))
  check("one registration call", driver.startRegistrationCalls == 1)
  check("one session created", driver.createSessionCalls == 1)
}()

await { () async in
  print("scenario: already registered skips registration call")
  let driver = FakeDriver()
  let c = BeaconSessionController(driver: driver)
  await c.begin()
  driver.push(registration: .registered)
  check("connecting", await waitFor(.connecting, on: c))
  driver.push(session: .started)
  check("live", await waitFor(.live, on: c))
  check("no re-registration", driver.startRegistrationCalls == 0)
}()

await { () async in
  print("scenario: paused holds — restart forbidden, resume reuses session")
  let driver = FakeDriver()
  let c = BeaconSessionController(driver: driver)
  await c.begin()
  driver.push(registration: .registered)
  _ = await waitFor(.connecting, on: c)
  driver.push(session: .started)
  _ = await waitFor(.live, on: c)
  driver.push(session: .paused)
  check("pausedByDevice", await waitFor(.pausedByDevice, on: c))
  await c.restart()
  try? await Task.sleep(nanoseconds: 100_000_000)
  check("restart during pause is a no-op", driver.createSessionCalls == 1)
  driver.push(session: .started)
  check("device-driven resume back to live", await waitFor(.live, on: c))
  check("resume reused the session", driver.createSessionCalls == 1)
}()

await { () async in
  print("scenario: stopped is terminal — restart creates a NEW session")
  let driver = FakeDriver()
  let c = BeaconSessionController(driver: driver)
  await c.begin()
  driver.push(registration: .registered)
  _ = await waitFor(.connecting, on: c)
  driver.push(session: .started)
  _ = await waitFor(.live, on: c)
  driver.push(session: .stopped)
  check("ended", await waitFor(.ended, on: c))
  await c.restart()
  driver.push(registration: .registered)
  check("reconnecting", await waitFor(.connecting, on: c))
  driver.push(session: .started)
  check("live again", await waitFor(.live, on: c))
  check("second session created", driver.createSessionCalls == 2)
}()

await { () async in
  print("scenario: registration unavailable surfaces as failure")
  let driver = FakeDriver()
  let c = BeaconSessionController(driver: driver)
  await c.begin()
  driver.push(registration: .unavailable)
  check("failed state reached", await waitForFailure(on: c))
  check("no session without registration", driver.createSessionCalls == 0)
}()

await { () async in
  print("scenario: begin is idempotent while driving")
  let driver = FakeDriver()
  let c = BeaconSessionController(driver: driver)
  await c.begin()
  driver.push(registration: .registered)
  _ = await waitFor(.connecting, on: c)
  await c.begin() // must not double-drive
  driver.push(session: .started)
  check("live", await waitFor(.live, on: c))
  check("single session despite double begin", driver.createSessionCalls == 1)
}()

print(failures == 0 ? "\nALL CHECKS PASSED" : "\n\(failures) CHECK(S) FAILED")
exit(failures == 0 ? 0 : 1)
