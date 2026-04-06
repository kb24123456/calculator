//
//  ExpressionDisplayView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct ExpressionDisplayView: View {
    let viewModel: CalculatorViewModel

    var body: some View {
        VStack(alignment: .trailing, spacing: NumoSpacing.xs) {
            Spacer()

            // Expression
            ScrollView(.horizontal, showsIndicators: false) {
                Text(viewModel.displayExpression)
                    .font(viewModel.currentResult.isEmpty ? NumoTypography.monoDisplayLarge : NumoTypography.monoDisplayMedium)
                    .foregroundStyle(viewModel.currentResult.isEmpty ? NumoColors.textPrimary : NumoColors.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .shake(trigger: viewModel.errorShakeTrigger)
            }
            .defaultScrollAnchor(.trailing)

            // Result (live preview)
            if !viewModel.currentResult.isEmpty && !viewModel.isError {
                Text(viewModel.currentResult)
                    .font(NumoTypography.monoDisplayLarge)
                    .foregroundStyle(NumoColors.textPrimary)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .transition(.opacity)
            }

            if viewModel.isError {
                Text(String(localized: "表达式错误"))
                    .font(NumoTypography.bodySmall)
                    .foregroundStyle(NumoColors.danger)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

#Preview {
    let vm = CalculatorViewModel()
    ExpressionDisplayView(viewModel: vm)
        .frame(height: 200)
        .padding()
}
