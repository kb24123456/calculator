//
//  ChineseUppercaseView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct ChineseUppercaseView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ChineseUppercaseViewModel()

    var body: some View {
        VStack(spacing: NumoSpacing.lg) {
            Spacer()

            // Input
            NumoTextField(title: String(localized: "输入金额"), text: $viewModel.inputAmount)
                .onChange(of: viewModel.inputAmount) {
                    viewModel.convert()
                }

            // Result
            if !viewModel.uppercaseResult.isEmpty {
                NumoCard {
                    VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                        Text(String(localized: "人民币大写"))
                            .font(NumoTypography.bodySmall)
                            .foregroundStyle(NumoColors.textSecondary)

                        Text(viewModel.uppercaseResult)
                            .font(NumoTypography.titleMedium)
                            .foregroundStyle(NumoColors.textPrimary)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onTapGesture {
                    PasteboardService.copy(viewModel.uppercaseResult)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }

            if viewModel.isOutOfRange {
                Text(String(localized: "超出支持范围"))
                    .font(NumoTypography.bodySmall)
                    .foregroundStyle(NumoColors.danger)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, NumoSpacing.md)
        .onAppear {
            viewModel.updateFromLastResult(appState.lastResult)
        }
    }
}

#Preview {
    ChineseUppercaseView()
        .environment(AppState())
}
