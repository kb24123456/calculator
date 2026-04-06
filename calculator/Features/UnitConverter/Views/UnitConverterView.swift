//
//  UnitConverterView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct UnitConverterView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = UnitConverterViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: NumoSpacing.lg) {
                // Category picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: NumoSpacing.xs) {
                        ForEach(UnitCategory.allCases) { category in
                            ToolChip(
                                tool: Tool.unit,
                                isSelected: viewModel.selectedCategory == category,
                                action: { viewModel.selectCategory(category) }
                            )
                            .overlay {
                                // Override chip label
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
                }

                // Source input
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    unitPicker(selected: $viewModel.sourceUnit, units: viewModel.selectedCategory.units)
                    NumoTextField(title: "0", text: $viewModel.sourceValue)
                        .onChange(of: viewModel.sourceValue) { viewModel.convert() }
                }

                // Swap button
                Button { viewModel.swapUnits() } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(NumoColors.accentRed)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(NumoColors.surfaceSecondary))
                }
                .buttonStyle(.plain)

                // Target
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    unitPicker(selected: $viewModel.targetUnit, units: viewModel.selectedCategory.units)

                    if !viewModel.convertedValue.isEmpty {
                        Text(viewModel.convertedValue)
                            .font(NumoTypography.monoDisplayMedium)
                            .foregroundStyle(NumoColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, NumoSpacing.md)
                            .contentTransition(.numericText())
                    }
                }

                Spacer()
            }
            .padding(.horizontal, NumoSpacing.md)
            .padding(.top, NumoSpacing.md)
        }
        .onAppear {
            viewModel.updateFromLastResult(appState.lastResult)
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
                Text("\(selected.wrappedValue.nameKey)")
                    .font(NumoTypography.bodyMedium)
                    .foregroundStyle(NumoColors.textPrimary)
                Text(selected.wrappedValue.symbol)
                    .font(NumoTypography.bodySmall)
                    .foregroundStyle(NumoColors.textSecondary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
                    .foregroundStyle(NumoColors.textTertiary)
            }
            .padding(.horizontal, NumoSpacing.md)
            .padding(.vertical, NumoSpacing.xs)
        }
    }
}

#Preview {
    UnitConverterView()
        .environment(AppState())
}
