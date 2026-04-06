//
//  ResultBanner.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct ResultBanner: View {
    let label: String
    let value: String
    var valueFont: Font = NumoTypography.monoTitleLarge
    var onCopy: (() -> Void)?

    @State private var showCopied = false

    var body: some View {
        HStack {
            Text(label)
                .font(NumoTypography.bodyMedium)
                .foregroundStyle(NumoColors.textSecondary)

            Spacer()

            Text(value)
                .font(valueFont)
                .foregroundStyle(NumoColors.textPrimary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, NumoSpacing.md)
        .padding(.vertical, NumoSpacing.sm)
        .background(NumoColors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onTapGesture {
            UIPasteboard.general.string = value
            showCopied = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onCopy?()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showCopied = false
            }
        }
        .overlay(alignment: .trailing) {
            if showCopied {
                Label(String(localized: "已复制"), systemImage: "checkmark")
                    .font(NumoTypography.caption)
                    .foregroundStyle(NumoColors.success)
                    .padding(.horizontal, NumoSpacing.xs)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: showCopied)
            }
        }
    }
}

#Preview {
    ResultBanner(label: "结果", value: "¥1,460.00")
        .padding()
}
