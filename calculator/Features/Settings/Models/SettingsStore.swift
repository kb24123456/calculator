//
//  SettingsStore.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/9.
//

import SwiftUI

/// Centralized settings store using @AppStorage for persistence.
/// Injected via .environment() at the app root.
@Observable
final class SettingsStore {

    // MARK: - Calculator

    @ObservationIgnored
    @AppStorage("numo_operator_on_right") var operatorOnRight: Bool = true

    @ObservationIgnored
    @AppStorage("numo_decimal_precision") var decimalPrecision: Int = -1  // -1 = auto

    @ObservationIgnored
    @AppStorage("numo_thousands_sep") var thousandsSeparatorRaw: String = ThousandsSeparator.comma.rawValue

    @ObservationIgnored
    @AppStorage("numo_auto_copy") var autoCopyResult: Bool = false

    // MARK: - Interaction

    @ObservationIgnored
    @AppStorage("numo_haptic_enabled") var hapticEnabled: Bool = true

    @ObservationIgnored
    @AppStorage("numo_sound_enabled") var soundEnabled: Bool = false

    @ObservationIgnored
    @AppStorage("numo_clipboard_detect") var clipboardDetection: Bool = true

    // MARK: - Display

    @ObservationIgnored
    @AppStorage("numo_theme") var themeRaw: String = AppTheme.system.rawValue

    // MARK: - Computed

    var thousandsSeparator: ThousandsSeparator {
        get { ThousandsSeparator(rawValue: thousandsSeparatorRaw) ?? .comma }
        set { thousandsSeparatorRaw = newValue.rawValue }
    }

    var theme: AppTheme {
        get { AppTheme(rawValue: themeRaw) ?? .system }
        set { themeRaw = newValue.rawValue }
    }

    var preferredColorScheme: ColorScheme? {
        switch theme {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

// MARK: - Enums

enum ThousandsSeparator: String, CaseIterable, Identifiable {
    case comma = "comma"
    case space = "space"
    case none = "none"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .comma: "1,234"
        case .space: "1 234"
        case .none: String(localized: "无")
        }
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: String(localized: "跟随系统")
        case .light: String(localized: "浅色")
        case .dark: String(localized: "深色")
        }
    }

    var sfSymbol: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light:  "sun.max"
        case .dark:   "moon"
        }
    }
}
