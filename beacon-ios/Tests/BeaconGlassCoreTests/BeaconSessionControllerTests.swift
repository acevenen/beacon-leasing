import XCTest
@testable import BeaconGlassCore

/// Scripted fake for the DAT seam. Mirrors Sources/beacon-core-checks/main.swift
/// scenario-for-scenario — keep the two in sync.
final class FakeDriver: GlassesSessionDriving, @unchecked Sendable {
  private let lock = NSLock()
  private var regContinuations: [AsyncStream<RegistrationPhase>.Continuation] = []
  private var sessContinuations: [AsyncStream<SessionPhase>.Continuation] = []
  // Replayed to late subscribers — removes the push-before-subscribe race.
  private var lastReg: RegistrationPhase?
  private var lastSess: SessionPhase?
  private(set) var startRegistrationCalls = 0
  private(set) var createSessionCalls = 0
  var registrationError: Error?

  private func sync<T>(_ body: () -> T) -> T {
    lock.lock(); defer { lock.unlock() }
    return body()
  }

  func startRegistration() async throws {
    let err: Error? = sync { startRegistrationCalls += 1; return registrationError }
    if let err { throw err }
    push(registration: .registering)
    push(registration: .registered)
  }

  func registrationPhases() -> AsyncStream<RegistrationPhase> {
    AsyncStream { c in
      self.sync { if let last = self.lastReg { c.yield(last) }; self.regContinuations.append(c) }
    }
  }

  func createAndStartSession() async throws {
    // New session = fresh stream: the old session's terminal .stopped must not
    // leak into it (mirrors real SDK semantics).
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

final class BeaconSessionControllerTests: XCTestCase {

  /// Stream-based wait raced against a timeout — sees every transition (no
  /// missed transients) and can never block past the deadline.
  private func waitFor(
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

  private func expect(
    _ target: BeaconControllerState,
    on controller: BeaconSessionController,
    _ message: String = "",
    file: StaticString = #filePath, line: UInt = #line
  ) async {
    let ok = await waitFor(where: { $0 == target }, on: controller)
    XCTAssertTrue(ok, "Timed out waiting for \(target). \(message)", file: file, line: line)
  }

  func testHappyPathReachesLive() async {
    let driver = FakeDriver()
    let controller = BeaconSessionController(driver: driver)
    await controller.begin()

    driver.push(registration: .available)   // controller should call startRegistration
    await expect(.registered, on: controller)
    await expect(.connecting, on: controller)
    driver.push(session: .starting)
    driver.push(session: .started)
    await expect(.live, on: controller)

    XCTAssertEqual(driver.startRegistrationCalls, 1)
    XCTAssertEqual(driver.createSessionCalls, 1)
  }

  func testAlreadyRegisteredSkipsRegistrationCall() async {
    let driver = FakeDriver()
    let controller = BeaconSessionController(driver: driver)
    await controller.begin()

    driver.push(registration: .registered)  // e.g. registered on a prior run
    await expect(.connecting, on: controller)
    driver.push(session: .started)
    await expect(.live, on: controller)

    XCTAssertEqual(driver.startRegistrationCalls, 0, "must not re-register")
    XCTAssertEqual(driver.createSessionCalls, 1)
  }

  func testPausedHoldsAndNeverRestarts() async {
    let driver = FakeDriver()
    let controller = BeaconSessionController(driver: driver)
    await controller.begin()
    driver.push(registration: .registered)
    await expect(.connecting, on: controller)
    driver.push(session: .started)
    await expect(.live, on: controller)

    driver.push(session: .paused)
    await expect(.pausedByDevice, on: controller)

    // DAT rule: no new session while paused — even if someone taps restart.
    await controller.restart()
    try? await Task.sleep(nanoseconds: 100_000_000)
    XCTAssertEqual(driver.createSessionCalls, 1, "restart during pause is forbidden")

    // Device resumes on its own.
    driver.push(session: .started)
    await expect(.live, on: controller)
    XCTAssertEqual(driver.createSessionCalls, 1, "resume must reuse the session")
  }

  func testStoppedIsTerminalAndRestartCreatesNewSession() async {
    let driver = FakeDriver()
    let controller = BeaconSessionController(driver: driver)
    await controller.begin()
    driver.push(registration: .registered)
    await expect(.connecting, on: controller)
    driver.push(session: .started)
    await expect(.live, on: controller)

    driver.push(session: .stopped)
    await expect(.ended, on: controller)

    // Restart is legal from `ended` and must create a NEW session.
    await controller.restart()
    driver.push(registration: .registered)
    await expect(.connecting, on: controller)
    driver.push(session: .started)
    await expect(.live, on: controller)
    XCTAssertEqual(driver.createSessionCalls, 2)
  }

  func testRegistrationUnavailableFails() async {
    let driver = FakeDriver()
    let controller = BeaconSessionController(driver: driver)
    await controller.begin()

    driver.push(registration: .unavailable)
    let sawFailure = await waitFor(
      where: { if case .failed = $0 { return true }; return false }, on: controller)
    XCTAssertTrue(sawFailure, "unavailable registration must surface as failed")
    XCTAssertEqual(driver.createSessionCalls, 0, "no session without registration")
  }

  func testBeginIsIdempotentWhileDriving() async {
    let driver = FakeDriver()
    let controller = BeaconSessionController(driver: driver)
    await controller.begin()
    driver.push(registration: .registered)
    await expect(.connecting, on: controller)

    // Second begin while connecting must not double-drive.
    await controller.begin()
    driver.push(session: .started)
    await expect(.live, on: controller)
    XCTAssertEqual(driver.createSessionCalls, 1)
  }
}
