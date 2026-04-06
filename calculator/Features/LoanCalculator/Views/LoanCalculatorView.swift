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

                // MARK: - Grouped Inputs Card
                inputsCard

                // MARK: - Repayment Method
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

                // MARK: - Hero Result Card
                if let result = viewModel.result {
                    resultHeroCard(result: result)
                        .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
                }
            }
            .padding(.top, NumoSpacing.sm)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.result != nil)
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

    // MARK: - Grouped Inputs Card (amount + term + rate, no borders)

    private var inputsCard: some View {
        VStack(spacing: 0) {
            // Row: Loan amount
            inputRow(
                label: String(localized: "贷款金额"),
                unit: String(localized: "万元"),
                value: viewModel.amountText,
                placeholder: "100",
                isActive: activeField == .primary
            ) { activeField = .primary }

            Divider()
                .padding(.leading, NumoSpacing.md)

            // Row: Term presets
            VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                Text(String(localized: "贷款期限"))
                    .font(NumoTypography.caption)
                    .foregroundStyle(NumoColors.textTertiary)
                    .padding(.horizontal, NumoSpacing.md)
                    .padding(.top, NumoSpacing.sm)

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
                                        viewModel.termMonths == preset.months
                                            ? NumoColors.chipSelectedText
                                            : NumoColors.chipDefaultText
                                    )
                                    .padding(.horizontal, NumoSpacing.sm)
                                    .frame(height: 30)
                                    .background(
                                        Capsule().fill(
                                            viewModel.termMonths == preset.months
                                                ? NumoColors.chipSelected
                                                : NumoColors.chipDefault
                                        )
                                    )
                                    .animation(NumoAnimations.chipSelection, value: viewModel.termMonths)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, NumoSpacing.md)
                }
                .padding(.bottom, NumoSpacing.sm)
            }

            Divider()
                .padding(.leading, NumoSpacing.md)

            // Row: Annual rate
            inputRow(
                label: String(localized: "年利率"),
                unit: "%",
                value: viewModel.annualRateText,
                placeholder: "3.45",
                isActive: activeField == .secondary
            ) { activeField = .secondary }

            // Rate presets
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
                            .frame(height: 26)
                            .background(Capsule().fill(NumoColors.chipDefault))
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal, NumoSpacing.md)
            .padding(.bottom, NumoSpacing.sm)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(NumoColors.surfaceSecondary)
        )
    }

    // MARK: - Input Row (inside card, no individual background)

    private func inputRow(
        label: String,
        unit: String,
        value: String,
        placeholder: String,
        isActive: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(NumoTypography.caption)
                        .foregroundStyle(isActive ? NumoColors.textSecondary : NumoColors.textTertiary)
                    Text(unit)
                        .font(NumoTypography.caption)
                        .foregroundStyle(NumoColors.textTertiary)
                }
                Spacer()
                Text(value.isEmpty ? placeholder : value)
                    .font(NumoTypography.monoTitleLarge)
                    .foregroundStyle(
                        value.isEmpty
                            ? NumoColors.textTertiary
                            : (isActive ? NumoColors.textPrimary : NumoColors.textSecondary)
                    )
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: value)
            }
            .padding(.horizontal, NumoSpacing.md)
            .frame(height: 56)
        }
        .buttonStyle(.plain)
        .animation(NumoAnimations.chipSelection, value: isActive)
    }

    // MARK: - Hero Result Card

    private func resultHeroCard(result: LoanResult) -> some View {
        VStack(spacing: 0) {
            // Hero: label + big amount
            VStack(spacing: NumoSpacing.xs) {
                Text(
                    viewModel.method == .equalInstallment
                        ? String(localized: "月供")
                        : String(localized: "首月月供")
                )
                .font(NumoTypography.bodySmall)
                .foregroundStyle(NumoColors.textSecondary)

                Text(ExpressionFormatter.formatCurrency(result.monthlyPayment))
                    .font(NumoTypography.monoHero)
                    .foregroundStyle(NumoColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: result.monthlyPayment)

                if let lastMonth = result.lastMonthPayment {
                    Text(String(localized: "末月 \(ExpressionFormatter.formatCurrency(lastMonth))"))
                        .font(NumoTypography.caption)
                        .foregroundStyle(NumoColors.textTertiary)
                        .contentTransition(.numericText())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, NumoSpacing.xl)
            .padding(.horizontal, NumoSpacing.lg)

            Divider()
                .padding(.horizontal, NumoSpacing.lg)

            // Secondary stats: 总还款 | 总利息
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: NumoSpacing.xxs) {
                    Text(String(localized: "总还款"))
                        .font(NumoTypography.caption)
                        .foregroundStyle(NumoColors.textTertiary)
                    Text(ExpressionFormatter.formatCurrency(result.totalRepayment))
                        .font(NumoTypography.monoTitleLarge)
                        .foregroundStyle(NumoColors.textPrimary)
                        .contentTransition(.numericText())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: NumoSpacing.xxs) {
                    Text(String(localized: "总利息"))
                        .font(NumoTypography.caption)
                        .foregroundStyle(NumoColors.textTertiary)
                    Text(ExpressionFormatter.formatCurrency(result.totalInterest))
                        .font(NumoTypography.monoTitleLarge)
                        .foregroundStyle(NumoColors.danger)
                        .contentTransition(.numericText())
                }
            }
            .padding(NumoSpacing.lg)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(NumoColors.surfaceSecondary)
        )
    }
}
