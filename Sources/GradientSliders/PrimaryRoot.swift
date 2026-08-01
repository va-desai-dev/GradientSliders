    //
    //  PrimaryRoot.swift
    //  FancySliders
    //
    //  Created by Vedant A. Desai on 7/30/26.
    //
import SwiftUI

    // ── Typography plumbing ────────────────────────────────────────────────────
    // Makes the active Typography role set reachable from any view via
    // @Environment(\.typography). Each public slider injects its own set from the
    // `typeface` chosen at the call site, so its sub-labels stay in sync. Default
    // is the standard (SF) face so anything read before injection still renders.
@MainActor
private struct TypographyKey: @preconcurrency EnvironmentKey {
    static var defaultValue = Typography(face: .standard)
}

extension EnvironmentValues {
    var typography: Typography {
        get { self[TypographyKey.self] }
        set { self[TypographyKey.self] = newValue }
    }
}
