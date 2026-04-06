//
//  CurrencyExchangeView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

/// Display-only currency exchange view. Keypad input managed by NumoTabView.
struct CurrencyExchangeView: View {
    @Bindable var viewModel: CurrencyExchangeViewModel

    @Namespace private var swapAnimation
    @State private var isSwapped = false
    @State private var swapRotation: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Source section
            currencySection(
                currency: isSwapped ? viewModel.targetCurrency : viewModel.sourceCurrency,
                amount: viewModel.sourceAmount.isEmpty ? "0" : viewModel.sourceAmount,
                isSource: true,
                matchedId: isSwapped ? "target" : "source",
                onSelect: { selected in
                    viewModel.sourceCurrency = selected
                    viewModel.convert()
                }
            )

            // Swap button
            swapButton
                .padding(.vertical, NumoSpacing.sm)

            // Target section
            currencySection(
                currency: isSwapped ? viewModel.sourceCurrency : viewModel.targetCurrency,
                amount: viewModel.convertedAmount.isEmpty ? "0" : viewModel.convertedAmount,
                isSource: false,
                matchedId: isSwapped ? "source" : "target",
                onSelect: { selected in
                    viewModel.targetCurrency = selected
                    viewModel.convert()
                }
            )

            Spacer()

            // Rate info - always visible with fixed height to prevent layout jumps
            rateInfoBar
                .frame(height: 20)
                .padding(.bottom, NumoSpacing.xs)

            // Quick currency chips
            quickCurrencyChips
                .padding(.bottom, NumoSpacing.xs)

            // Loading / Error
            if viewModel.isLoading {
                LoadingDot()
            }
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(NumoTypography.bodySmall)
                    .foregroundStyle(NumoColors.danger)
            }
        }
        .task {
            await viewModel.loadRates()
        }
    }

    // MARK: - Currency Section (pill + amount)

    private func currencySection(
        currency: CurrencyInfo,
        amount: String,
        isSource: Bool,
        matchedId: String,
        onSelect: @escaping (CurrencyInfo) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: NumoSpacing.xs) {
            currencyPill(currency: currency, onSelect: onSelect)
                .matchedGeometryEffect(id: matchedId, in: swapAnimation)

            Text(amount)
                .font(NumoTypography.monoDisplayLarge)
                .foregroundStyle(isSource ? NumoColors.textPrimary : NumoColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: amount)
        }
    }

    // MARK: - Swap Button

    private var swapButton: some View {
        HStack {
            Spacer()
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.8)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isSwapped.toggle()
                    swapRotation += 180
                }
                viewModel.swapCurrencies()
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(NumoColors.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle().fill(NumoColors.surfaceSecondary)
                    )
                    .rotationEffect(.degrees(swapRotation))
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }

    // MARK: - Rate Info Bar (fixed height, no layout jumps)

    private var rateInfoBar: some View {
        HStack(spacing: NumoSpacing.xxs) {
            Text(viewModel.rateInfo)
                .font(NumoTypography.caption)
                .foregroundStyle(NumoColors.textTertiary)

            if let lastUpdated = viewModel.lastUpdated {
                Text("·")
                    .font(NumoTypography.caption)
                    .foregroundStyle(NumoColors.textTertiary)
                Text(lastUpdated.relativeDescription)
                    .font(NumoTypography.caption)
                    .foregroundStyle(NumoColors.textTertiary)
            }

            Spacer()
        }
    }

    // MARK: - Quick Currency Chips

    private var quickCurrencyChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: NumoSpacing.xs) {
                ForEach(CurrencyInfo.quickCurrencies, id: \.self) { code in
                    if let currency = CurrencyInfo.find(code) {
                        let isSelected = viewModel.targetCurrency.code == code
                        Button {
                            viewModel.targetCurrency = currency
                            viewModel.convert()
                        } label: {
                            HStack(spacing: NumoSpacing.xxs) {
                                Text(currency.flag)
                                    .font(.system(size: 14))
                                    .frame(width: 22, height: 22)
                                    .background(Circle().fill(NumoColors.surface.opacity(0.3)))
                                    .clipShape(Circle())
                                Text(currency.localizedName)
                                    .font(NumoTypography.bodySmall)
                            }
                            .foregroundStyle(isSelected ? .white : NumoColors.chipDefaultText)
                            .padding(.horizontal, NumoSpacing.sm)
                            .frame(height: 34)
                            .background(
                                Capsule().fill(isSelected ? NumoColors.accentRed : NumoColors.chipDefault)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Currency Pill

    private func currencyPill(currency: CurrencyInfo, onSelect: @escaping (CurrencyInfo) -> Void) -> some View {
        Menu {
            ForEach(CurrencyInfo.all) { c in
                Button {
                    onSelect(c)
                } label: {
                    Text("\(c.flag) \(c.code) - \(c.localizedName)")
                }
            }
        } label: {
            HStack(spacing: NumoSpacing.xs) {
                // Flag in circle
                Text(currency.flag)
                    .font(.system(size: 22))
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(NumoColors.surfaceSecondary))
                    .clipShape(Circle())

                Text("\(currency.symbol) \(currency.code)")
                    .font(NumoTypography.bodyMedium.weight(.medium))
                    .foregroundStyle(NumoColors.textPrimary)

                Text(currency.localizedName)
                    .font(NumoTypography.bodySmall)
                    .foregroundStyle(NumoColors.textSecondary)

                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
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
