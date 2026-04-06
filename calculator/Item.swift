//
//  Item.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation
import SwiftData

@Model
final class CalculationRecord {
    var expression: String
    var result: String
    var resultDecimal: Decimal
    var timestamp: Date
    var isFavorite: Bool

    init(expression: String, result: String, resultDecimal: Decimal, timestamp: Date = .now, isFavorite: Bool = false) {
        self.expression = expression
        self.result = result
        self.resultDecimal = resultDecimal
        self.timestamp = timestamp
        self.isFavorite = isFavorite
    }
}

@Model
final class ExchangeRate {
    var baseCurrency: String
    var targetCurrency: String
    var rate: Double
    var fetchedAt: Date

    init(baseCurrency: String, targetCurrency: String, rate: Double, fetchedAt: Date = .now) {
        self.baseCurrency = baseCurrency
        self.targetCurrency = targetCurrency
        self.rate = rate
        self.fetchedAt = fetchedAt
    }
}
