//
//  Constants.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

enum Constants {
    enum API {
        static let exchangeRateBaseURL = "https://api.frankfurter.app/latest"
        static let exchangeRateTimeout: TimeInterval = 10
        static let exchangeRateCacheMaxAge: TimeInterval = 3600 // 1 hour
        static let exchangeRateStaleAge: TimeInterval = 86400 // 24 hours
    }

    enum Calculator {
        static let maxExpressionLength = 200
        static let maxDecimalPlaces = 10
        static let maxDisplayDigits = 15
        static let scientificNotationThreshold: Decimal = 1_000_000_000_000_000
    }

    enum ChineseUppercase {
        static let maxIntegerDigits = 12
        static let maxDecimalPlaces = 2
    }
}
