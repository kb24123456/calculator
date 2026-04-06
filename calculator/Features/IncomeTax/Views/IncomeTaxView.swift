//
//  IncomeTaxView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct IncomeTaxView: View {
    @State private var viewModel = IncomeTaxViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: NumoSpacing.lg) {
                // Salary input
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    Text(String(localized: "税前月薪"))
                        .font(NumoTypography.bodySmall)
                        .foregroundStyle(NumoColors.textSecondary)
                    NumoTextField(title: String(localized: "输入税前月薪"), text: $viewModel.monthlySalaryText)
                        .onChange(of: viewModel.monthlySalaryText) { viewModel.calculate() }
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

                // Special deductions
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    Text(String(localized: "专项附加扣除（月）"))
                        .font(NumoTypography.bodySmall)
                        .foregroundStyle(NumoColors.textSecondary)
                    NumoTextField(title: "0", text: $viewModel.specialDeductionsText)
                        .onChange(of: viewModel.specialDeductionsText) { viewModel.calculate() }
                }

                // Result
                if let result = viewModel.result {
                    NumoCard {
                        VStack(spacing: NumoSpacing.sm) {
                            // After-tax salary (first month)
                            VStack(spacing: NumoSpacing.xxs) {
                                Text(String(localized: "税后月薪"))
                                    .font(NumoTypography.bodySmall)
                                    .foregroundStyle(NumoColors.textSecondary)
                                Text(ExpressionFormatter.formatCurrency(result.monthlyNetSalary[0]))
                                    .font(NumoTypography.monoDisplayMedium)
                                    .foregroundStyle(NumoColors.textPrimary)
                                    .contentTransition(.numericText())
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
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(String(localized: "五险一金"))
                                        .font(NumoTypography.caption)
                                        .foregroundStyle(NumoColors.textTertiary)
                                    Text(ExpressionFormatter.formatCurrency(result.monthlySocialInsurance))
                                        .font(NumoTypography.bodyMedium)
                                        .foregroundStyle(NumoColors.textPrimary)
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
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(String(localized: "有效税率"))
                                        .font(NumoTypography.caption)
                                        .foregroundStyle(NumoColors.textTertiary)
                                    Text("\(ExpressionFormatter.format(result.effectiveTaxRate))%")
                                        .font(NumoTypography.bodyMedium)
                                        .foregroundStyle(NumoColors.textPrimary)
                                }
                            }
                        }
                    }

                    // Monthly breakdown toggle
                    Button {
                        viewModel.showBreakdown.toggle()
                    } label: {
                        HStack {
                            Text(String(localized: "月度明细"))
                                .font(NumoTypography.bodyMedium)
                                .foregroundStyle(NumoColors.textPrimary)
                            Spacer()
                            Image(systemName: viewModel.showBreakdown ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12))
                                .foregroundStyle(NumoColors.textTertiary)
                        }
                        .padding(.horizontal, NumoSpacing.md)
                    }
                    .buttonStyle(.plain)

                    if viewModel.showBreakdown {
                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                Text(String(localized: "月"))
                                    .frame(width: 30, alignment: .leading)
                                Text(String(localized: "个税"))
                                    .frame(maxWidth: .infinity)
                                Text(String(localized: "到手"))
                                    .frame(maxWidth: .infinity)
                            }
                            .font(NumoTypography.caption)
                            .foregroundStyle(NumoColors.textTertiary)
                            .padding(.vertical, 4)

                            Divider()

                            ForEach(0..<12, id: \.self) { i in
                                HStack {
                                    Text("\(i + 1)")
                                        .frame(width: 30, alignment: .leading)
                                    Text(ExpressionFormatter.formatCurrency(result.monthlyTax[i]))
                                        .frame(maxWidth: .infinity)
                                    Text(ExpressionFormatter.formatCurrency(result.monthlyNetSalary[i]))
                                        .frame(maxWidth: .infinity)
                                }
                                .font(NumoTypography.caption)
                                .foregroundStyle(NumoColors.textPrimary)
                                .padding(.vertical, 4)

                                if i < 11 { Divider() }
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
    IncomeTaxView()
}
