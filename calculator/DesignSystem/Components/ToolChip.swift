//
//  ToolChip.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct ToolChip: View {
    let tool: Tool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
            action()
        } label: {
            Text(tool.displayName)
                .font(isSelected ? NumoTypography.bodyMedium.weight(.semibold) : NumoTypography.bodyMedium)
                .foregroundStyle(isSelected ? NumoColors.chipSelectedText : NumoColors.chipDefaultText)
                .padding(.horizontal, NumoSpacing.md)
                .frame(height: 36)
                .background(
                    Capsule()
                        .fill(isSelected ? NumoColors.chipSelected : NumoColors.chipDefault)
                )
        }
        .buttonStyle(.plain)
        .animation(NumoAnimations.chipSelection, value: isSelected)
    }
}

#Preview {
    HStack(spacing: NumoSpacing.chipGap) {
        ToolChip(tool: .calculator, isSelected: true) {}
        ToolChip(tool: .currency, isSelected: false) {}
        ToolChip(tool: .uppercase, isSelected: false) {}
    }
    .padding()
}
