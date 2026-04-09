//
//  ChineseUppercaseView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI
import Combine

/// Display-only Chinese uppercase view. Keypad input managed by NumoTabView.
/// 长按数字区 → 粘贴；长按结果区 → 复制（由 NumoTabView 全局处理）。
struct ChineseUppercaseView: View {
    let viewModel: ChineseUppercaseViewModel

    @State private var cursorVisible: Bool = true

    private var isEmpty: Bool { viewModel.inputAmount.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Spacer()

            // MARK: — Input Area
            // 空态：灰色休眠；有值：深黑激活。
            // 右对齐，千位分隔符，48pt Rounded Semibold Mono。
            // 长按触发粘贴，优先级高于外层全局长按复制。
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Spacer(minLength: 0)
                Text(formattedInput)
                    .font(.system(size: 48, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(isEmpty ? Color.secondary.opacity(0.35) : Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: viewModel.inputAmount)
                Text("|")
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .foregroundStyle(Color.primary.opacity(0.45))
                    .opacity(cursorVisible ? 1 : 0)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .onLongPressGesture(minimumDuration: 0.4) {
                pasteFromClipboard()
            }

            // MARK: — Paste Hint
            HStack(spacing: 4) {
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 10))
                Text("长按数字可粘贴")
                    .font(.system(size: 11, design: .rounded))
            }
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, NumoSpacing.xxs)
            .padding(.bottom, NumoSpacing.lg)

            // MARK: — Gradient Divider
            // 从两端向中心渐入，赋予悬浮感，避免硬线割裂排版节奏。
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
            .padding(.bottom, NumoSpacing.lg)

            // MARK: — Result Label（视觉依靠锚点）
            // caption2 小标签在巨型汉字正上方提供"标注感"，建立阶梯视觉层级。
            Text("人民币大写")
                .font(.caption2)
                .foregroundStyle(isEmpty ? Color.secondary.opacity(0.4) : Color.secondary)
                .animation(.easeInOut(duration: 0.25), value: isEmpty)
                .padding(.bottom, NumoSpacing.xxs)

            // MARK: — Result Area（人民币大写）
            // 空态：48pt Regular Tertiary，安静休眠。
            // 有值：52pt Semibold Serif Primary，高级感跃然而出。
            // minimumScaleFactor 防止超长大写被截断。
            Group {
                if viewModel.isOutOfRange {
                    Text("超出支持范围")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(NumoColors.danger)
                } else if isEmpty {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("零圆整")
                            .font(.system(size: 48, weight: .regular))
                            .foregroundStyle(.tertiary)
                        Image(systemName: "square.on.square")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(Color(.systemGray4))
                    }
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(viewModel.displayResult)
                            .font(.system(size: 52, weight: .semibold, design: .serif))
                            .foregroundStyle(.primary)
                            .minimumScaleFactor(0.4)
                            .lineLimit(1)
                        Image(systemName: "square.on.square")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(Color(.systemGray3))
                            .layoutPriority(-1)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.25), value: viewModel.displayResult)
            .animation(.easeInOut(duration: 0.25), value: isEmpty)

            Spacer()
        }
        .onReceive(Timer.publish(every: 0.53, on: .main, in: .common).autoconnect()) { _ in
            cursorVisible.toggle()
        }
    }

    // MARK: — Thousands Separator Formatting

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

    // MARK: — Paste Action

    private func pasteFromClipboard() {
        guard let text = UIPasteboard.general.string else { return }
        var cleaned = ""
        var hasDecimal = false
        for char in text {
            if char.isNumber {
                cleaned.append(char)
            } else if (char == "." || char == "。") && !hasDecimal {
                cleaned.append(".")
                hasDecimal = true
            }
        }
        guard !cleaned.isEmpty else { return }
        viewModel.inputAmount = cleaned
        viewModel.convert()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
