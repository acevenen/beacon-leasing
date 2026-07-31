// BeaconDisplayRenderer — pushes BEACON match cards to the Ray-Ban Display lens
// via the MWDATDisplay declarative DSL (DAT-native track; the web app in
// glass.html is the other track — they do not share a runtime).
//
// DSL rules encoded here (from Meta's display-access skill):
//  - Every send() FULLY REPLACES on-lens content AND all handlers. Navigation
//    is re-sending a new root. There is no diffing.
//  - Exactly one root per send, and it must be FlexBox (or VideoPlayer).
//  - addDisplay only works on a .started session; wait for DisplayState
//    .started via statePublisher before the first send.
//  - This file deliberately does NOT import SwiftUI: MWDATDisplay has its own
//    Text/Button/Image types and importing both makes every name ambiguous.

import Foundation
import MWDATCore
import MWDATDisplay

struct DisplayMatch {
  let unit: String        // "2402"
  let plan: String        // "2x2D TWO BED CORNER"
  let rent: String        // "$5,170/MO"
  let availability: String// "READY NOW"
  let route: [String]     // ["ELEVATOR BANK A", "FLOOR 24", "RIGHT OFF ELEVATOR"]
}

final class BeaconDisplayRenderer {
  private var display: Display?
  private var stateToken: AnyListenerToken?  // dropping the token kills the listener
  private var ready = false
  private var pendingMatch: DisplayMatch?

  /// Attach to a session that has already reached `.started`.
  func attach(to session: DeviceSession) throws {
    let display = try session.addDisplay()
    self.display = display
    stateToken = display.statePublisher.listen { [weak self] state in
      guard let self else { return }
      if state == .started {
        self.ready = true
        if let match = self.pendingMatch {
          self.pendingMatch = nil
          self.show(match: match)
        }
      }
    }
    display.start() // synchronous in 0.8.0
  }

  /// Render one match card in-lens. Queued if the display isn't started yet.
  func show(match: DisplayMatch) {
    guard ready, let display else { pendingMatch = match; return }
    let card = FlexBox(direction: .column) {
      MWDATDisplay.Text("BEACON › \(match.availability)")
      MWDATDisplay.Text(match.unit)
      MWDATDisplay.Text(match.plan)
      MWDATDisplay.Text(match.rent)
      MWDATDisplay.Button("ROUTE") { [weak self] in
        self?.show(routeFor: match)  // navigation = send a new root
      }
    }
    display.send(card)
  }

  /// Route view — replaces the card (and its handlers) entirely.
  private func show(routeFor match: DisplayMatch) {
    guard let display else { return }
    let route = FlexBox(direction: .column) {
      MWDATDisplay.Text("GUIDE TO \(match.unit)")
      for step in match.route {
        MWDATDisplay.Text(step)
      }
      MWDATDisplay.Button("BACK") { [weak self] in
        self?.show(match: match)
      }
    }
    display.send(route)
  }

  func detach() {
    display?.stop()
    stateToken = nil
    display = nil
    ready = false
  }
}
