//
//  SliderFillShape.swift
//  FancySliders
//
//  Created by Vedant A. Desai on 7/30/26.
//

import SwiftUI

// 1. ADD THIS SHAPE COMPONENT ANYWHERE IN YOUR FILE (OUTSIDE THE SLIDER VIEWS)
struct SliderFillShape: Shape {
    var zeroX: CGFloat
    var currentX: CGFloat
    var cornerRadius: CGFloat
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(zeroX, currentX) }
        set {
            zeroX = newValue.first
            currentX = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let minX = min(zeroX, currentX)
        let maxX = max(zeroX, currentX)
        let fillRect = CGRect(
            x: minX,
            y: 0,
            width: max(0, maxX - minX),
            height: rect.height
        )
        
        // Completely rounds both edges so the center line perfectly mirrors the thumb
        return Path(roundedRect: fillRect, cornerRadius: cornerRadius)
    }
}
struct GradientSliderTrack: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let gradient: LinearGradient
    
    private let trackHeight: CGFloat = 9  // Thicker track
    private let thumbSize: CGFloat = 18    // Aligned to height
    private let thumbWidth: CGFloat = 36   // Sleek horizontal width
    private let thumbHeight: CGFloat = 18 // Perfectly flush
    
    @Namespace private var glassNamespace
    @State private var isDragging: Bool = false
    @State private var edgeFeedbackTrigger: Bool = false
    @State private var sliderValue: CGFloat = 0.5
    
    // Baseline tracker storage
    @State private var touchDownValue: Double = 0.0
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let usable = max(0, width - thumbWidth)
            let span = range.upperBound - range.lowerBound
            let progress = span > 0 ? (value - range.lowerBound) / span : 0
            let zeroProgress = span > 0 ? (0.0 - range.lowerBound) / span : 0.5
            
            // 1. Map positions in unified coordinate spaces
            let thumbX = usable * CGFloat(progress)
            let thumbCenter = thumbX + (thumbWidth / 2)
            let zeroCenter = width * CGFloat(zeroProgress)
            
            // 2. Calculate distance from the center line
            let distanceFromCenter = thumbCenter - zeroCenter
            
            // 3. THE FLUID FIX:
            let zeroX = zeroCenter
            let currentX: CGFloat = {
                if distanceFromCenter == 0 {
                    return zeroCenter
                } else if distanceFromCenter > 0 {
                    let scalingFactor = min(1.0, distanceFromCenter / (thumbWidth / 2))
                    return zeroCenter + distanceFromCenter + (thumbWidth / 2) * scalingFactor
                } else {
                    let scalingFactor = min(1.0, abs(distanceFromCenter) / (thumbWidth / 2))
                    return zeroCenter + distanceFromCenter - (thumbWidth / 2) * scalingFactor
                }
            }()
            
            ZStack(alignment: .leading) {
                Group {
                    Capsule()
                        .fill(Color(.systemGray5).opacity(0.5))
                    gradient.opacity(1).saturation(2)
                        .mask(alignment: .leading) {
                            SliderFillShape(
                                zeroX: zeroX,
                                currentX: currentX,
                                cornerRadius: trackHeight / 2
                            )
                            .clipShape(Capsule()) // Perfectly masks the entire slider track assembly
                        }
                }
                .frame(height: trackHeight)

                // LAYER 3: THUMB
                Capsule()
                    .frame(width: thumbWidth, height: thumbHeight)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .foregroundStyle(
                        isDragging ? Color.clear : Color.white
                    )
                    .glassEffect()
                    .scaleEffect(x: isDragging ? 1.5 : 1.0, y: isDragging ? 1.5 : 1.0, anchor: .center)
                    .offset(x: thumbX)
            }
            .frame(height: trackHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .contentShape(Rectangle()) // Makes the whole bar touchable
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        if !isDragging {
                            touchDownValue = value // Snapshot exact position on touch down
                            withAnimation(.snappy()) {
                                isDragging = true
                            }
                        }
                        
                        guard usable > 0 else { return }
                        
                        // Drag anywhere tracking via translation delta
                        let deltaX = drag.translation.width
                        let deltaValue = (Double(deltaX / usable) * span)
                        let rawValue = touchDownValue + deltaValue
                        
                        var processedValue: Double = 0.0
                        
                        // MICROSCOPIC APPLE SNAP ENGINE:
                        // The zero pull is reduced to a faint line. 1 and -1 will feel smooth and free.
                        if abs(rawValue) < 0.15 && range.contains(0.0) {
                            processedValue = 0.0
                        } else {
                            processedValue = step > 0 ? (rawValue / step).rounded() * step : rawValue
                        }
                        
                        value = min(max(range.lowerBound, processedValue), range.upperBound)
                    }
                    .onEnded { drag in
                        guard usable > 0 else { return }
                        
                        // 1. Calculate final location value right where the finger released
                        let deltaX = drag.translation.width
                        let deltaValue = (Double(deltaX / usable) * span)
                        let finalTouchValue = touchDownValue + deltaValue
                        
                        // 2. Kinetic fling evaluation
                        let horizontalVelocity = drag.velocity.width
                        var calculatedValue = finalTouchValue
                        
                        if abs(horizontalVelocity) > 150 {
                            let decelerationRate: Double = 0.12
                            let kineticFlingDistance = Double(horizontalVelocity / usable) * span * decelerationRate
                            calculatedValue += kineticFlingDistance
                        }
                        
                        var processedValue: Double = 0.0
                        
                        // Microscopic snap validation on release
                        if abs(calculatedValue) < 0.15 && range.contains(0.0) {
                            processedValue = 0.0
                        } else {
                            processedValue = step > 0 ? (calculatedValue / step).rounded() * step : calculatedValue
                        }
                        
                        let finalRestingValue = min(max(range.lowerBound, processedValue), range.upperBound)
                        
                        // Snappy native critical spring finish
                        withAnimation(.spring(response: 0.22, dampingFraction: 1.0, blendDuration: 0)) {
                            value = finalRestingValue
                            isDragging = false
                        }
                    }
            )
        }
    }
}
