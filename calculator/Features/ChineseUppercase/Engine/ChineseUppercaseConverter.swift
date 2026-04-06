//
//  ChineseUppercaseConverter.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

struct ChineseUppercaseConverter {

    private static let digits = ["零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖"]
    private static let units = ["", "拾", "佰", "仟"]
    private static let bigUnits = ["", "万", "亿"]

    /// Convert a Decimal amount to Chinese uppercase (人民币大写).
    /// Supports: 0 ~ 999,999,999,999.99
    /// Returns nil if out of range.
    static func convert(_ amount: Decimal) -> String? {
        let isNegative = amount < 0
        let absAmount = amount.absoluteValue.rounded(to: Constants.ChineseUppercase.maxDecimalPlaces)

        // Range check
        let maxValue = Decimal(string: "999999999999.99")!
        guard absAmount <= maxValue else { return nil }

        let str = NSDecimalNumber(decimal: absAmount).stringValue
        let parts = str.split(separator: ".", maxSplits: 1)
        let integerPart = String(parts[0])
        let decimalPart = parts.count > 1 ? String(parts[1]).padding(toLength: 2, withPad: "0", startingAt: 0) : ""

        // Build integer part
        let integerStr = convertInteger(integerPart)

        // Build decimal part
        let decimalStr = convertDecimal(decimalPart)

        var result = ""
        if isNegative { result += "负" }

        if integerStr.isEmpty || integerStr == "零" {
            if decimalStr.isEmpty {
                return result + "零圆整"
            } else {
                return result + "零圆" + decimalStr
            }
        } else {
            result += integerStr + "圆"
            if decimalStr.isEmpty {
                result += "整"
            } else {
                result += decimalStr
            }
        }

        return result
    }

    // MARK: - Integer Conversion

    private static func convertInteger(_ str: String) -> String {
        guard !str.isEmpty else { return "零" }

        // Remove leading zeros
        let trimmed = String(str.drop { $0 == "0" })
        guard !trimmed.isEmpty else { return "零" }

        let digitChars = Array(trimmed)
        let count = digitChars.count

        // Split into groups of 4 digits from right
        var groups: [[Int]] = []
        var i = count
        while i > 0 {
            let start = max(0, i - 4)
            let group = digitChars[start..<i].map { Int(String($0))! }
            groups.insert(group, at: 0)
            i = start
        }

        var result = ""
        for (groupIndex, group) in groups.enumerated() {
            let bigUnitIndex = groups.count - 1 - groupIndex
            let groupStr = convertFourDigits(group)
            if !groupStr.isEmpty && groupStr != "零" {
                // Handle zero between groups
                if !result.isEmpty && group.count == 4 && group[0] == 0 {
                    result += "零"
                }
                result += groupStr + bigUnits[min(bigUnitIndex, bigUnits.count - 1)]
            } else if !result.isEmpty {
                // All zeros in this group - may need a single 零
                // Only add 零 if the next group has content
            }
        }

        return result.isEmpty ? "零" : result
    }

    private static func convertFourDigits(_ group: [Int]) -> String {
        var result = ""
        var lastWasZero = false
        let count = group.count

        for (i, digit) in group.enumerated() {
            let unitIndex = count - 1 - i
            if digit == 0 {
                if !result.isEmpty && !lastWasZero {
                    lastWasZero = true
                }
            } else {
                if lastWasZero {
                    result += "零"
                    lastWasZero = false
                }
                result += digits[digit] + units[unitIndex]
            }
        }

        return result
    }

    // MARK: - Decimal Conversion

    private static func convertDecimal(_ str: String) -> String {
        guard !str.isEmpty else { return "" }

        let padded = str.padding(toLength: 2, withPad: "0", startingAt: 0)
        let jiao = Int(String(padded[padded.startIndex]))!
        let fen = Int(String(padded[padded.index(after: padded.startIndex)]))!

        var result = ""

        if jiao > 0 {
            result += digits[jiao] + "角"
        } else if fen > 0 {
            result += "零"
        }

        if fen > 0 {
            result += digits[fen] + "分"
        } else if jiao > 0 {
            result += "整"
        }

        return result
    }
}
