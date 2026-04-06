//
//  ExpressionFormatter.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

struct ExpressionFormatter {

    /// Format a Decimal result for display.
    /// - Uses locale-aware grouping separators
    /// - Trims trailing zeros
    /// - Switches to scientific notation for very large numbers
    /// - Handles negative zero
    static func format(_ value: Decimal, maxDecimalPlaces: Int = Constants.Calculator.maxDecimalPlaces) -> String {
        // Handle negative zero
        if value == 0 { return "0" }

        let absValue = abs(value)

        // Scientific notation for very large numbers
        if absValue >= Constants.Calculator.scientificNotationThreshold {
            let doubleVal = NSDecimalNumber(decimal: value).doubleValue
            let formatted = String(format: "%g", doubleVal)
            return formatted
        }

        // Format with NSDecimalNumber for precision
        let handler = NSDecimalNumberHandler(
            roundingMode: .plain,
            scale: Int16(maxDecimalPlaces),
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        let rounded = NSDecimalNumber(decimal: value).rounding(accordingToBehavior: handler)

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maxDecimalPlaces
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."

        return formatter.string(from: rounded) ?? "\(value)"
    }

    /// Format a Decimal as currency display (always 2 decimal places).
    static func formatCurrency(_ value: Decimal, symbol: String = "¥", decimalPlaces: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimalPlaces
        formatter.minimumFractionDigits = decimalPlaces
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."

        let formatted = formatter.string(from: NSDecimalNumber(decimal: value)) ?? "\(value)"
        return "\(symbol)\(formatted)"
    }

    /// Format a Decimal as percentage display.
    static func formatPercent(_ value: Decimal, decimalPlaces: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimalPlaces
        formatter.minimumFractionDigits = 0

        let formatted = formatter.string(from: NSDecimalNumber(decimal: value)) ?? "\(value)"
        let sign = value > 0 ? "+" : ""
        return "\(sign)\(formatted)%"
    }
}

private func abs(_ value: Decimal) -> Decimal {
    value < 0 ? -value : value
}
