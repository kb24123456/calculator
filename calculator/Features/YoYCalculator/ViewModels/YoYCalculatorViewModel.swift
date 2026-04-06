//
//  YoYCalculatorViewModel.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

@Observable
final class YoYCalculatorViewModel {
    var mode: ComparisonMode = .yoy
    var currentValueText: String = ""
    var previousValueText: String = ""
    var result: YoYResult?
    var errorMessage: String?

    func calculate() {
        let current = currentValueText.decimalValue
        let previous = previousValueText.decimalValue

        guard let current, let previous else {
            result = nil
            errorMessage = nil
            return
        }

        guard previous != 0 else {
            result = nil
            errorMessage = String(localized: "上期值不能为零")
            return
        }

        let absoluteChange = current - previous
        let percentageChange = (absoluteChange / previous.absoluteValue) * 100

        let trend: Trend
        if percentageChange > 0 {
            trend = .up
        } else if percentageChange < 0 {
            trend = .down
        } else {
            trend = .flat
        }

        result = YoYResult(
            percentageChange: percentageChange.rounded(to: 2),
            absoluteChange: absoluteChange,
            trend: trend,
            currentValue: current,
            previousValue: previous
        )
        errorMessage = nil
    }

    func updateFromLastResult(_ lastResult: Decimal?) {
        guard let value = lastResult else { return }
        currentValueText = ExpressionFormatter.format(value)
        calculate()
    }
}
