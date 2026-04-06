//
//  UnitConverterView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

/// Display-only unit converter view. Keypad input managed by NumoTabView.
struct UnitConverterView: View {
    @Bindable var viewModel: UnitConverterViewModel

    var body: some View {
        VStack(spacing: NumoSpacing.md) {
            // Category picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: NumoSpacing.xs) {
                    ForEach(UnitCategory.allCases) { category in
                        Button { viewModel.selectCategory(category) } label: {
                            Text(category.displayName)
                                .font(viewModel.selectedCategory == category ? NumoTypography.bodyMedium.weight(.semibold) : NumoTypography.bodyMedium)
                                .foregroundStyle(viewModel.selectedCategory == category ? NumoColors.chipSelectedText : NumoColors.chipDefaultText)
                                .padding(.horizontal, NumoSpacing.md)
                                .frame(height: 36)
                                .background(
                                    Capsule()
                                        .fill(viewModel.selectedCategory == category ? NumoColors.chipSelected : NumoColors.chipDefault)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Spacer()

            // Source unit + value
            VStack(alignment: .trailing, spacing: NumoSpacing.xs) {
                unitPicker(selected: $viewModel.sourceUnit, units: viewModel.selectedCategory.units)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(viewModel.sourceValue.isEmpty ? "0" : viewModel.sourceValue)
                    .font(NumoTypography.monoDisplayLarge)
                    .foregroundStyle(NumoColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: viewModel.sourceValue)
            }

            // Swap button
            HStack {
                Spacer()
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
                    viewModel.swapUnits()
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(NumoColors.accentRed)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(NumoColors.surfaceSecondary))
                }
                .buttonStyle(.plain)
                Spacer()
            }

            // Target unit + converted value
            VStack(alignment: .trailing, spacing: NumoSpacing.xs) {
                unitPicker(selected: $viewModel.targetUnit, units: viewModel.selectedCategory.units)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !viewModel.convertedValue.isEmpty {
                    Text(viewModel.convertedValue)
                        .font(NumoTypography.monoDisplayLarge)
                        .foregroundStyle(NumoColors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .contentTransition(.numericText())
                }
            }

            Spacer()
        }
    }

    private func unitPicker(selected: Binding<UnitDefinition>, units: [UnitDefinition]) -> some View {
        Menu {
            ForEach(units) { unit in
                Button {
                    selected.wrappedValue = unit
                    viewModel.convert()
                } label: {
                    Text("\(unit.nameKey) (\(unit.symbol))")
                }
            }
        } label: {
            HStack {
                Text(selected.wrappedValue.nameKey)
                    .font(NumoTypography.bodyMedium)
                    .foregroundStyle(NumoColors.textPrimary)
                Text(selected.wrappedValue.symbol)
                    .font(NumoTypography.bodySmall)
                    .foregroundStyle(NumoColors.textSecondary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundStyle(NumoColors.textTertiary)
            }
            .padding(.horizontal, NumoSpacing.sm)
            .padding(.vertical, NumoSpacing.xs)
            .background(
                Capsule().fill(NumoColors.surfaceSecondary)
            )
        }
    }
}
