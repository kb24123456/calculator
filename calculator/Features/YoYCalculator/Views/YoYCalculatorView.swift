//
//  YoYCalculatorView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

/// Display-only YoY/MoM view. Keypad input managed by NumoTabView.
struct YoYCalculatorView: View {
    let viewModel: YoYCalculatorViewModel
    @Binding var activeField: ToolInputField

    var body: some View {
        VStack(spacing: NumoSpacing.md) {
            Spacer()

            // Current value - full width
            inputField(
                label: String(localized: "本期值"),
                value: viewModel.currentValueText,
                isActive: activeField == .primary
            ) {
                activeField = .primary
            }

            // YoY + MoM comparison values side by side
            HStack(spacing: NumoSpacing.sm) {
                inputField(
                    label: String(localized: "同比比较值"),
                    value: viewModel.yoyPreviousText,
                    isActive: activeField == .secondary
                ) {
                    activeField = .secondary
                }

                inputField(
                    label: String(localized: "环比比较值"),
                    value: viewModel.momPreviousText,
                    isActive: activeField == .tertiary
                ) {
                    activeField = .tertiary
                }
            }

            // Dual results
            if viewModel.yoyResult != nil || viewModel.momResult != nil {
                HStack(spacing: NumoSpacing.sm) {
                    if let yoy = viewModel.yoyResult {
                        resultCard(title: String(localized: "同比变化"), result: yoy)
                            .transition(.scale(scale: 0.9).combined(with: .opacity))
                    }
                    if let mom = viewModel.momResult {
                        resultCard(title: String(localized: "环比变化"), result: mom)
                            .transition(.scale(scale: 0.9).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.yoyResult?.percentageChange)
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.momResult?.percentageChange)
            }

            Spacer()
        }
    }

    // MARK: - Result Card

    private func resultCard(title: String, result: YoYResult) -> some View {
        NumoCard {
            VStack(spacing: NumoSpacing.xs) {
                Text(title)
                    .font(NumoTypography.caption)
                    .foregroundStyle(NumoColors.textTertiary)

                TrendIndicator(
                    trend: result.trend,
                    value: ExpressionFormatter.formatPercent(result.percentageChange)
                )

                Text(ExpressionFormatter.formatSigned(result.absoluteChange))
                    .font(NumoTypography.bodySmall)
                    .foregroundStyle(NumoColors.textSecondary)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Tappable input field

    private func inputField(label: String, value: String, isActive: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: NumoSpacing.xxs) {
                Text(label)
                    .font(NumoTypography.caption)
                    .foregroundStyle(NumoColors.textTertiary)
                Text(value.isEmpty ? "0" : value)
                    .font(NumoTypography.monoTitleLarge)
                    .foregroundStyle(isActive ? NumoColors.textPrimary : NumoColors.textSecondary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: value)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, NumoSpacing.md)
            .padding(.vertical, NumoSpacing.sm)
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
