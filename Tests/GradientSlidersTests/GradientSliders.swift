import Testing
import SwiftUI
import FancySliders

// A plain (non-@testable) import: this only compiles if the public API surface
// is actually reachable by a real consumer. If either slider stops being
// `public` — or loses a public init — this test fails to build.
@MainActor
@Test func publicSlidersAreConstructable() {
    _ = UnipolarSlider(
        "Volume",
        value: .constant(50),
        in: 0...100,
        color: .blue,
        typeface: .rounded
    )

    _ = BipolarSlider(
        "Temperature",
        value: .constant(0),
        in: -100...100,
        leftColor: .blue,
        rightColor: .red,
        typeface: .mono
    )
}
