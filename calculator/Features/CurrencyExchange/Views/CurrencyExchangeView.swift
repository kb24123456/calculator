//
//  CurrencyExchangeView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct CurrencyExchangeView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = CurrencyExchangeViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: NumoSpacing.lg) {
                // Source
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    currencySelector(currency: viewModel.sourceCurrency) { selected in
                        viewModel.sourceCurrency = selected
                        viewModel.convert()
                    }

                    NumoTextField(title: "0", text: $viewModel.sourceAmount)
                        .onChange(of: viewModel.sourceAmount) { viewModel.convert() }
                }

                // Swap
                HStack {
                    Spacer()
                    Button { viewModel.swapCurrencies() } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(NumoColors.accentRed)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(NumoColors.surfaceSecondary))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }

                // Target
                VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                    currencySelector(currency: viewModel.targetCurrency) { selected in
                        viewModel.targetCurrency = selected
                        viewModel.convert()
                    }

                    if !viewModel.convertedAmount.isEmpty {
                        Text(viewModel.convertedAmount)
                            .font(NumoTypography.monoDisplayMedium)
                            .foregroundStyle(NumoColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, NumoSpacing.md)
                            .contentTransition(.numericText())
                    }
                }

                // Rate info
                if !viewModel.rateInfo.isEmpty {
                    HStack {
                        Text(viewModel.rateInfo)
                            .font(NumoTypography.caption)
                            .foregroundStyle(NumoColors.textTertiary)
                        if let lastUpdated = viewModel.lastUpdated {
                            Text("· \(lastUpdated.relativeDescription)")
                                .font(NumoTypography.caption)
                                .foregroundStyle(NumoColors.textTertiary)
                        }
                        Spacer()
                    }
                }

                // Quick currencies
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: NumoSpacing.xs) {
                        ForEach(CurrencyInfo.quickCurrencies, id: \.self) { code in
                            if let currency = CurrencyInfo.find(code) {
                                Button {
                                    viewModel.targetCurrency = currency
                                    viewModel.convert()
                                } label: {
                                    Text("\(currency.flag) \(currency.code)")
                                        .font(NumoTypography.bodySmall)
                                        .foregroundStyle(
                                            viewModel.targetCurrency.code == code
                                                ? NumoColors.chipSelectedText
                                                : NumoColors.chipDefaultText
                                        )
                                        .padding(.horizontal, NumoSpacing.sm)
                                        .frame(height: 32)
                                        .background(
                                            Capsule().fill(
                                                viewModel.targetCurrency.code == code
                                                    ? NumoColors.chipSelected
                                                    : NumoColors.chipDefault
                                            )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // Error / Loading
                if viewModel.isLoading {
                    LoadingDot()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(NumoTypography.bodySmall)
                        .foregroundStyle(NumoColors.danger)
                }

                Spacer()
            }
            .padding(.horizontal, NumoSpacing.md)
            .padding(.top, NumoSpacing.md)
        }
        .task {
            viewModel.updateFromLastResult(appState.lastResult)
            await viewModel.loadRates()
        }
    }

    private func currencySelector(currency: CurrencyInfo, onSelect: @escaping (CurrencyInfo) -> Void) -> some View {
        Menu {
            ForEach(CurrencyInfo.all) { c in
                Button {
                    onSelect(c)
                } label: {
                    Text("\(c.flag) \(c.code) - \(c.nameKey)")
                }
            }
        } label: {
            HStack(spacing: NumoSpacing.xs) {
                Text(currency.flag)
                    .font(.system(size: 20))
                Text("\(currency.symbol) \(currency.code)")
                    .font(NumoTypography.bodyMedium)
                    .foregroundStyle(NumoColors.textPrimary)
                Text(currency.nameKey)
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

#Preview {
    CurrencyExchangeView()
        .environment(AppState())
}
