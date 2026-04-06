//
//  NumoCard.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct NumoCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(NumoSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(NumoColors.surfaceSecondary)
            )
    }
}

#Preview {
    NumoCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Result")
                .font(NumoTypography.bodySmall)
                .foregroundStyle(NumoColors.textSecondary)
            Text("¥1,460.00")
                .font(NumoTypography.titleLarge)
                .foregroundStyle(NumoColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding()
}
