//
//  View+Extensions.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

extension View {
    /// Apply modifier conditionally.
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Hide view if condition is true.
    @ViewBuilder
    func hidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}
