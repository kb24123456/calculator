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

    case date = "date"
    case unit = "unit"
    case loan = "loan"
    case preciousMetals = "preciousMetals"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .calculator: String(localized: "计算器")
        case .currency: String(localized: "汇率")
        case .uppercase: String(localized: "大写")
        case .yoy: String(localized: "同比环比")

        case .date: String(localized: "日期")
        case .unit: String(localized: "单位")
        case .loan: String(localized: "贷款")
        case .preciousMetals: String(localized: "真金白银")
        }
    }

    var icon: String {
        switch self {
        case .calculator: "plus.forwardslash.minus"
        case .currency: "coloncurrencysign.arrow.trianglehead.counterclockwise.rotate.90"
        case .uppercase: "textformat.characters.dottedunderline.zh"
        case .yoy: "chart.line.uptrend.xyaxis"

        case .date: "calendar"
        case .unit: "ruler"
        case .loan: "house"
        case .preciousMetals: "sparkles"
        }
    }
}

@Observable
final class AppState {
    var selectedTool: Tool = .calculator
    var lastResult: Decimal?
    var isAllToolsPanelOpen: Bool = false
    // MARK: - Favorites

    static let defaultFavorites: [Tool] = [.currency, .uppercase, .yoy]
    private static let favoritesKey = "numo_favorite_tools"

    var favoriteTools: [Tool] {
        didSet {
            Self.saveFavorites(favoriteTools)
        }
    }

    init() {
        self.favoriteTools = Self.loadFavorites()
    }

    func selectTool(_ tool: Tool) {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedTool = tool
            isAllToolsPanelOpen = false
        }
    }

    func toggleFavorite(_ tool: Tool) {
        if let index = favoriteTools.firstIndex(of: tool) {
            // Don't remove the last favorite
            if favoriteTools.count > 1 {
                favoriteTools.remove(at: index)
            }
        } else {
            favoriteTools.append(tool)
        }
    }

    func isFavorite(_ tool: Tool) -> Bool {
        favoriteTools.contains(tool)
    }

    func moveFavorite(from source: IndexSet, to destination: Int) {
        favoriteTools.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Persistence

    private static func saveFavorites(_ tools: [Tool]) {
        let rawValues = tools.map { $0.rawValue }
        if let data = try? JSONEncoder().encode(rawValues) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }

    private static func loadFavorites() -> [Tool] {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let rawValues = try? JSONDecoder().decode([String].self, from: data) else {
            return defaultFavorites
        }
        let tools = rawValues.compactMap { Tool(rawValue: $0) }
        return tools.isEmpty ? defaultFavorites : tools
    }
}
