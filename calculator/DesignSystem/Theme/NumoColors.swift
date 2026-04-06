//
//  NumoColors.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

enum NumoColors {
    // MARK: - Accent
    static let accent = Color("AccentColor")
    static let accentRed = Color(light: .init(red: 0.77, green: 0.25, blue: 0.25),
                                  dark: .init(red: 0.84, green: 0.32, blue: 0.32))

    // MARK: - Surface
    static let surface = Color(light: .white, dark: .black)
    static let surfaceSecondary = Color(light: .init(red: 0.95, green: 0.95, blue: 0.97),
                                         dark: .init(red: 0.11, green: 0.11, blue: 0.12))

    // MARK: - Text
    static let textPrimary = Color(light: .black, dark: .white)
    static let textSecondary = Color(light: .init(red: 0.24, green: 0.24, blue: 0.26).opacity(0.6),
                                      dark: .init(red: 0.92, green: 0.92, blue: 0.96).opacity(0.6))
    static let textTertiary = Color(light: .init(red: 0.24, green: 0.24, blue: 0.26).opacity(0.3),
                                     dark: .init(red: 0.92, green: 0.92, blue: 0.96).opacity(0.3))

    // MARK: - Divider
    static let divider = Color(light: .init(red: 0.24, green: 0.24, blue: 0.26).opacity(0.12),
                                dark: .init(red: 0.33, green: 0.33, blue: 0.35).opacity(0.3))

    // MARK: - Keypad
    static let keypadBackground = Color(light: .init(red: 0.95, green: 0.95, blue: 0.97),
                                         dark: .init(red: 0.11, green: 0.11, blue: 0.12))
    static let keyPressHighlight = Color(light: .black.opacity(0.08),
                                          dark: .white.opacity(0.12))

    // MARK: - Chip
    static let chipSelected = Color(light: .init(red: 0.15, green: 0.15, blue: 0.15),
                                     dark: .init(red: 0.85, green: 0.85, blue: 0.85))
    static let chipSelectedText = Color(light: .white, dark: .black)
    static let chipDefault = Color(light: .init(red: 0.95, green: 0.95, blue: 0.97),
                                    dark: .init(red: 0.17, green: 0.17, blue: 0.18))
    static let chipDefaultText = Color(light: .init(red: 0.24, green: 0.24, blue: 0.26).opacity(0.6),
                                        dark: .init(red: 0.92, green: 0.92, blue: 0.96).opacity(0.6))

    // MARK: - Semantic
    // 刻意回避正红/正绿的"股票盘面感"：
    // success → 深邃的青苔翠绿（Teal-Emerald），带冷色调，沉稳克制；
    // danger  → 暗玫瑰红（Muted Cardinal），降低饱和度，权威而不刺眼。
    static let success = Color(light: .init(red: 0.07, green: 0.64, blue: 0.46),
                                dark: .init(red: 0.13, green: 0.78, blue: 0.55))
    static let danger = Color(light: .init(red: 0.83, green: 0.24, blue: 0.24),
                               dark: .init(red: 0.89, green: 0.33, blue: 0.33))
    static let warning = Color(light: .init(red: 1.0, green: 0.58, blue: 0.0),
                                dark: .init(red: 1.0, green: 0.84, blue: 0.04))
}

// MARK: - Color convenience init for light/dark

extension Color {
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}
