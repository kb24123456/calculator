//
//  LoanCalculatorView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct LoanCalculatorView: View {
    @State private var viewModel = LoanCalculatorViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: NumoSpacing.lg) {
                // Amount
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    Text(String(localized: "贷款金额（万元）"))
                        .font(NumoTypography.bodySmall)
                        .foregroundStyle(NumoColors.textSecondary)
                    NumoTextField(title: "100", text: $viewModel.amountText)
                        .onChange(of: viewModel.amountText) { viewModel.calculate() }
                }

                // Term
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

                // Rate
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    Text(String(localized: "年利率（%）"))
                        .font(NumoTypography.bodySmall)
                        .foregroundStyle(NumoColors.textSecondary)
                    HStack(spacing: NumoSpacing.xs) {
                        NumoTextField(title: "3.45", text: $viewModel.annualRateText)
                            .frame(maxWidth: .infinity)
                            .onChange(of: viewModel.annualRateText) { viewModel.calculate() }
                        ForEach(LoanCalculatorViewModel.ratePresets, id: \.rate) { preset in
                            Button {
                                viewModel.annualRateText = preset.rate
                                viewModel.calculate()
                            } label: {
                                Text(preset.label)
                                    .font(NumoTypography.caption)
                                    .foregroundStyle(NumoColors.chipDefaultText)
                                    .padding(.horizontal, NumoSpacing.xs)
                                    .frame(height: 32)
                                    .background(Capsule().fill(NumoColors.chipDefault))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Method
                NumoSegmentedControl(
                    options: [
                        (String(localized: "等额本息"), RepaymentMethod.equalInstallment),
                        (String(localized: "等额本金"), RepaymentMethod.equalPrincipal),
                    ],
                    selection: $viewModel.method
                )
                .onChange(of: viewModel.method) { viewModel.calculate() }

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
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(String(localized: "总利息"))
                                        .font(NumoTypography.caption)
                                        .foregroundStyle(NumoColors.textTertiary)
                                    Text(ExpressionFormatter.formatCurrency(result.totalInterest))
                                        .font(NumoTypography.bodyMedium)
                                        .foregroundStyle(NumoColors.danger)
                                }
                            }
                        }
                    }

                    // Schedule toggle
                    Button {
                        viewModel.showSchedule.toggle()
                    } label: {
                        HStack {
                            Text(String(localized: "还款明细"))
                                .font(NumoTypography.bodyMedium)
                                .foregroundStyle(NumoColors.textPrimary)
                            Spacer()
                            Image(systemName: viewModel.showSchedule ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12))
                                .foregroundStyle(NumoColors.textTertiary)
                        }
                        .padding(.horizontal, NumoSpacing.md)
                    }
                    .buttonStyle(.plain)

                    if viewModel.showSchedule {
                        LazyVStack(spacing: 0) {
                            ForEach(result.schedule) { entry in
                                HStack {
                                    Text("\(entry.month)")
                                        .font(NumoTypography.caption)
                                        .foregroundStyle(NumoColors.textTertiary)
                                        .frame(width: 30, alignment: .leading)
                                    Text(ExpressionFormatter.formatCurrency(entry.payment))
                                        .font(NumoTypography.caption)
                                        .frame(maxWidth: .infinity)
                                    Text(ExpressionFormatter.formatCurrency(entry.principal))
                                        .font(NumoTypography.caption)
                                        .frame(maxWidth: .infinity)
                                    Text(ExpressionFormatter.formatCurrency(entry.interest))
                                        .font(NumoTypography.caption)
                                        .foregroundStyle(NumoColors.textSecondary)
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.vertical, 4)
                                Divider()
                            }
                        }
                        .padding(.horizontal, NumoSpacing.md)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, NumoSpacing.md)
            .padding(.top, NumoSpacing.md)
        }
    }
}

#Preview {
    LoanCalculatorView()
}
