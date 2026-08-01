// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

// -  A plain gradient slider with a monospaced value indicator. Slider only accepts Integers. Perfect for percentage choosers, age, demographic variables in forms/surveys etc.
    /// - Based on one singular range from 0-Integer (e.g., 100).
    /// - "hideValueLabel = true" , you can hide the value ticker. Useful to use when you are worried about user becoming choosy over what to set it at. Takes out the cognitive load of making a decision. Some examples this can be used is when you care more about general estimations/confidence band based score ranges over precise metrics (e.g., volume/brightness sliders).
    /// - Pass any `color` you like — the gradient fades from a soft white into it.
    /// - `typeface` re-skins the labels using one of the four bundled SF designs.
public struct UnipolarSlider: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let format: String
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

    public init(
        _ label: String,
        value: Binding<Int>,
        in range: ClosedRange<Int>,
        step: Int = 1,
        color: Color,
        format: String = "%d",
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
                CreatorFieldLabel(label)
                Spacer()
                if !hideValueLabel {
                    Text(String(format: format, value))
                        .font(typography.label.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            GradientSliderTrack(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0) }
                ),
                range: Double(range.lowerBound)...Double(range.upperBound),
                step: Double(step),
                gradient: trackGradient
            )
            .frame(height: 28)
        }
        .padding(.vertical, 2)
        .environment(\.typography, typography)
    }
}

// -  A bidirectional gradient slider with a monospaced value indicator. Slider only accepts Integers. Perfect for percentage selections where your construct of interest is bivariate such as political spectrum leanings, "percentage heat vs percentage cold" etc. Plan to seperately add guages too I have developer.
    /// - Based on one singular range from -Int-Int.
    /// - "hideValueLabel = true" , you can hide the value ticker. Useful to use when you are worried about user becoming choosy over what to set it at. Takes out the cognitive load of making a decision. Some examples this can be used is when you care more about general estimations/confidence band based score ranges over precise metrics (e.g., volume/brightness sliders).
    /// - Pass a `leftColor` and `rightColor` — the gradient fades through a soft white pivot at zero.
    /// - `typeface` re-skins the labels using one of the four bundled SF designs.
public struct BipolarSlider: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let lowerlim: String
    let upperlim: String
    let leftColor: Color
    let rightColor: Color
    let format: String
    let hideValueLabel: Bool
    let typeface: TypeFaceSelections

    private var typography: Typography { Typography(face: typeface) }

    private var trackGradient: LinearGradient {
        let lower = Double(range.lowerBound)
        let upper = Double(range.upperBound)
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
        value: Binding<Int>,
        in range: ClosedRange<Int>,
        step: Int = 1,
        leftColor: Color,
        rightColor: Color,
        lowerLimit: String = "",
        upperLimit: String = "",
        format: String = "%d",
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
                CreatorFieldLabel(label)
                Spacer()
                if !hideValueLabel {
                    Text(String(format: format, value))
                        .font(typography.label.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            HStack {
                Text(lowerlim)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                Spacer()
                Text(upperlim)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            GradientSliderTrack(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0) }
                ),
                range: Double(range.lowerBound)...Double(range.upperBound),
                step: Double(step),
                gradient: trackGradient
            )
            .frame(height: 28)
        }
        .padding(.vertical, 2)
        .environment(\.typography, typography)
    }
}
