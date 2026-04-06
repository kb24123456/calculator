//
//  YoYCalculatorView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct YoYCalculatorView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = YoYCalculatorViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: NumoSpacing.lg) {
                // Mode selector
                NumoSegmentedControl(
                    options: [
                        (String(localized: "同比 YoY"), ComparisonMode.yoy),
                        (String(localized: "环比 MoM"), ComparisonMode.mom),
                    ],
                    selection: $viewModel.mode
                )

                // Inputs
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    Text(String(localized: "本期值"))
                        .font(NumoTypography.bodySmall)
                        .foregroundStyle(NumoColors.textSecondary)
                    NumoTextField(title: "0", text: $viewModel.currentValueText)
                        .onChange(of: viewModel.currentValueText) { viewModel.calculate() }
                }

                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    Text(viewModel.mode == .yoy ? String(localized: "去年同期值") : String(localized: "上期值"))
                        .font(NumoTypography.bodySmall)
                        .foregroundStyle(NumoColors.textSecondary)
                    NumoTextField(title: "0", text: $viewModel.previousValueText)
                        .onChange(of: viewModel.previousValueText) { viewModel.calculate() }
                }

                // Error
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(NumoTypography.bodySmall)
                        .foregroundStyle(NumoColors.danger)
                }

                // Result
                if let result = viewModel.result {
                    NumoCard {
                        VStack(spacing: NumoSpacing.sm) {
                            HStack {
                                Text(viewModel.mode == .yoy ? String(localized: "同比变化") : String(localized: "环比变化"))
                                    .font(NumoTypography.bodyMedium)
                                    .foregroundStyle(NumoColors.textSecondary)
                                Spacer()
                                TrendIndicator(
                                    trend: result.trend,
                                    value: ExpressionFormatter.formatPercent(result.percentageChange)
                                )
                            }

                            Divider()

                            HStack {
                                Text(String(localized: "变化量"))
                                    .font(NumoTypography.bodyMedium)
                                    .foregroundStyle(NumoColors.textSecondary)
                                Spacer()
                                Text(ExpressionFormatter.format(result.absoluteChange))
                                    .font(NumoTypography.monoTitleLarge)
                                    .foregroundStyle(NumoColors.textPrimary)
                            }
                        }
                    }

                    // Formula explanation
                    Text(viewModel.mode == .yoy
                         ? String(localized: "同比增长率 = (本期值 - 去年同期值) / |去年同期值| × 100%")
                         : String(localized: "环比增长率 = (本期值 - 上期值) / |上期值| × 100%"))
                        .font(NumoTypography.caption)
                        .foregroundStyle(NumoColors.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding(.horizontal, NumoSpacing.md)
            .padding(.top, NumoSpacing.md)
        }
        .onAppear {
            viewModel.updateFromLastResult(appState.lastResult)
        }
    }
}

#Preview {
    YoYCalculatorView()
        .environment(AppState())
}
