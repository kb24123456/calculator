//
//  CalculatorView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI
import SwiftData

struct CalculatorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CalculatorViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Expression Display
            ExpressionDisplayView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, NumoSpacing.md)

            // MARK: - Keypad
            KeypadView(viewModel: viewModel) {
                viewModel.calculateAndCommit(modelContext: modelContext, appState: appState)
            }
            .padding(.horizontal, NumoSpacing.sm)
            .padding(.bottom, NumoSpacing.xs)
        }
    }
}

#Preview {
    CalculatorView()
        .environment(AppState())
        .environment(HapticService())
        .modelContainer(for: CalculationRecord.self, inMemory: true)
}
