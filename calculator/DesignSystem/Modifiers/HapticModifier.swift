//
//  HapticModifier.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct HapticModifier: ViewModifier {
    let style: UIImpactFeedbackGenerator.FeedbackStyle
    let intensity: CGFloat

    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.impactOccurred(intensity: intensity)
            }
        )
    }
}

extension View {
    func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light, intensity: CGFloat = 0.6) -> some View {
        modifier(HapticModifier(style: style, intensity: intensity))
    }
}
