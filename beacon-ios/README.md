# beacon-ios — the DAT-native slice
The Track-B companion to BEACON GLASS: an iPhone app that registers with Meta AI, connects to the glasses, runs a device session, and pushes match cards to the lens via the `MWDATDisplay` DSL. (Track A — the web app in `../glass.html` — is the shipping demo path; this is the camera/mic/Display-DSL future.)

Built protocol-first so the risky part is verified before Xcode ever enters the room. We test state machines like Anduril tests flight software, then vibe the UI on top.

## Layout

| Path | What | Verifiable today? |
|---|---|---|
| `Sources/BeaconGlassCore/` | Pure-Swift session state machine (`BeaconSessionController`) + the `GlassesSessionDriving` seam. Zero MWDAT imports. | ✅ `swift run beacon-core-checks` — no Xcode needed |
| `Sources/beacon-core-checks/` | XCTest-free check runner (CLT ships no XCTest). 6 scenarios: happy path, skip-if-registered, pause-never-restarts, stopped-is-terminal, unavailable-fails, idempotent begin. | ✅ same |
| `Tests/BeaconGlassCoreTests/` | The same scenarios as XCTest, for when Xcode exists. | needs Xcode |
| `App/` | The thin real-SDK layer: `DATSessionDriver` (wraps `Wearables.shared`), `BeaconGlassApp` (SwiftUI shell), `BeaconDisplayRenderer` (in-lens match cards), `InfoPlist-additions.xml`. | needs Xcode + glasses |

## Run the checks (any Mac, CLT only — no Xcode, no SwiftPM needed)
```bash
sed '/import BeaconGlassCore/d' Sources/beacon-core-checks/main.swift > /tmp/checks-src-main.swift && mkdir -p /tmp/checks-src && mv /tmp/checks-src-main.swift /tmp/checks-src/main.swift && xcrun swiftc -swift-version 5 Sources/BeaconGlassCore/BeaconSessionController.swift /tmp/checks-src/main.swift -o /tmp/beacon-checks && /tmp/beacon-checks
```
Compiles in ~1s, runs 22 checks across 6 lifecycle scenarios. Last verified: **ALL CHECKS PASSED** (2026-07-30). `swift run beacon-core-checks` also works in a normal terminal; the direct-swiftc line exists because sandboxed environments can stall SwiftPM, and because iCloud evicts files mid-build in ~/Documents. Ask us how we know.

## Assemble the app (needs Xcode 15+, iOS 17 target)
1. New iOS App project `BeaconGlass`, bundle id **without hyphens** (Wearables rule), e.g. `com.acevenen.beaconglass`.
2. Add local package `beacon-ios/` (BeaconGlassCore) + SPM package `https://github.com/facebook/meta-wearables-dat-ios` (0.8.x → MWDATCore, MWDATDisplay).
3. Drop the four `App/` files into the target; merge `InfoPlist-additions.xml` into Info.plist (URL scheme `beaconglass`, `MetaAppID=0` for dev, `DAMEnabled=true`).
4. On the test iPhone: Meta AI app installed, per-device Developer Mode ON (Settings → Your glasses → Developer Mode — it silently turns off after firmware updates).
5. Run on device → tap **Connect glasses** → approve in Meta AI → session goes LIVE → `BeaconDisplayRenderer.show(match:)` puts a unit card in the lens.

## SDK 0.8.0 traps already handled in this code
Early `AutoDeviceSelector` creation (async-populate race) · synchronous `start()` · never-restart-while-paused · new-session-after-stopped · listener tokens retained · no SwiftUI import next to `MWDATDisplay` (name collisions) · `fb-viewapp` in `LSApplicationQueriesSchemes`.

Full platform reference: `../../META-WEARABLES-PLAYBOOK.md`.
