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

    // ── Palette plumbing ───────────────────────────────────────────────────────
    // A host app sets this once (via `.sliderPalette(_:)`) to theme the label and
    // value-ticker colors across *every* slider consistently. The gradient stays a
    // per-call choice. Defaults mirror SwiftUI's semantic colors, so anything read
    // before injection looks exactly like the system default.
public struct SliderPalette: Sendable {
    public var labelColor: Color   // field labels
    public var valueColor: Color   // value tickers
    public var accent: Color  // toggle tint
    public var textentryfill: Color
    public var strokeborder: Color

    public init(
        labelColor: Color = .primary,
        valueColor: Color = .secondary,
        accent: Color = .accentColor,
        textentryfill: Color = .primary,
        strokeborder: Color = .accentColor
    ) {
        self.labelColor = labelColor
        self.valueColor = valueColor
        self.accent = accent
        self.textentryfill = textentryfill
        self.strokeborder = strokeborder
    }

    public static let `default` = SliderPalette()
}

private struct SliderPaletteKey: EnvironmentKey {
    static let defaultValue = SliderPalette.default
}

extension EnvironmentValues {
        // Named `sliderPalette` (not `palette`) so it can't clash with a host app
        // that also extends EnvironmentValues with its own `\.palette`.
    public var sliderPalette: SliderPalette {
        get { self[SliderPaletteKey.self] }
        set { self[SliderPaletteKey.self] = newValue }
    }
}

extension View {
        // The single knob a host app uses to theme all sliders at once.
    public func sliderPalette(_ palette: SliderPalette) -> some View {
        environment(\.sliderPalette, palette)
    }
}
