//
//  CalculatorView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

/// Display-only view for the calculator tool.
/// Shows expression and live result. Keypad is managed by NumoTabView.
struct CalculatorView: View {
    let viewModel: CalculatorViewModel

    var body: some View {
        ExpressionDisplayView(viewModel: viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
