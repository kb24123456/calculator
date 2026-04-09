//
//  CurrencyExchangeViewModel.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

enum CurrencyInputSide { case source, target }

@Observable
final class CurrencyExchangeViewModel {

    // MARK: - Active side

    var activeInput: CurrencyInputSide = .source

    // MARK: - Raw inputs (what the user typed)

    var sourceAmount: String = ""
    var targetAmount: String = ""

    // MARK: - Computed results

    /// Shown in target half when source is active
    var convertedAmount: String = ""
    /// Shown in source half when target is active
    var sourceResult: String = ""

    // MARK: - Currencies & state

    var sourceCurrency: CurrencyInfo = CurrencyInfo.find("USD")!
    var targetCurrency: CurrencyInfo = CurrencyInfo.find("CNY")!
    var rateInfo: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var lastUpdated: Date?

    private var rates: [String: Decimal] = [:]
    private let service: ExchangeRateServiceProtocol = ExchangeRateServiceImpl()

    // MARK: - Load

    func loadRates() async {
        isLoading = true
        errorMessage = nil
        do {
            rates = try await service.fetchRates(base: "USD")
            lastUpdated = Date()
            convert()
        } catch {
            errorMessage = String(localized: "无法获取汇率，请检查网络")
        }
        isLoading = false
    }

    // MARK: - Active-side dispatch

    func convert() {
        switch activeInput {
        case .source: convertFromSource()
        case .target: convertFromTarget()
        }
    }

    func convertFromSource() {
        updateRateInfo()
        let cleaned = sourceAmount.withoutGroupingSeparators
        guard !cleaned.isEmpty, let amount = Decimal(string: cleaned) else {
            convertedAmount = ""
            return
        }
        convertedAmount = compute(amount: amount, from: sourceCurrency, to: targetCurrency)
    }

    func convertFromTarget() {
        updateRateInfo()
        let cleaned = targetAmount.withoutGroupingSeparators
        guard !cleaned.isEmpty, let amount = Decimal(string: cleaned) else {
            sourceResult = ""
            return
        }
        sourceResult = compute(amount: amount, from: targetCurrency, to: sourceCurrency)
    }

    // MARK: - Shared conversion engine

    private func compute(amount: Decimal, from: CurrencyInfo, to: CurrencyInfo) -> String {
        let fromUSD: Decimal
        if from.code == "USD" {
            fromUSD = amount
        } else if let rate = rates[from.code] {
            fromUSD = amount / rate
        } else { return "" }

        let result: Decimal
        if to.code == "USD" {
            result = fromUSD
        } else if let rate = rates[to.code] {
            result = fromUSD * rate
        } else { return "" }

        return ExpressionFormatter.formatCurrency(
            result.rounded(to: to.decimalPlaces),
            symbol: to.symbol,
            decimalPlaces: to.decimalPlaces
        )
    }

    // MARK: - Active side management

    /// 切换激活侧。对方侧的旧输入保留（用 C 键清除），不自动抹除。
    func setActive(_ side: CurrencyInputSide) {
        guard activeInput != side else { return }
        activeInput = side
        convert()
    }

    // MARK: - Swap

    func swapCurrencies() {
        let temp = sourceCurrency
        sourceCurrency = targetCurrency
        targetCurrency = temp
        // 重置为 source 激活，避免 swap 后状态混乱
        activeInput = .source
        targetAmount = ""
        sourceResult = ""
        convertFromSource()
    }

    // MARK: - Clipboard fill

    func updateFromLastResult(_ lastResult: Decimal?) {
        guard let value = lastResult else { return }
        activeInput = .source
        sourceAmount = ExpressionFormatter.format(value)
        convertFromSource()
    }

    // MARK: - Rate label

    private func updateRateInfo() {
        guard !rates.isEmpty else { rateInfo = "--"; return }
        let directRate: Decimal
        if sourceCurrency.code == "USD" {
            directRate = rates[targetCurrency.code] ?? 1
        } else if targetCurrency.code == "USD" {
            directRate = 1 / (rates[sourceCurrency.code] ?? 1)
        } else {
            let s = rates[sourceCurrency.code] ?? 1
            let t = rates[targetCurrency.code] ?? 1
            directRate = t / s
        }
        rateInfo = "1 \(sourceCurrency.code) = \(ExpressionFormatter.format(directRate.rounded(to: 4))) \(targetCurrency.code)"
    }
}
