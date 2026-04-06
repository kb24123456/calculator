//
//  YoYCalculatorViewModel.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

@Observable
final class YoYCalculatorViewModel {
    var currentValueText: String = ""
    var yoyPreviousText: String = ""
    var momPreviousText: String = ""
    var yoyResult: YoYResult?
    var momResult: YoYResult?
    var errorMessage: String?

    func calculate() {
        let current = currentValueText.decimalValue
        yoyResult = computeResult(current: current, previous: yoyPreviousText.decimalValue)
        momResult = computeResult(current: current, previous: momPreviousText.decimalValue)
    }

    private func computeResult(current: Decimal?, previous: Decimal?) -> YoYResult? {
        guard let current, let previous else { return nil }
        guard previous != 0 else { return nil }

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

        return YoYResult(
            percentageChange: percentageChange.rounded(to: 2),
            absoluteChange: absoluteChange,
            trend: trend,
            currentValue: current,
            previousValue: previous
        )
    }
}
