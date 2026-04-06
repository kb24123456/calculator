//
//  Currency.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

struct CurrencyInfo: Identifiable, Hashable {
    let code: String       // ISO 4217
    let symbol: String
    let flag: String
    let nameKey: String    // Chinese name (source language)
    let decimalPlaces: Int

    var id: String { code }

    /// Localized display name: Chinese name in zh, ISO code in en
    var localizedName: String {
        String(localized: String.LocalizationValue(nameKey))
    }

    static let all: [CurrencyInfo] = [
        CurrencyInfo(code: "CNY", symbol: "¥", flag: "🇨🇳", nameKey: "人民币", decimalPlaces: 2),
        CurrencyInfo(code: "USD", symbol: "$", flag: "🇺🇸", nameKey: "美元", decimalPlaces: 2),
        CurrencyInfo(code: "EUR", symbol: "€", flag: "🇪🇺", nameKey: "欧元", decimalPlaces: 2),
        CurrencyInfo(code: "JPY", symbol: "¥", flag: "🇯🇵", nameKey: "日元", decimalPlaces: 0),
        CurrencyInfo(code: "GBP", symbol: "£", flag: "🇬🇧", nameKey: "英镑", decimalPlaces: 2),
        CurrencyInfo(code: "HKD", symbol: "HK$", flag: "🇭🇰", nameKey: "港币", decimalPlaces: 2),
        CurrencyInfo(code: "KRW", symbol: "₩", flag: "🇰🇷", nameKey: "韩元", decimalPlaces: 0),
        CurrencyInfo(code: "AUD", symbol: "A$", flag: "🇦🇺", nameKey: "澳元", decimalPlaces: 2),
        CurrencyInfo(code: "CAD", symbol: "C$", flag: "🇨🇦", nameKey: "加元", decimalPlaces: 2),
        CurrencyInfo(code: "SGD", symbol: "S$", flag: "🇸🇬", nameKey: "新加坡元", decimalPlaces: 2),
        CurrencyInfo(code: "CHF", symbol: "Fr", flag: "🇨🇭", nameKey: "瑞士法郎", decimalPlaces: 2),
        CurrencyInfo(code: "THB", symbol: "฿", flag: "🇹🇭", nameKey: "泰铢", decimalPlaces: 2),
        CurrencyInfo(code: "MYR", symbol: "RM", flag: "🇲🇾", nameKey: "马来西亚林吉特", decimalPlaces: 2),
        CurrencyInfo(code: "NZD", symbol: "NZ$", flag: "🇳🇿", nameKey: "新西兰元", decimalPlaces: 2),
        CurrencyInfo(code: "SEK", symbol: "kr", flag: "🇸🇪", nameKey: "瑞典克朗", decimalPlaces: 2),
    ]

    static let quickCurrencies = ["CNY", "USD", "EUR", "JPY", "GBP", "HKD"]

    static func find(_ code: String) -> CurrencyInfo? {
        all.first { $0.code == code }
    }
}
