//
//  ToolTransition.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

extension AnyTransition {
    /// Tool content area switch transition:
    /// - Removal: fade out + slide down 8pt
    /// - Insertion: fade in + slide up 8pt
    static var toolSwitch: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 8)),
            removal: .opacity.combined(with: .offset(y: -8))
        )
    }
}
