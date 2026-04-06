//
//  IncomeTaxView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

/// Display-only income tax view. Keypad input managed by NumoTabView.
struct IncomeTaxView: View {
    @Bindable var viewModel: IncomeTaxViewModel
    @Binding var activeField: ToolInputField

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: NumoSpacing.md) {
                // Salary input (tappable)
                inputField(
                    label: String(localized: "税前月薪"),
                    value: viewModel.monthlySalaryText,
                    placeholder: String(localized: "输入税前月薪"),
                    isActive: activeField == .primary
                ) {
                    activeField = .primary
                }

                // Housing fund slider
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    HStack {
                        Text(String(localized: "公积金比例"))
                            .font(NumoTypography.bodySmall)
                            .foregroundStyle(NumoColors.textSecondary)
                        Spacer()
                        Text("\(Int(viewModel.housingFundPercent))%")
                            .font(NumoTypography.bodyMedium)
                            .foregroundStyle(NumoColors.textPrimary)
                    }
                    Slider(value: $viewModel.housingFundPercent, in: 5...12, step: 1)
                        .tint(NumoColors.accentRed)
                        .onChange(of: viewModel.housingFundPercent) { viewModel.calculate() }
                }

                // Special deductions (tappable)
                inputField(
                    label: String(localized: "专项附加扣除（月）"),
                    value: viewModel.specialDeductionsText,
                    placeholder: "0",
                    isActive: activeField == .secondary
                ) {
                    activeField = .secondary
                }

                // Result
                if let result = viewModel.result {
                    NumoCard {
                        VStack(spacing: NumoSpacing.sm) {
                            VStack(spacing: NumoSpacing.xxs) {
                                Text(String(localized: "税后月薪"))
                                    .font(NumoTypography.bodySmall)
                                    .foregroundStyle(NumoColors.textSecondary)
                                Text(ExpressionFormatter.formatCurrency(result.monthlyNetSalary[0]))
                                    .font(NumoTypography.monoDisplayMedium)
                                    .foregroundStyle(NumoColors.textPrimary)
                                    .contentTransition(.numericText())
                                    .animation(.easeInOut(duration: 0.2), value: result.monthlyNetSalary[0])
                            }

                            Divider()

                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "个税（首月）"))
                                        .font(NumoTypography.caption)
                                        .foregroundStyle(NumoColors.textTertiary)
                                    Text(ExpressionFormatter.formatCurrency(result.monthlyTax[0]))
                                        .font(NumoTypography.bodyMedium)
                                        .foregroundStyle(NumoColors.textPrimary)
                                        .contentTransition(.numericText())
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(String(localized: "五险一金"))
                                        .font(NumoTypography.caption)
                                        .foregroundStyle(NumoColors.textTertiary)
                                    Text(ExpressionFormatter.formatCurrency(result.monthlySocialInsurance))
                                        .font(NumoTypography.bodyMedium)
                                        .foregroundStyle(NumoColors.textPrimary)
                                        .contentTransition(.numericText())
                                }
                            }

                            Divider()

                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "年度总税"))
                                        .font(NumoTypography.caption)
                                        .foregroundStyle(NumoColors.textTertiary)
                                    Text(ExpressionFormatter.formatCurrency(result.annualTax))
                                        .font(NumoTypography.bodyMedium)
                                        .foregroundStyle(NumoColors.danger)
                                        .contentTransition(.numericText())
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(String(localized: "有效税率"))
                                        .font(NumoTypography.caption)
                                        .foregroundStyle(NumoColors.textTertiary)
                                    Text("\(ExpressionFormatter.format(result.effectiveTaxRate))%")
                                        .font(NumoTypography.bodyMedium)
                                        .foregroundStyle(NumoColors.textPrimary)
                                        .contentTransition(.numericText())
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, NumoSpacing.sm)
            .padding(.horizontal, 2) // Prevent border clipping
        }
    }

    // MARK: - Tappable input field

    private func inputField(label: String, value: String, placeholder: String, isActive: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                Text(label)
                    .font(NumoTypography.bodySmall)
                    .foregroundStyle(NumoColors.textSecondary)
                Spacer()
                Text(value.isEmpty ? placeholder : value)
                    .font(NumoTypography.monoTitleLarge)
                    .foregroundStyle(value.isEmpty ? NumoColors.textTertiary : (isActive ? NumoColors.textPrimary : NumoColors.textSecondary))
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: value)
            }
            .padding(.horizontal, NumoSpacing.md)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(NumoColors.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isActive ? NumoColors.accentRed.opacity(0.5) : .clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
