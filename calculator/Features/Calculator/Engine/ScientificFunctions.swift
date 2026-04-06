//
//  ScientificFunctions.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

enum AngleUnit {
    case radians
    case degrees

    func toRadians(_ value: Double) -> Double {
        switch self {
        case .radians: value
        case .degrees: value * .pi / 180
        }
    }

    func fromRadians(_ value: Double) -> Double {
        switch self {
        case .radians: value
        case .degrees: value * 180 / .pi
        }
    }
}

/// Power function for Decimal: computes base^exponent iteratively.
/// Only supports non-negative integer exponents.
func decimalPow(_ base: Decimal, _ exponent: Int) -> Decimal {
    guard exponent >= 0 else { return 0 }
    if exponent == 0 { return 1 }
    var result: Decimal = 1
    for _ in 0..<exponent {
        result *= base
    }
    return result
}
