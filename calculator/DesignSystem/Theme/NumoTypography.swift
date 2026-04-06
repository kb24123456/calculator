//
//  NumoTypography.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

enum NumoTypography {
    // MARK: - Display
    static let displayLarge = Font.system(size: 48, weight: .light, design: .rounded)
    static let displayMedium = Font.system(size: 36, weight: .light, design: .rounded)

    // MARK: - Title
    static let titleLarge = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let titleMedium = Font.system(size: 17, weight: .semibold, design: .rounded)

    // MARK: - Body
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .rounded)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .rounded)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .rounded)

    // MARK: - Caption
    static let caption = Font.system(size: 11, weight: .regular, design: .rounded)

    // MARK: - Keypad
    static let keypadLarge = Font.system(size: 28, weight: .medium, design: .rounded)
    static let keypadMedium = Font.system(size: 22, weight: .medium, design: .rounded)

    // MARK: - Monospaced for numeric results
    static let monoDisplayLarge = Font.system(size: 48, weight: .light, design: .rounded).monospacedDigit()
    static let monoDisplayMedium = Font.system(size: 36, weight: .light, design: .rounded).monospacedDigit()
    static let monoTitleLarge = Font.system(size: 22, weight: .semibold, design: .rounded).monospacedDigit()
}
