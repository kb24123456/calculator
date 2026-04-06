//
//  TrendIndicator.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

enum Trend {
    case up, down, flat

    var icon: String {
        switch self {
        case .up: "arrow.up.right"
        case .down: "arrow.down.right"
        case .flat: "arrow.right"
        }
    }

    var color: Color {
        switch self {
        case .up: NumoColors.danger    // 中国惯例：红涨
        case .down: NumoColors.success // 中国惯例：绿跌
        case .flat: NumoColors.textSecondary
        }
    }
}

struct TrendIndicator: View {
    let trend: Trend
    let value: String

    var body: some View {
        HStack(spacing: NumoSpacing.xxs) {
            Image(systemName: trend.icon)
                .font(.system(size: 12, weight: .semibold))
            Text(value)
                .font(NumoTypography.bodyMedium.weight(.semibold))
        }
        .foregroundStyle(trend.color)
    }
}

#Preview {
    VStack(spacing: 12) {
        TrendIndicator(trend: .up, value: "+15.5%")
        TrendIndicator(trend: .down, value: "-8.2%")
        TrendIndicator(trend: .flat, value: "0.0%")
    }
}
