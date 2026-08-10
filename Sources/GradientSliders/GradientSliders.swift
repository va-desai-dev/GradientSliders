// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import Foundation
import Foundation

// A numeric value a slider can drive. Both `Int` (integer sliders) and `Double`
// (continuous sliders) conform, so one generic slider handles both without a
// redundant copy. The track itself always works in `Double`, so conformers only
// need to bridge to/from that.
public protocol SliderValue: Comparable, ExpressibleByIntegerLiteral, Sendable {
    var doubleValue: Double { get }
    static func fromDouble(_ value: Double) -> Self
}

extension Int: SliderValue {
    public var doubleValue: Double { Double(self) }
    // Truncates toward zero. The track always emits values snapped to the step
    // grid (exact integral Doubles for integer steps), so this is lossless there
    // and simply drops any fractional drift on continuous input.
    public static func fromDouble(_ value: Double) -> Int { Int(value) }
}

extension Double: SliderValue {
    public var doubleValue: Double { self }
    public static func fromDouble(_ value: Double) -> Double { value }
}

public enum SliderValueFormat: String, Codable, CaseIterable, Identifiable {
    case integer = "%d"
    case double = "%.2f"
    case percent = "%.0f%%" // Handy bonus: formats as 100%

    public var id: String { rawValue } // Make the id public as well

    // Renders a value for the on-screen ticker. Shared by both sliders so the
    // formatting rules live in one place regardless of the underlying value type.
    func display(_ value: Double) -> String {
        switch self {
            case .integer:
                // Always whole — safeguards a Double against printing a decimal.
                return String(format: "%.0f", value)
            case .double:
                // Strip a trailing ".0" for whole numbers, keep precision otherwise.
                if value.truncatingRemainder(dividingBy: 1) == 0 {
                    return String(format: "%.0f", value)
                }
                return String(format: rawValue, value)
            case .percent:
                // Keep the literal "%" — never strip, even for whole numbers.
                return String(format: rawValue, value)
        }
    }
}


// -  A plain gradient slider with a monospaced value indicator. Generic over the value type — pass an `Int` binding for integer steps or a `Double` binding for continuous values. Perfect for percentage choosers, age, demographic variables in forms/surveys etc.
    /// - Based on one singular range from 0 to an upper bound (e.g., 0...100 or 0.0...1.0).
    /// - "hideValueLabel = true" , you can hide the value ticker. Useful to use when you are worried about user becoming choosy over what to set it at. Takes out the cognitive load of making a decision. Some examples this can be used is when you care more about general estimations/confidence band based score ranges over precise metrics (e.g., volume/brightness sliders).
    /// - Pass any `color` you like — the gradient fades from a soft white into it.
    /// - `typeface` re-skins the labels using one of the four bundled SF designs.
public struct UnipolarSlider<V: SliderValue>: View {
    let label: String
    @Binding var value: V
    let range: ClosedRange<V>
    let step: V
    let format: SliderValueFormat
    let hideValueLabel: Bool
    let gradientColor: Color
    let typeface: TypeFaceSelections

    private var typography: Typography { Typography(face: typeface) }

    private var trackGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .white.opacity(0.26), location: 0.0),
                .init(color: gradientColor, location: 1.0),
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var formattedValue: String { format.display(value.doubleValue) }


    public init(
        _ label: String,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V = 1,
        color: Color,
        format: SliderValueFormat = .integer,
        hideValueLabel: Bool = false,
        typeface: TypeFaceSelections = .standard
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.gradientColor = color
        self.format = format
        self.hideValueLabel = hideValueLabel
        self.typeface = typeface
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                SliderLabelText(label)
                Spacer()
                if !hideValueLabel {
                    SliderValueText(formattedValue)
                        .monospacedDigit()
                }
            }
                GradientSliderTrack(
                    value: Binding(
                        get: { value.doubleValue },
                        set: { value = V.fromDouble($0) }
                    ),
                    range: range.lowerBound.doubleValue...range.upperBound.doubleValue,
                    step: step.doubleValue,
                    gradient: trackGradient
                )
                .frame(height: 28)
        }
        .padding(.vertical, 2)
        .environment(\.typography, typography)
    }
}

// -  A bidirectional gradient slider with a monospaced value indicator. Generic over the value type — pass an `Int` binding for integer steps or a `Double` binding for continuous values. Perfect for percentage selections where your construct of interest is bivariate such as political spectrum leanings, "percentage heat vs percentage cold" etc. Plan to seperately add guages too I have developer.
    /// - Based on one singular range straddling zero (e.g., -100...100 or -1.0...1.0).
    /// - "hideValueLabel = true" , you can hide the value ticker. Useful to use when you are worried about user becoming choosy over what to set it at. Takes out the cognitive load of making a decision. Some examples this can be used is when you care more about general estimations/confidence band based score ranges over precise metrics (e.g., volume/brightness sliders).
    /// - Pass a `leftColor` and `rightColor` — the gradient fades through a soft white pivot at zero.
    /// - `typeface` re-skins the labels using one of the four bundled SF designs.
public struct BipolarSlider<V: SliderValue>: View {
    let label: String
    @Binding var value: V
    let range: ClosedRange<V>
    let step: V
    let lowerlim: String
    let upperlim: String
    let leftColor: Color
    let rightColor: Color
    let format: SliderValueFormat
    let hideValueLabel: Bool
    let typeface: TypeFaceSelections


    private var typography: Typography { Typography(face: typeface) }

    private var formattedValue: String { format.display(value.doubleValue) }

