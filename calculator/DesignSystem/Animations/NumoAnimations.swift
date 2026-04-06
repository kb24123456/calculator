//
//  NumoAnimations.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

enum NumoAnimations {
    /// Button press spring
    static let buttonPress = Animation.spring(response: 0.2, dampingFraction: 0.6)

    /// Tool switch transition duration
    static let toolSwitchOut: Animation = .easeOut(duration: 0.2)
    static let toolSwitchIn: Animation = .easeIn(duration: 0.25).delay(0.05)

    /// Chip selection
    static let chipSelection = Animation.easeInOut(duration: 0.25)

    /// Key press highlight fade
    static let keyHighlight = Animation.easeOut(duration: 0.15)

    /// Error shake
    static let errorShake = Animation.linear(duration: 0.4)

    /// General spring for interactive feedback
    static let interactiveSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
}
