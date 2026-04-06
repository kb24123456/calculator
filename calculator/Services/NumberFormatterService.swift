//
//  NumberFormatterService.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

struct NumberFormatterService {
    static let shared = NumberFormatterService()

    private let decimalFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.usesGroupingSeparator = true
        f.groupingSeparator = ","
        f.decimalSeparator = "."
        f.maximumFractionDigits = 10
        f.minimumFractionDigits = 0
        return f
    }()

    private let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        f.usesGroupingSeparator = true
        return f
    }()

    func formatDecimal(_ value: Decimal) -> String {
        decimalFormatter.string(from: NSDecimalNumber(decimal: value)) ?? "\(value)"
    }

    func formatCurrency(_ value: Decimal) -> String {
        currencyFormatter.string(from: NSDecimalNumber(decimal: value)) ?? "\(value)"
    }

    func parseDecimal(_ string: String) -> Decimal? {
        let cleaned = string.replacingOccurrences(of: ",", with: "")
        return Decimal(string: cleaned)
    }
}
