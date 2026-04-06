//
//  YoYCalculatorView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

/// Display-only YoY/MoM dashboard view. Keypad input managed by NumoTabView.
struct YoYCalculatorView: View {
    let viewModel: YoYCalculatorViewModel
    @Binding var activeField: ToolInputField

    var body: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 0)

            // MARK: — Anchor Card（本期 · 全行锚点）
            anchorCard

            // MARK: — Dual Cards（同比 + 环比）
            HStack(spacing: 12) {
                comparisonCard(
                    label: "同比",
                    subtitle: "去年同期",
                    valueText: viewModel.yoyPreviousText,
                    result: viewModel.yoyResult,
                    field: .secondary
                )
                comparisonCard(
                    label: "环比",
                    subtitle: "上一期",
                    valueText: viewModel.momPreviousText,
                    result: viewModel.momResult,
                    field: .tertiary
                )
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: — Anchor Card

    private var anchorCard: some View {
        let isActive = activeField == .primary
        return Button { activeField = .primary } label: {
            VStack(alignment: .leading, spacing: NumoSpacing.xxs) {
                Text("本期数据")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(formattedNumber(viewModel.currentValueText))
                    .font(.system(size: 56, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: viewModel.currentValueText)
            }
            .padding(.horizontal, NumoSpacing.md)
            .padding(.vertical, NumoSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(NumoColors.surfaceSecondary)
                    .shadow(
                        color: isActive ? .black.opacity(0.07) : .clear,
                        radius: 12, x: 0, y: 4
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }

    // MARK: — Comparison Card

    private func comparisonCard(
        label: String,
        subtitle: String,
        valueText: String,
        result: YoYResult?,
        field: ToolInputField
    ) -> some View {
        let isActive = activeField == field
        return Button { activeField = field } label: {
            VStack(alignment: .leading, spacing: 0) {

                // ── 上半：输入区 ──
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(label)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(isActive ? .primary : .secondary)
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Text(formattedNumber(valueText))
                        .font(.system(size: 22, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(isActive ? .primary : .secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.15), value: valueText)
                        .padding(.top, NumoSpacing.xxs)
                }
                .padding(.horizontal, NumoSpacing.sm)
                .padding(.top, NumoSpacing.sm)
                .padding(.bottom, NumoSpacing.xs)

                Divider().opacity(0.45)

                // ── 下半：结果区 ──
                VStack(alignment: .leading, spacing: 2) {
                    if let result {
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
                            // draw-on：趋势变化时 .id 强制重建视图，触发 transition；
                            // 以箭头"尾部"为 anchor 缩放至点再展开，模拟笔触描绘效果。
                            let anchor: UnitPoint = result.trend == .up   ? .bottomLeading
                                                  : result.trend == .down ? .topLeading
                                                  : .leading
                            Image(systemName: result.trend.icon)
                                .font(.system(size: 15, weight: .bold))
                                .id(result.trend)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.01, anchor: anchor)
                                        .combined(with: .opacity),
                                    removal: .scale(scale: 0.01, anchor: anchor)
                                        .combined(with: .opacity)
                                ))

                            Text(ExpressionFormatter.formatPercent(result.percentageChange))
                                .font(.system(size: 34, weight: .bold, design: .rounded).monospacedDigit())
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .contentTransition(.numericText())
                        }
                        .foregroundStyle(result.trend.color)
                        .animation(
                            .spring(response: 0.38, dampingFraction: 0.72),
                            value: result.percentageChange
                        )
                        .animation(
                            .spring(response: 0.44, dampingFraction: 0.68),
                            value: result.trend
                        )

                        Text(ExpressionFormatter.formatSigned(result.absoluteChange))
                            .font(.system(size: 11, design: .rounded).monospacedDigit())
                            .foregroundStyle(.tertiary)
                            .contentTransition(.numericText())
                            .animation(
                                .spring(response: 0.38, dampingFraction: 0.72),
                                value: result.absoluteChange
                            )
                    } else {
                        Text("—")
                            .font(.system(size: 34, weight: .thin, design: .rounded))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal, NumoSpacing.sm)
                .padding(.vertical, NumoSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.spring(response: 0.38, dampingFraction: 0.72), value: result == nil)
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(NumoColors.surfaceSecondary)
                    .shadow(
                        color: isActive ? .black.opacity(0.07) : .clear,
                        radius: 12, x: 0, y: 4
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }

    // MARK: — Thousands Separator

    private func formattedNumber(_ text: String) -> String {
        guard !text.isEmpty else { return "0" }
        let parts = text.split(separator: ".", maxSplits: 1)
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
