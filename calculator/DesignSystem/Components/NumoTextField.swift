//
//  NumoTextField.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct NumoTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .decimalPad
    var alignment: TextAlignment = .trailing

    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(title, text: $text)
            .font(NumoTypography.bodyLarge)
            .multilineTextAlignment(alignment)
            .keyboardType(keyboardType)
            .focused($isFocused)
            .padding(.horizontal, NumoSpacing.md)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(NumoColors.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isFocused ? NumoColors.divider : .clear, lineWidth: 1)
                    )
            )
    }
}

#Preview {
    NumoTextField(title: "输入金额", text: .constant("1,200"))
        .padding()
}
