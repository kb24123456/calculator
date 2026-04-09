//
//  UnitConverterView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI
import Combine

/// Display-only unit converter view.
/// Category switching lives in the global HUD Menu (NumoTabView).
/// Keypad input managed by NumoTabView.
struct UnitConverterView: View {
    @Bindable var viewModel: UnitConverterViewModel

    @State private var swapRotation: Double = 0
    @State private var sourceSlide: CGFloat = 0
    @State private var targetSlide: CGFloat = 0
    @State private var cursorVisible: Bool = true

    var body: some View {
        VStack(spacing: NumoSpacing.md) {
            Spacer(minLength: 0)

            // MARK: - Hero Card
            ZStack(alignment: .center) {
                VStack(spacing: 0) {
                    // Source half
                    ZStack {
                        halfContent(
                            unit: viewModel.sourceUnit,
                            amount: sourceDisplayAmount,
                            isSource: true,
                            isActive: viewModel.activeInput == .source
                        ) { selected in
                            viewModel.sourceUnit = selected
                            viewModel.convert()
                        }
                        .offset(y: sourceSlide)
                    }
                    .frame(maxWidth: .infinity, minHeight: 130)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.setActive(.source)
                        }
                    }

                    Divider()

                    // Target half
                    ZStack {
                        halfContent(
                            unit: viewModel.targetUnit,
                            amount: targetDisplayAmount,
                            isSource: false,
                            isActive: viewModel.activeInput == .target
                        ) { selected in
                            viewModel.targetUnit = selected
                            viewModel.convert()
                        }
                        .offset(y: targetSlide)
                    }
                    .frame(maxWidth: .infinity, minHeight: 130)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.setActive(.target)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(NumoColors.surfaceSecondary)
                )

                swapButton
            }

            Spacer(minLength: 0)
        }
        .onReceive(Timer.publish(every: 0.53, on: .main, in: .common).autoconnect()) { _ in
            cursorVisible.toggle()
        }
    }

    // MARK: - Display amount helpers

    private var sourceDisplayAmount: String {
        switch viewModel.activeInput {
        case .source: return viewModel.sourceValue.isEmpty ? "0" : viewModel.sourceValue
        case .target: return viewModel.sourceResult.isEmpty ? "0" : viewModel.sourceResult
        }
    }

    private var targetDisplayAmount: String {
        switch viewModel.activeInput {
        case .source: return viewModel.convertedValue.isEmpty ? "0" : viewModel.convertedValue
        case .target: return viewModel.targetValue.isEmpty ? "0" : viewModel.targetValue
        }
    }

    // MARK: - Half Content

    private func halfContent(
        unit: UnitDefinition,
        amount: String,
        isSource: Bool,
        isActive: Bool,
        onSelect: @escaping (UnitDefinition) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            unitSelector(unit: unit, onSelect: onSelect)

            Spacer(minLength: NumoSpacing.xs)

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

                // Faint unit symbol suffix
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

                // Blinking cursor
                if isActive {
                    Text("|")
                        .font(
                            isSource
                                ? .system(size: 64, weight: .light, design: .rounded)
                                : .system(size: 52, weight: .light, design: .rounded)
                        )
                        .foregroundStyle(
                            (isSource ? NumoColors.textPrimary : NumoColors.textSecondary)
                                .opacity(0.5)
                        )
                        .opacity(cursorVisible ? 1 : 0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, NumoSpacing.xl)
        .padding(.vertical, NumoSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Unit Selector

    private func unitSelector(
        unit: UnitDefinition,
        onSelect: @escaping (UnitDefinition) -> Void
    ) -> some View {
        Menu {
            ForEach(viewModel.selectedCategory.units) { u in
                Button { onSelect(u) } label: {
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

    // MARK: - Swap Button

    private var swapButton: some View {
        Button { doSwap() } label: {
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

    private func doSwap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.8)
        withAnimation(.easeIn(duration: 0.11)) {
            sourceSlide = 20; targetSlide = -20
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
            viewModel.swapUnits()
            withAnimation(.spring(response: 0.44, dampingFraction: 0.56)) {
                sourceSlide = 0; swapRotation += 180
            }
            withAnimation(.spring(response: 0.50, dampingFraction: 0.52).delay(0.05)) {
                targetSlide = 0
            }
        }
    }
}
