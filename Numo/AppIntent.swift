//
//  AppIntent.swift
//  Numo
//
//  Created by 廖云丰 on 2026/4/9.
//

import WidgetKit
import AppIntents

// MARK: - Gold Price Widget (no configuration needed)

struct GoldPriceIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "金价" }
    static var description: IntentDescription { "显示实时黄金价格" }
}

// MARK: - Currency Pair Widget

struct CurrencyPairIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "汇率" }
    static var description: IntentDescription { "显示货币汇率" }

    @Parameter(title: "源货币", default: "USD")
    var sourceCurrency: String

    @Parameter(title: "目标货币", default: "CNY")
    var targetCurrency: String
}
