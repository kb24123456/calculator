//
//  NumoSegmentedControl.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct NumoSegmentedControl<T: Hashable>: View {
    let options: [(label: String, value: T)]
    @Binding var selection: T

    var body: some View {
        HStack(spacing: NumoSpacing.xxs) {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]
                let isSelected = option.value == selection

                Button {
                    withAnimation(NumoAnimations.chipSelection) {
                        selection = option.value
                    }
                } label: {
                    Text(option.label)
                        .font(isSelected ? NumoTypography.bodyMedium.weight(.semibold) : NumoTypography.bodyMedium)
                        .foregroundStyle(isSelected ? NumoColors.textPrimary : NumoColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(isSelected ? NumoColors.surfaceSecondary : .clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(NumoSpacing.xxs)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(NumoColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(NumoColors.divider, lineWidth: 0.5)
                )
        )
    }
}

#Preview {
    NumoSegmentedControl(
        options: [("同比", 0), ("环比", 1)],
        selection: .constant(0)
    )
    .padding()
}