    private var trackGradient: LinearGradient {
        let lower = range.lowerBound.doubleValue
        let upper = range.upperBound.doubleValue
        let totalRange = upper - lower
        let centerLocation = totalRange != 0 ? (0.0 - lower) / totalRange : 0.5
        return LinearGradient(
            gradient: Gradient(stops: [
                .init(color: leftColor, location: 0.0),
                .init(color: .gray.opacity(0.1), location: CGFloat(max(0, min(1, centerLocation)))),
                .init(color: rightColor, location: 1.0),
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    public init(
        _ label: String,
        value: Binding<V>,
        in range: ClosedRange<V>,
        step: V = 1,
        leftColor: Color,
        rightColor: Color,
        lowerLimit: String = "",
        upperLimit: String = "",
        format: SliderValueFormat = .integer,
        hideValueLabel: Bool = false,
        typeface: TypeFaceSelections = .standard
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.leftColor = leftColor
        self.rightColor = rightColor
        self.lowerlim = lowerLimit
        self.upperlim = upperLimit
        self.format = format
        self.hideValueLabel = hideValueLabel
        self.typeface = typeface
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                SliderLabelText(label)
                Spacer()
                if !hideValueLabel {
                    SliderValueText(formattedValue)
                        .monospacedDigit()
                }
            }
            HStack {
                SliderSecondaryText(lowerlim)
                Spacer()
                SliderSecondaryText(upperlim)
            }
            GradientSliderTrack(
                value: Binding(
                    get: { value.doubleValue },
                    set: { value = V.fromDouble($0) }
                ),
                range: range.lowerBound.doubleValue...range.upperBound.doubleValue,
                step: step.doubleValue,
                gradient: trackGradient
            )
            .frame(height: 28)
        }
        .padding(.vertical, 2)
        .environment(\.typography, typography)
    }
}


// -  An optional gradient slider: a trailing toggle enables/disables the value.
    /// - Off → the binding is `nil`, so the caller falls back to its own default;
    ///   on → it holds `defaultWhenEnabled` until dragged. Generic over the value
    ///   type — pass an `Int` or `Double` optional binding.
    /// - Pass a `valueName` binding to make the parameter's name user-editable (a
    ///   "customizable" slider); omit it for a fixed `label`. That single optional
    ///   binding is the seam that used to require a whole second view.
    /// - `color` optionally overrides the gradient tint; label and value colors come
    ///   from the injected `SliderPalette` so every slider stays consistent.
public struct OptionalGradientSlider<V: SliderValue>: View {
    @Environment(\.sliderPalette) private var palette

    let label: String
    @Binding var value: V?
    let range: ClosedRange<V>
    let step: V
    let format: SliderValueFormat
    let defaultWhenEnabled: V
    let gradientColor: Color?
        // nil → fixed label; non-nil → editable name field (the conditional seam).
    private let valueName: Binding<String>?
    let typeface: TypeFaceSelections

    private var typography: Typography { Typography(face: typeface) }

        // Fixed-label variant.
    public init(
        _ label: String,
        value: Binding<V?>,
        in range: ClosedRange<V>,
        step: V = 1,
        format: SliderValueFormat = .integer,
        defaultWhenEnabled: V,
        color: Color? = nil,
        typeface: TypeFaceSelections = .standard
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.format = format
        self.defaultWhenEnabled = defaultWhenEnabled
        self.gradientColor = color
        self.valueName = nil
        self.typeface = typeface
    }

        // Customizable variant: the parameter name becomes an editable field.
    public init(
        _ label: String,
        valueName: Binding<String>,
        value: Binding<V?>,
        in range: ClosedRange<V>,
        step: V = 1,
        format: SliderValueFormat = .integer,
        defaultWhenEnabled: V,
        color: Color? = nil,
        typeface: TypeFaceSelections = .standard
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.format = format
        self.defaultWhenEnabled = defaultWhenEnabled
        self.gradientColor = color
        self.valueName = valueName
        self.typeface = typeface
    }

    private var trackGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .white.opacity(0.26), location: 0.0),
                .init(color: gradientColor ?? palette.accent, location: 1.0),
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                header
                Toggle("", isOn: overrideBinding)
                    .labelsHidden()
                    .tint(palette.accent)
            }
            GradientSliderTrack(
                value: sliderBinding,
                range: range.lowerBound.doubleValue...range.upperBound.doubleValue,
                step: step.doubleValue,
                gradient: trackGradient
            )
            .frame(height: 28)
            .disabled(value == nil)
            .opacity(value == nil ? 0.5 : 1)
        }
        .padding(.vertical, 2)
        .environment(\.typography, typography)
    }

        // THE CONDITIONAL PARSER: the single place that decides the row's leading
        // content. Enabled + editable name → text field; enabled + fixed → label;
        // disabled → label + an italic "default" hint. When enabled, the value
        // ticker rides along after a spacer.
    @ViewBuilder private var header: some View {
        if let value {
            if let valueName {
                TextField("custom_entry", text: valueName)
                    .labelsHidden() // iOS: keeps it a placeholder; macOS: hides the leading label
                    .foregroundStyle(palette.valueColor)
                    .textCase(.lowercase)
                    .lineLimit(1)
                    .autocorrectionDisabled()
                    .noAutocap()
                    .font(typography.heading)
                    .textFieldStyle(.plain)
                    .sliderTextFieldStyle()
            } else {
                SliderLabelText(label)
            }
            Spacer()
            SliderValueText(format.display(value.doubleValue))
                .monospacedDigit()
        } else {
            SliderLabelText(label)
            Spacer()
            SliderValueText("default")
                .italic()
        }
    }

    private var overrideBinding: Binding<Bool> {
        Binding(
            get: { value != nil },
            set: { isOn in value = isOn ? (value ?? defaultWhenEnabled) : nil }
        )
    }

    private var sliderBinding: Binding<Double> {
        Binding(
            get: { (value ?? defaultWhenEnabled).doubleValue },
            set: { value = V.fromDouble($0) }
        )
    }
}
