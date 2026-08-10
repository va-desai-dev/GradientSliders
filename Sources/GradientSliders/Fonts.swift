    //
    //  SliderLabels.swift
    //  FancySliders
    //
    //  Created by Vedant A. Desai on 7/30/26.
    //

import SwiftUI

struct Typography {
    let display: Font       // hero / brand moments (largeTitle-scale, blackest weight)
    let title: Font         // section titles      — replaces .title2.weight(.heavy)
    let heading: Font       // field labels         — replaces .title3.weight(.semibold)
    let headline: Font      // toggles / row leads  — replaces .headline.weight(.semibold)
    let body: Font          // running text
    let label: Font         // muted secondary labels — replaces .callout.weight(.medium)
    let subheadline: Font   // status lines         — replaces .subheadline.weight(.semibold)
    let caption: Font       // fine print
    let mono: Font          // numbers / metrics / data ("system-y" content stays legible)
}

extension Typography {
        // Build a full role set from a single typeface choice. Every role is derived
        // from the face's `design` (or, for a bundled brand font, its per-weight cut
        // via `customFontName`) so one line here re-skins the entire app's type.
    init(face: TypeFaceSelections) {
        self.init(
            display:     Self.font(.largeTitle, .black,    face: face),
            title:       Self.font(.title2,     .heavy,    face: face),
            heading:     Self.font(.title3,     .semibold, face: face),
            headline:    Self.font(.headline,   .semibold, face: face),
            body:        Self.font(.body,       .regular,  face: face),
            label:       Self.font(.callout,    .medium,   face: face),
            subheadline: Self.font(.subheadline, .semibold, face: face),
            caption:     Self.font(.caption,    .regular,  face: face),
            mono:        .system(.callout, design: .monospaced)
        )
    }
    
        // One place that decides system-vs-bundled. System faces keep full Dynamic
        // Type behavior for free; a bundled face is selected by its exact PostScript
        // name (so we get the *real* weighted cut, not a synthesized one) yet still
        // scales relative to the same text style, so it stays accessible too. This is
        // the single seam a real brand font plugs into — see AppTypeface.customFontName.
    private static func font(_ style: Font.TextStyle, _ weight: Font.Weight, face: TypeFaceSelections) -> Font{
        return .system(style, design: face.design).weight(weight)
    }
    
        // Point sizes for a bundled font at the default (Large) content size. Only
        // consulted for custom families; system faces use Font.system(_:design:).
    private static func baseSize(for style: Font.TextStyle) -> CGFloat {
        switch style {
            case .largeTitle:  34
            case .title:       28
            case .title2:      22
            case .title3:      20
            case .headline:    17
            case .body:        17
            case .callout:     16
            case .subheadline: 15
            case .footnote:    13
            case .caption:     12
            case .caption2:    11
            default:           17
        }
    }
}

    // The typefaces the picker can choose. rawValue is the stored choice. System
    // choices use SF with a different Font.Design; .brand uses the bundled Comfortaa
    // cuts registered in Info.plist (UIAppFonts).
public enum TypeFaceSelections: String, CaseIterable, Identifiable, Sendable {
    case standard   // SF (system default) — the safe fallback, current look
    case rounded    // SF Rounded — friendly, softer
    case serif      // New York — editorial, "not an iOS app"
    case mono       // SF Mono — technical / brutalist

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
            case .standard: "Sharp"
            case .rounded:  "Curvy"
            case .serif:    "Editor"
            case .mono:     "Mono"
        }
    }
    
        // Which Font.Design backs this face. Used only when customFontName is nil;
        // for .brand it's the fallback design if the bundled cuts fail to load.
    var design: Font.Design {
        switch self {
            case .standard: .default
            case .rounded:  .rounded
            case .serif:    .serif
            case .mono:     .monospaced
        }
    }
    
        // Whether this face ships a bundled custom font family (selected by PostScript
        // name) rather than an SF system design. Every current case is a system face,
        // so this is false — it's the seam a real brand font plugs into later.
    var isBundled: Bool {
        switch self {
            case .standard, .rounded, .serif, .mono: false
        }
    }
    
        // Shared key so Typography and the Settings picker read/write the same choice.
    static let storageKey = "activeTypeface"
        // Standard SF is the safe, universally available default face.
    public static let `default`: TypeFaceSelections = .standard
}

    // NEW: App-wide muted secondary label.
struct SliderValueText: View {
    @Environment(\.typography) private var typography
    @Environment(\.sliderPalette) private var sliderforeground
    let label: String

    init(_ label: String) {
        self.label = label
    }

    var body: some View {
        Text(label)
            .font(typography.label.monospacedDigit())
            .foregroundStyle(sliderforeground.valueColor.opacity(0.76))
    }
}

struct SliderSecondaryText: View {
    @Environment(\.typography) private var typography
    @Environment(\.sliderPalette) private var sliderforeground
    let label: String

    init(_ label: String) {
        self.label = label
    }

    var body: some View {
        Text(label)
            .font(typography.caption.monospaced())
            .foregroundStyle(sliderforeground.valueColor.opacity(0.76))
    }
}

    // NEW: App-wide creator field label.
struct SliderLabelText: View {
    @Environment(\.typography) private var typography
    @Environment(\.sliderPalette) private var sliderforeground
    let label: String

    init(_ label: String) {
        self.label = label
    }

    var body: some View {
        Text(label)
            .font(typography.heading)
            .foregroundStyle(sliderforeground.labelColor)
    }
}

struct SliderTextField: ViewModifier {
    @Environment(\.typography) private var typography
    @Environment(\.sliderPalette) private var palette

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(palette.textentryfill.opacity(0.34), in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(palette.strokeborder.opacity(0.5), lineWidth: 0.75)
            )
    }
}

extension View {
    func sliderTextFieldStyle() -> some View {
        modifier(SliderTextField())
    }
}

