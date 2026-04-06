//
//  CurrencyExchangeViewModel.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

@Observable
final class CurrencyExchangeViewModel {
    var sourceAmount: String = ""
    var sourceCurrency: CurrencyInfo = CurrencyInfo.find("USD")!
    var targetCurrency: CurrencyInfo = CurrencyInfo.find("CNY")!
    var convertedAmount: String = ""
    var rateInfo: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var lastUpdated: Date?

    private var rates: [String: Decimal] = [:]
    private let service: ExchangeRateServiceProtocol = ExchangeRateServiceImpl()

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

    func convert() {
        let cleaned = sourceAmount.withoutGroupingSeparators
        guard !cleaned.isEmpty, let amount = Decimal(string: cleaned) else {
            convertedAmount = ""
            rateInfo = ""
            return
        }

        // Convert: source → USD → target
        let sourceToUSD: Decimal
        if sourceCurrency.code == "USD" {
            sourceToUSD = amount
        } else if let sourceRate = rates[sourceCurrency.code] {
            sourceToUSD = amount / sourceRate
        } else {
            convertedAmount = ""
            return
        }

        let result: Decimal
        if targetCurrency.code == "USD" {
            result = sourceToUSD
        } else if let targetRate = rates[targetCurrency.code] {
            result = sourceToUSD * targetRate
        } else {
            convertedAmount = ""
            return
        }

        let rounded = result.rounded(to: targetCurrency.decimalPlaces)
        convertedAmount = ExpressionFormatter.formatCurrency(rounded, symbol: targetCurrency.symbol, decimalPlaces: targetCurrency.decimalPlaces)

        // Rate info
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

    func swapCurrencies() {
        let temp = sourceCurrency
        sourceCurrency = targetCurrency
        targetCurrency = temp
        convert()
    }

    func updateFromLastResult(_ lastResult: Decimal?) {
        guard let value = lastResult else { return }
        sourceAmount = ExpressionFormatter.format(value)
        convert()
    }
}
