//
//  AppState.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

/// Which input field is active in multi-field tools
enum ToolInputField: Hashable {
    case primary
    case secondary
    case tertiary
}

enum Tool: String, CaseIterable, Identifiable {
    case calculator = "calculator"
    case currency = "currency"
    case uppercase = "uppercase"
    case yoy = "yoy"
    case incomeTax = "incomeTax"
    case date = "date"
    case unit = "unit"
    case loan = "loan"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .calculator: String(localized: "计算器")
        case .currency: String(localized: "汇率")
        case .uppercase: String(localized: "大写")
        case .yoy: String(localized: "同比环比")
        case .incomeTax: String(localized: "个税")
        case .date: String(localized: "日期")
        case .unit: String(localized: "单位")
        case .loan: String(localized: "贷款")
        }
    }

    var icon: String {
        switch self {
        case .calculator: "plus.forwardslash.minus"
        case .currency: "coloncurrencysign.arrow.trianglehead.counterclockwise.rotate.90"
        case .uppercase: "textformat.characters.dottedunderline.zh"
        case .yoy: "chart.line.uptrend.xyaxis"
        case .incomeTax: "yensign"
        case .date: "calendar"
        case .unit: "ruler"
        case .loan: "house"
        }
    }

    /// Tools shown in the top toolbar chips
    static let toolbarTools: [Tool] = [.calculator, .currency, .uppercase, .yoy, .incomeTax]

    /// Tools shown in the "more" drawer
    static let drawerTools: [Tool] = [.date, .unit, .loan]
}

@Observable
final class AppState {
    var selectedTool: Tool = .calculator
    var lastResult: Decimal?
    var isDrawerOpen: Bool = false
    var operatorOnRight: Bool = true  // true = operators on right (default)

    func selectTool(_ tool: Tool) {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedTool = tool
            isDrawerOpen = false
        }
    }
}
