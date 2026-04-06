//
//  CurrencyExchangeView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct CurrencyExchangeView: View {
    @Bindable var viewModel: CurrencyExchangeViewModel

    @State private var swapRotation: Double = 0
    @State private var sourceSlide: CGFloat = 0
    @State private var targetSlide: CGFloat = 0

    var body: some View {
        VStack(spacing: NumoSpacing.md) {
            Spacer(minLength: 0)

            // MARK: - Unified Exchange Card
            ZStack(alignment: .center) {
                VStack(spacing: 0) {
                    // Source half — clipped so slide stays within bounds
                    ZStack {
                        halfContent(
                            currency: viewModel.sourceCurrency,
                            amount: viewModel.sourceAmount.isEmpty ? "0" : viewModel.sourceAmount,
                            isSource: true,
                            onSelect: { selected in
                                viewModel.sourceCurrency = selected
                                viewModel.convert()
                            }
                        )
                        .offset(y: sourceSlide)
                    }
                    .frame(maxWidth: .infinity, minHeight: 130)
                    .clipped()

                    Divider()

                    // Target half — clipped so slide stays within bounds
                    ZStack {
                        halfContent(
                            currency: viewModel.targetCurrency,
                            amount: viewModel.convertedAmount.isEmpty ? "0" : viewModel.convertedAmount,
                            isSource: false,
                            onSelect: { selected in
                                viewModel.targetCurrency = selected
                                viewModel.convert()
                            }
                        )
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

            if viewModel.isLoading { LoadingDot() }
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

    // MARK: - Half Content (selector + faint symbol + big amount)

    private func halfContent(
        currency: CurrencyInfo,
        amount: String,
        isSource: Bool,
        onSelect: @escaping (CurrencyInfo) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Currency selector: 🇺🇸 USD · 美元  ˅
            currencySelector(currency: currency, onSelect: onSelect)

            Spacer(minLength: NumoSpacing.xs)

            // Amount row: faint symbol prefix + big number
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(currency.symbol)
                    .font(.system(
                        size: isSource ? 34 : 28,
                        weight: .light,
                        design: .rounded
                    ))
                    .foregroundStyle(
                        (isSource ? NumoColors.textPrimary : NumoColors.textSecondary)
                            .opacity(0.14)
                    )
                    .animation(.easeInOut(duration: 0.2), value: currency.symbol)

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
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, NumoSpacing.xl)
        .padding(.vertical, NumoSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Currency Selector (horizontal single line)

    private func currencySelector(
        currency: CurrencyInfo,
        onSelect: @escaping (CurrencyInfo) -> Void
    ) -> some View {
        Menu {
            ForEach(CurrencyInfo.all) { c in
                Button {
                    onSelect(c)
                } label: {
                    Text("\(c.flag) \(c.code) – \(c.localizedName)")
                }
            }
        } label: {
            HStack(spacing: NumoSpacing.xs) {
                Text("\(currency.flag) \(currency.code) · \(currency.localizedName)")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(NumoColors.textPrimary)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currency.code)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(NumoColors.textTertiary)
            }
        }
    }

    // MARK: - Swap Button with staggered spring animation

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

    // MARK: - Swap with staggered spring physics

    private func doSwap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.8)

        // Phase 1: both halves slide toward the divider
        withAnimation(.easeIn(duration: 0.11)) {
            sourceSlide = 20
            targetSlide = -20
        }

        // Phase 2: swap data, then spring each half back with offset timing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
            viewModel.swapCurrencies()

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
