//
//  Decimal+Extensions.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

extension Decimal {
    /// Rounds to specified number of decimal places.
    func rounded(to places: Int) -> Decimal {
        var value = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, places, .plain)
        return rounded
    }

    /// Returns the absolute value.
    var absoluteValue: Decimal {
        self < 0 ? -self : self
    }

    /// Converts to Double (for scientific functions that require it).
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
