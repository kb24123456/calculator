//
//  InputValidator.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

struct InputValidator {
    /// Validate numeric input string — allows digits, one decimal point, and leading minus.
    static func isValidNumericInput(_ text: String) -> Bool {
        let cleaned = text.withoutGroupingSeparators
        guard !cleaned.isEmpty else { return true } // empty is valid (nothing entered yet)

        let pattern = #"^-?\d*\.?\d*$"#
        return cleaned.range(of: pattern, options: .regularExpression) != nil
    }

    /// Prevent multiple decimal points.
    static func sanitizeDecimalInput(_ text: String) -> String {
        var result = ""
        var hasDecimal = false
        for ch in text {
            if ch == "." {
                if !hasDecimal {
                    hasDecimal = true
                    result.append(ch)
                }
            } else if ch.isNumber || ch == "-" || ch == "," {
                result.append(ch)
            }
        }
        return result
    }
}
