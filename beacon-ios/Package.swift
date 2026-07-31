// swift-tools-version: 5.9
// BeaconGlassCore — pure-Swift session/registration state machine for the
// BEACON iOS companion app. No MWDAT imports here: this package must build
// and test on any Mac with only Command Line Tools, so the DAT-touching
// adapter lives in App/ and is compiled by the Xcode app target instead.
import PackageDescription

let package = Package(
  name: "BeaconGlassCore",
  platforms: [.iOS(.v16), .macOS(.v13)],
  products: [
    .library(name: "BeaconGlassCore", targets: ["BeaconGlassCore"])
  ],
  targets: [
    .target(name: "BeaconGlassCore"),
    // XCTest suite — runs under Xcode (`swift test` needs XCTest, absent in CLT)
    .testTarget(name: "BeaconGlassCoreTests", dependencies: ["BeaconGlassCore"]),
    // CLT-friendly check runner — `swift run beacon-core-checks` verifies the
    // same lifecycle rules on a bare Mac with no Xcode installed
    .executableTarget(name: "beacon-core-checks", dependencies: ["BeaconGlassCore"]),
  ]
)
