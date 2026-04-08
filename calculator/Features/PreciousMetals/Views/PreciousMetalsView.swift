//
//  PreciousMetalsView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/9.
//

import SwiftUI

/// Display-only precious metals view.
/// Mode switching lives in the global HUD (NumoTabView).
/// Keypad input managed by NumoTabView.
struct PreciousMetalsView: View {
    let viewModel: PreciousMetalsViewModel

    private static let goldColor = Color(red: 0.85, green: 0.65, blue: 0.13)
    private static let silverColor = Color(red: 0.58, green: 0.60, blue: 0.63)

    private var isEmpty: Bool { viewModel.inputAmount.isEmpty }

    var body: some View {
        Group {
            switch viewModel.mode {
            case .purchase:
                purchaseBody
            case .salary:
                salaryBody
            }
        }
        .task {
            await viewModel.loadPrices()
        }
    }

    // MARK: - Purchase Mode

    private var purchaseBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            // Input amount
            Text(formattedInput)
                .font(.system(size: 48, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(isEmpty ? Color.secondary.opacity(0.35) : Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.15), value: viewModel.inputAmount)

            // Price hint
            HStack(spacing: 4) {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.6)
                    Text("行情获取中…")
                        .font(.system(size: 11, design: .rounded))
                } else if viewModel.metalPrice.isLive {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.system(size: 10))
                    Text("Au ¥\(ExpressionFormatter.format(viewModel.metalPrice.goldPerGram))/g · Ag ¥\(ExpressionFormatter.format(viewModel.metalPrice.silverPerGram))/g")
                        .font(.system(size: 11, design: .rounded).monospacedDigit())
                        .contentTransition(.numericText())
                } else {
                    Image(systemName: "info.circle")
                        .font(.system(size: 10))
                    Text("Au ¥\(ExpressionFormatter.format(viewModel.metalPrice.goldPerGram))/g（参考价）")
                        .font(.system(size: 11, design: .rounded))
                }
            }
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, NumoSpacing.xxs)
            .padding(.bottom, NumoSpacing.lg)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
            .animation(.easeInOut(duration: 0.2), value: viewModel.metalPrice.isLive)

            // Gradient divider
            gradientDivider
                .padding(.bottom, NumoSpacing.lg)

            // Gold row
            metalRow(
                icon: "circle.fill",
                iconColor: Self.goldColor,
                label: "黄金",
                symbol: "Au",
                amount: viewModel.goldGrams,
                unit: "克"
            )
            .padding(.bottom, NumoSpacing.md)

            // Silver row
            metalRow(
                icon: "circle.fill",
                iconColor: Self.silverColor,
                label: "白银",
                symbol: "Ag",
                amount: viewModel.silverGrams,
                unit: "克"
            )

            Spacer()
        }
    }

    // MARK: - Salary Mode

    private var salaryBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            // Label
            Text("月薪")
                .font(.caption2)
                .foregroundStyle(isEmpty ? Color.secondary.opacity(0.4) : Color.secondary)
                .animation(.easeInOut(duration: 0.25), value: isEmpty)
                .padding(.bottom, NumoSpacing.xxs)

            // Input amount
            Text(formattedInput)
                .font(.system(size: 48, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(isEmpty ? Color.secondary.opacity(0.35) : Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.15), value: viewModel.inputAmount)
                .padding(.bottom, NumoSpacing.lg)

            // Gradient divider
            gradientDivider
                .padding(.bottom, NumoSpacing.lg)

            // Rank result
            if let rank = viewModel.matchedRank {
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    // Grade badge
                    Text(rank.dynasty + " · " + rank.grade)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(NumoColors.textSecondary)
                        .padding(.horizontal, NumoSpacing.sm)
                        .padding(.vertical, NumoSpacing.xxxs)
                        .background(
                            Capsule()
                                .fill(NumoColors.surfaceSecondary)
                        )

                    // Rank title
                    Text(rank.title)
                        .font(.system(size: 52, weight: .semibold, design: .serif))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .contentTransition(.numericText())

                    // Description
                    Text(rank.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(NumoColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.push(from: .bottom).combined(with: .opacity))
            } else {
                // Empty state
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    Text("—")
                        .font(.system(size: 52, weight: .regular))
                        .foregroundStyle(.tertiary)
                    Text("输入月薪，查看对应的古代官职")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.push(from: .top).combined(with: .opacity))
            }

            Spacer()
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.matchedRank?.title)
    }

    // MARK: - Components

    private func metalRow(
        icon: String,
        iconColor: Color,
        label: String,
        symbol: String,
        amount: String,
        unit: String
    ) -> some View {
        HStack(spacing: NumoSpacing.sm) {
            // Icon + label
            HStack(spacing: NumoSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(iconColor)
                Text(label)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(NumoColors.textPrimary)
                Text(symbol)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(NumoColors.textTertiary)
            }

            Spacer()

            // Amount
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(amount.isEmpty ? "—" : amount)
                    .font(.system(size: 34, weight: .medium, design: .rounded).monospacedDigit())
                    .foregroundStyle(amount.isEmpty ? Color.secondary.opacity(0.35) : NumoColors.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: amount)
                Text(unit)
                    .font(.system(size: 16, weight: .light, design: .rounded))
                    .foregroundStyle(NumoColors.textTertiary)
            }
        }
    }

    private var gradientDivider: some View {
        LinearGradient(
            colors: [
                .clear,
                Color.primary.opacity(isEmpty ? 0.06 : 0.12),
                Color.primary.opacity(isEmpty ? 0.06 : 0.12),
                .clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
        .animation(.easeInOut(duration: 0.3), value: isEmpty)
    }

    // MARK: - Formatting

    private var formattedInput: String {
        guard !viewModel.inputAmount.isEmpty else { return "0" }
        let raw = viewModel.inputAmount
        let parts = raw.split(separator: ".", maxSplits: 1)
        let intStr = String(parts[0])
        let decStr = parts.count > 1 ? "." + String(parts[1]) : ""

        var grouped = ""
        for (i, char) in intStr.reversed().enumerated() {
            if i > 0 && i % 3 == 0 { grouped = "," + grouped }
            grouped = String(char) + grouped
        }
        return grouped + decStr
    }
}
