//
//  String+Extensions.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

extension String {
    /// Remove all non-numeric characters except decimal point and minus sign.
    var numericOnly: String {
        filter { $0.isNumber || $0 == "." || $0 == "-" }
    }

    /// Remove grouping separators (commas).
    var withoutGroupingSeparators: String {
        replacingOccurrences(of: ",", with: "")
    }

    /// Parse to Decimal, removing commas first.
    var decimalValue: Decimal? {
        Decimal(string: withoutGroupingSeparators)
    }
}
