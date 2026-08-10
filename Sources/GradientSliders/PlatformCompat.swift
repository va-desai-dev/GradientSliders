//
//  PlatformCompat.swift
//  GradientSliders
//
//  Cross-platform plumbing so the package builds for both the iOS and macOS
//  targets. UIKit and AppKit spell the same concepts differently (UIColor vs
//  NSColor, UIFont vs NSFont), and some semantic colors exist on one platform
//  but not the other. This file is the single seam where those differences are
//  reconciled — call sites use the neutral names below and stay platform-agnostic.
//

import SwiftUI

#if canImport(UIKit)
import UIKit

/// The platform's bridged color type (`UIColor` on iOS, `NSColor` on macOS).
typealias PlatformColor = UIColor
/// The platform's bridged font type (`UIFont` on iOS, `NSFont` on macOS).
typealias PlatformFont = UIFont
#elseif canImport(AppKit)
import AppKit

typealias PlatformColor = NSColor
typealias PlatformFont = NSFont
#endif

extension Color {
    /// Subtle neutral fill sitting behind the slider track. Uses `systemGray5`
    /// on iOS; AppKit has no numbered grays, so it falls back to the closest
    /// adaptive neutral.
    static var sliderTrackBackground: Color {
        #if canImport(UIKit)
        Color(PlatformColor.systemGray5)
        #elseif canImport(AppKit)
        Color(PlatformColor.quaternaryLabelColor)
        #else
        Color.gray.opacity(0.3)
        #endif
    }

    /// Hairline separator that resolves on both platforms (`separator` on iOS,
    /// `separatorColor` on macOS).
    static var platformSeparator: Color {
        #if canImport(UIKit)
        Color(PlatformColor.separator)
        #elseif canImport(AppKit)
        Color(PlatformColor.separatorColor)
        #else
        Color.gray
        #endif
    }
}
