//
//  CurrencyExchangeView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI
import Combine

struct CurrencyExchangeView: View {
    @Bindable var viewModel: CurrencyExchangeViewModel

    @State private var swapRotation: Double = 0
    @State private var sourceSlide: CGFloat = 0
    @State private var targetSlide: CGFloat = 0

    // Blinking cursor
    @State private var cursorVisible: Bool = true

    var body: some View {
        VStack(spacing: NumoSpacing.md) {
            Spacer(minLength: 0)

            // MARK: - Unified Exchange Card
            ZStack(alignment: .center) {
                VStack(spacing: 0) {
                    // Source half
                    ZStack {
                        halfContent(
                            currency: viewModel.sourceCurrency,
                            amount: sourceDisplayAmount,
                            isSource: true,
                            isActive: viewModel.activeInput == .source,
                            onSelect: { selected in
                                viewModel.sourceCurrency = selected
                                viewModel.convert()
                            }
                        )
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
                            currency: viewModel.targetCurrency,
                            amount: targetDisplayAmount,
                            isSource: false,
                            isActive: viewModel.activeInput == .target,
                            onSelect: { selected in
                                viewModel.targetCurrency = selected
                                viewModel.convert()
                            }
                        )
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
        .onReceive(Timer.publish(every: 0.53, on: .main, in: .common).autoconnect()) { _ in
            cursorVisible.toggle()
        }
    }

    // MARK: - Display amount helpers

    private var sourceDisplayAmount: String {
        switch viewModel.activeInput {
        case .source:
            return viewModel.sourceAmount.isEmpty ? "0" : viewModel.sourceAmount
        case .target:
            return viewModel.sourceResult.isEmpty ? "0" : viewModel.sourceResult
        }
    }

    private var targetDisplayAmount: String {
        switch viewModel.activeInput {
        case .source:
            return viewModel.convertedAmount.isEmpty ? "0" : viewModel.convertedAmount
        case .target:
            return viewModel.targetAmount.isEmpty ? "0" : viewModel.targetAmount
        }
    }

    // MARK: - Half Content

    private func halfContent(
        currency: CurrencyInfo,
        amount: String,
        isSource: Bool,
        isActive: Bool,
        onSelect: @escaping (CurrencyInfo) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            currencySelector(currency: currency, onSelect: onSelect)

            Spacer(minLength: NumoSpacing.xs)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                // Faint currency symbol prefix
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

                // Amount
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

                // Blinking cursor — only when this half is active
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

    // MARK: - Currency Selector

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

    // MARK: - Swap Button

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

    // MARK: - Swap animation

    private func doSwap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.8)

        withAnimation(.easeIn(duration: 0.11)) {
            sourceSlide = 20
            targetSlide = -20
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
            viewModel.swapCurrencies()

            withAnimation(.spring(response: 0.44, dampingFraction: 0.56)) {
                sourceSlide = 0
                swapRotation += 180
            }
            withAnimation(.spring(response: 0.50, dampingFraction: 0.52).delay(0.05)) {
                targetSlide = 0
            }
        }
    }
}
