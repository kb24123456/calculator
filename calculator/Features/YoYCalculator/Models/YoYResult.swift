//
//  YoYResult.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

enum ComparisonMode: String, CaseIterable {
    case yoy // 同比
    case mom // 环比
}

struct YoYResult {
    let percentageChange: Decimal
    let absoluteChange: Decimal
    let trend: Trend
    let currentValue: Decimal
    let previousValue: Decimal
}
