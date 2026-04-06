//
//  ChineseUppercaseView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

/// Display-only Chinese uppercase view. Keypad input managed by NumoTabView.
struct ChineseUppercaseView: View {
    let viewModel: ChineseUppercaseViewModel
    @State private var showCopied = false

    var body: some View {
        VStack(spacing: NumoSpacing.lg) {
            Spacer()

            // Input amount display
            Text(viewModel.inputAmount.isEmpty ? "0" : viewModel.inputAmount)
                .font(NumoTypography.monoDisplayLarge)
                .foregroundStyle(NumoColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: viewModel.inputAmount)

            // Result - always visible
            NumoCard {
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    HStack {
                        Text(String(localized: "人民币大写"))
                            .font(NumoTypography.bodySmall)
                            .foregroundStyle(NumoColors.textSecondary)
                        Spacer()
                        if showCopied {
                            Text(String(localized: "已复制"))
                                .font(NumoTypography.caption)
                                .foregroundStyle(NumoColors.accentRed)
                                .transition(.opacity)
                        }
                    }

                    Text(viewModel.displayResult)
                        .font(NumoTypography.titleMedium)
                        .foregroundStyle(NumoColors.textPrimary)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.25), value: viewModel.displayResult)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onTapGesture {
                copyResult()
            }
            .onLongPressGesture {
                copyResult()
            }

            if viewModel.isOutOfRange {
                Text(String(localized: "超出支持范围"))
                    .font(NumoTypography.bodySmall)
                    .foregroundStyle(NumoColors.danger)
            }

            Spacer()
        }
    }

    private func copyResult() {
        guard !viewModel.displayResult.isEmpty else { return }
        PasteboardService.copy(viewModel.displayResult)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation { showCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showCopied = false }
        }
    }
}
