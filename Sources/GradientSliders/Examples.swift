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
    @State private var val3: Int = 10
    @State private var val4: Int = 10
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
                    format: "%d",
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
                    format: "%d",
                    hideValueLabel: true,
                    typeface: .mono
                )
            }
            Group {
                Text("Unipolar Sliders")
                    .font(.title.bold())
                UnipolarSlider(
                    "Default (Standard Font)",
                    value: $val3, in: 0...100,
                    color: .orange,
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
        }
    }
}


#Preview {
    ExampleGradientSlider()
}

