//
//  LoanCalculatorView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

/// Display-only loan calculator view. Keypad input managed by NumoTabView.
struct LoanCalculatorView: View {
    let viewModel: LoanCalculatorViewModel
    @Binding var activeField: ToolInputField
    var onScrollCollapse: (() -> Void)?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: NumoSpacing.md) {
                // Amount input (tappable)
                inputField(
                    label: String(localized: "贷款金额（万元）"),
                    value: viewModel.amountText,
                    placeholder: "100",
                    isActive: activeField == .primary
                ) {
                    activeField = .primary
                }

                // Term presets
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    Text(String(localized: "贷款期限"))
                        .font(NumoTypography.bodySmall)
                        .foregroundStyle(NumoColors.textSecondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: NumoSpacing.xs) {
                            ForEach(LoanCalculatorViewModel.termPresets, id: \.months) { preset in
                                Button {
                                    viewModel.termMonths = preset.months
                                    viewModel.calculate()
                                } label: {
                                    Text(preset.label)
                                        .font(NumoTypography.bodySmall)
                                        .foregroundStyle(
                                            viewModel.termMonths == preset.months ? NumoColors.chipSelectedText : NumoColors.chipDefaultText
                                        )
                                        .padding(.horizontal, NumoSpacing.sm)
                                        .frame(height: 32)
                                        .background(
                                            Capsule().fill(
                                                viewModel.termMonths == preset.months ? NumoColors.chipSelected : NumoColors.chipDefault
                                            )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // Rate input (tappable) + presets
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    inputField(
                        label: String(localized: "年利率（%）"),
                        value: viewModel.annualRateText,
                        placeholder: "3.45",
                        isActive: activeField == .secondary
                    ) {
                        activeField = .secondary
                    }

                    HStack(spacing: NumoSpacing.xs) {
                        ForEach(LoanCalculatorViewModel.ratePresets, id: \.rate) { preset in
                            Button {
                                viewModel.annualRateText = preset.rate
                                viewModel.calculate()
                            } label: {
                                Text(preset.label)
                                    .font(NumoTypography.caption)
                                    .foregroundStyle(NumoColors.chipDefaultText)
                                    .padding(.horizontal, NumoSpacing.xs)
                                    .frame(height: 28)
                                    .background(Capsule().fill(NumoColors.chipDefault))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Method selector
                NumoSegmentedControl(
                    options: [
                        (String(localized: "等额本息"), RepaymentMethod.equalInstallment),
                        (String(localized: "等额本金"), RepaymentMethod.equalPrincipal),
                    ],
                    selection: Binding(
                        get: { viewModel.method },
                        set: {
                            viewModel.method = $0
                            viewModel.calculate()
                        }
                    )
                )

                // Result
                if let result = viewModel.result {
                    NumoCard {
                        VStack(spacing: NumoSpacing.sm) {
                            ResultBanner(
                                label: viewModel.method == .equalInstallment
                                    ? String(localized: "月供")
                                    : String(localized: "首月月供"),
                                value: ExpressionFormatter.formatCurrency(result.monthlyPayment)
                            )

                            if let lastMonth = result.lastMonthPayment {
                                ResultBanner(
                                    label: String(localized: "末月月供"),
                                    value: ExpressionFormatter.formatCurrency(lastMonth)
                                )
                            }

                            Divider()

                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "总还款"))
                                        .font(NumoTypography.caption)
                                        .foregroundStyle(NumoColors.textTertiary)
                                    Text(ExpressionFormatter.formatCurrency(result.totalRepayment))
                                        .font(NumoTypography.bodyMedium)
                                        .foregroundStyle(NumoColors.textPrimary)
                                        .contentTransition(.numericText())
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(String(localized: "总利息"))
                                        .font(NumoTypography.caption)
                                        .foregroundStyle(NumoColors.textTertiary)
                                    Text(ExpressionFormatter.formatCurrency(result.totalInterest))
                                        .font(NumoTypography.bodyMedium)
                                        .foregroundStyle(NumoColors.danger)
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
        .simultaneousGesture(
            DragGesture(minimumDistance: 40)
                .onChanged { value in
                    if value.translation.height < -40 {
                        onScrollCollapse?()
                    }
                }
        )
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
