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
    static let success = Color(light: .init(red: 0.20, green: 0.78, blue: 0.35),
                                dark: .init(red: 0.19, green: 0.82, blue: 0.35))
    static let danger = Color(light: .init(red: 1.0, green: 0.23, blue: 0.19),
                               dark: .init(red: 1.0, green: 0.27, blue: 0.23))
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
