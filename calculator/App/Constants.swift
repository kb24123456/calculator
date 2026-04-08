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

    enum PreciousMetals {
        static let gramsPerTroyOunce: Decimal = Decimal(string: "31.1035")!
        static let fallbackGoldPricePerGram: Decimal = 980   // CNY
        static let fallbackSilverPricePerGram: Decimal = 8   // CNY
        // Stooq — free, no key, intraday XAU/XAG vs CNY direct quotes
        static let stooqBaseURL = "https://stooq.com/q/l/?f=sd2t2ohlcv&h&e=json&s="
        // fawazahmed0 — free, no key, daily fallback
        static let metalPriceFallbackBaseURL = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies"
        static let metalPriceFallbackMirrorURL = "https://latest.currency-api.pages.dev/v1/currencies"
        static let metalPriceTimeout: TimeInterval = 10
    }
}
