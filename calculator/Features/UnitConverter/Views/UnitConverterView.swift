//
//  UnitConverterView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

/// Display-only unit converter view.
/// Category switching lives in the global HUD Menu (NumoTabView).
/// Keypad input managed by NumoTabView.
struct UnitConverterView: View {
    @Bindable var viewModel: UnitConverterViewModel

    @State private var swapRotation: Double = 0
    @State private var sourceSlide: CGFloat = 0
    @State private var targetSlide: CGFloat = 0

    var body: some View {
        VStack(spacing: NumoSpacing.md) {
            Spacer(minLength: 0)

            // MARK: - Hero Card (mirrors CurrencyExchangeView layout)
            ZStack(alignment: .center) {
                VStack(spacing: 0) {
                    // Source half — clipped so slide stays within bounds
                    ZStack {
                        halfContent(
                            unit: viewModel.sourceUnit,
                            amount: viewModel.sourceValue.isEmpty ? "0" : viewModel.sourceValue,
                            isSource: true
                        ) { selected in
                            viewModel.sourceUnit = selected
                            viewModel.convert()
                        }
                        .offset(y: sourceSlide)
                    }
                    .frame(maxWidth: .infinity, minHeight: 130)
                    .clipped()

                    Divider()

                    // Target half — clipped so slide stays within bounds
                    ZStack {
                        halfContent(
                            unit: viewModel.targetUnit,
                            amount: viewModel.convertedValue.isEmpty ? "0" : viewModel.convertedValue,
                            isSource: false
                        ) { selected in
                            viewModel.targetUnit = selected
                            viewModel.convert()
                        }
                        .offset(y: targetSlide)
                    }
                    .frame(maxWidth: .infinity, minHeight: 130)
                    .clipped()
                }
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(NumoColors.surfaceSecondary)
                )

                // Floating swap button centered on Divider
                swapButton
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Half Content (selector + faint symbol + big amount)

    private func halfContent(
        unit: UnitDefinition,
        amount: String,
        isSource: Bool,
        onSelect: @escaping (UnitDefinition) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Unit selector: 📐 米  m  ˅
            unitSelector(unit: unit, onSelect: onSelect)

            Spacer(minLength: NumoSpacing.xs)

            // Amount row: faint symbol prefix + big number
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(amount)
                    .font(
                        isSource
                            ? .system(size: 64, weight: .semibold, design: .rounded).monospacedDigit()
                            : .system(size: 52, weight: .medium, design: .rounded).monospacedDigit()
                    )
                    .foregroundStyle(isSource ? NumoColors.textPrimary : NumoColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.38)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: amount)

                Text(unit.symbol)
                    .font(.system(
                        size: isSource ? 34 : 28,
                        weight: .light,
                        design: .rounded
                    ))
                    .foregroundStyle(
                        (isSource ? NumoColors.textPrimary : NumoColors.textSecondary)
                            .opacity(0.14)
                    )
                    .animation(.easeInOut(duration: 0.2), value: unit.symbol)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, NumoSpacing.xl)
        .padding(.vertical, NumoSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Unit Selector (SF Symbol + name + symbol + chevron)

    private func unitSelector(
        unit: UnitDefinition,
        onSelect: @escaping (UnitDefinition) -> Void
    ) -> some View {
        Menu {
            ForEach(viewModel.selectedCategory.units) { u in
                Button {
                    onSelect(u)
                } label: {
                    Text("\(u.nameKey)  \(u.symbol)")
                }
            }
        } label: {
            HStack(spacing: NumoSpacing.xs) {
                Image(systemName: viewModel.selectedCategory.sfSymbol)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(NumoColors.textSecondary)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.selectedCategory.sfSymbol)
                Text(unit.nameKey)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(NumoColors.textPrimary)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: unit.nameKey)
                Text(unit.symbol)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(NumoColors.textTertiary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(NumoColors.textTertiary)
            }
        }
    }

    // MARK: - Swap Button with rotation

    private var swapButton: some View {
        Button {
            doSwap()
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(NumoColors.textSecondary)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(NumoColors.surface)
                        .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 2)
                )
                .rotationEffect(.degrees(swapRotation))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Staggered spring swap (identical physics to CurrencyExchangeView)

    private func doSwap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.8)

        // Phase 1: both halves slide toward the divider
        withAnimation(.easeIn(duration: 0.11)) {
            sourceSlide = 20
            targetSlide = -20
        }

        // Phase 2: swap data, then spring each half back with offset timing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
            viewModel.swapUnits()

            // Source springs back — leads
            withAnimation(.spring(response: 0.44, dampingFraction: 0.56)) {
                sourceSlide = 0
                swapRotation += 180
            }
            // Target springs back — follows with slight delay
            withAnimation(.spring(response: 0.50, dampingFraction: 0.52).delay(0.05)) {
                targetSlide = 0
            }
        }
    }
}
