//
//  Examples.swift
//  FancySliders
//
//  Created by Vedant A. Desai on 7/30/26.
//

import SwiftUI
import SwiftData

struct ExampleGradientSlider: View {
    @State private var val1: Int = 10
    @State private var val2: Int = 10
    @State private var val3: Double = 0.1
    @State private var val4: Int = 10
    @State private var opt1: Int? = nil
    @State private var opt2: Double? = 0.5
    @State private var opt2Name: String = "custom_parameter"
    var body: some View {
        Form {
            Group {
                Text("Bipolar Sliders")
                    .font(.title.bold())
                BipolarSlider(
                    "Default (Rounded Font)",
                    value: $val1,
                    in: -100...100, 
                    step: 1,
                    leftColor: Color(.systemBlue),
                    rightColor: Color(.systemRed),
                    lowerLimit: "lowerlim",
                    upperLimit: "upperlim",
                    format: .integer,
                    hideValueLabel: false,
                    typeface: .rounded
                )
                BipolarSlider(
                    "Hidden Value (Mono Font)",
                    value: $val2,
                    in: -100...100,
                    step: 1,
                    leftColor: Color(.systemBlue),
                    rightColor: Color(.systemRed),
                    lowerLimit: "lowerlim",
                    upperLimit: "upperlim",
                    format: .integer,
                    hideValueLabel: true,
                    typeface: .mono
                )
            }
            Group {
                Text("Unipolar Sliders")
                    .font(.title.bold())
                UnipolarSlider(
                    "Default (Standard Font)",
                    value: $val3,
                    in: 0.00...1.00,
                    step: 0.01,
                    color: .orange,
                    format: .double,
                    hideValueLabel: false,
                    typeface: .standard
                )
                UnipolarSlider(
                    "Hidden (Serif Font)",
                    value: $val4,
                    in: 0...100,
                    color: .green,
                    hideValueLabel: true,
                    typeface: .serif
                )
            }
            Group {
                Text("Optional Sliders")
                    .font(.title.bold())
                OptionalGradientSlider(
                    "Fixed Label",
                    value: $opt1,
                    in: 0...100,
                    defaultWhenEnabled: 50,
                    color: .red
                )
                OptionalGradientSlider(
                    "Customizable",
                    valueName: $opt2Name,
                    value: $opt2,
                    in: 0.0...1.0,
                    step: 0.01,
                    format: .double,
                    defaultWhenEnabled: 0.5,
                    color: .teal,
                    typeface: .rounded
                )
            }
        }
    }
}


#Preview("Default palette") {
    ExampleGradientSlider()
}

#Preview("Custom palette") {
    ExampleGradientSlider()
        .sliderPalette(
            SliderPalette(
                labelColor: .red,
                valueColor: .orange,
                accent: .orange,
                textentryfill: .red,
                strokeborder: .brown
            )
        )
}
