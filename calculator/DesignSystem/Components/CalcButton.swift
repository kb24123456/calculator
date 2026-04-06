//
//  CalcButton.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

enum CalcButtonType {
    case number
    case op
    case equals
    case function
}

struct CalcButton: View {
    let label: String
    let type: CalcButtonType
    let span: Int
    let action: () -> Void

    @State private var isHighlighted = false

    init(_ label: String, type: CalcButtonType = .number, span: Int = 1, action: @escaping () -> Void) {
        self.label = label
        self.type = type
        self.span = span
        self.action = action
    }

    var body: some View {
        Button {
            triggerHaptic()
            action()
        } label: {
            buttonContent
        }
        .buttonStyle(CalcButtonStyle(type: type))
    }

    @ViewBuilder
    private var buttonContent: some View {
        switch type {
        case .equals:
            Text(label)
                .font(NumoTypography.keypadLarge)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Capsule()
                        .fill(NumoColors.accentRed)
                )
        case .op:
            Text(label)
                .font(NumoTypography.keypadMedium)
                .foregroundStyle(NumoColors.accentRed)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .function:
            Text(label)
                .font(NumoTypography.keypadMedium)
                .foregroundStyle(NumoColors.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .number:
            Text(label)
                .font(NumoTypography.keypadLarge)
                .foregroundStyle(NumoColors.textPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func triggerHaptic() {
        let generator: UIImpactFeedbackGenerator
        let intensity: CGFloat
        switch type {
        case .number:
            generator = UIImpactFeedbackGenerator(style: .light)
            intensity = 0.6
        case .op:
            generator = UIImpactFeedbackGenerator(style: .light)
            intensity = 0.8
        case .equals:
            generator = UIImpactFeedbackGenerator(style: .medium)
            intensity = 0.9
        case .function:
            generator = UIImpactFeedbackGenerator(style: .rigid)
            intensity = 0.5
        }
        generator.impactOccurred(intensity: intensity)
    }
}

// MARK: - Button Style

private struct CalcButtonStyle: ButtonStyle {
    let type: CalcButtonType

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if type == .number || type == .function {
                        Circle()
                            .fill(NumoColors.keyPressHighlight)
                            .opacity(configuration.isPressed ? 1 : 0)
                            .animation(NumoAnimations.keyHighlight, value: configuration.isPressed)
                    }
                }
            )
            .scaleEffect(
                (type == .op || type == .equals) && configuration.isPressed ? 0.92 : 1.0
            )
            .animation(NumoAnimations.buttonPress, value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 8) {
            CalcButton("7") {}
            CalcButton("8") {}
            CalcButton("9") {}
            CalcButton("×", type: .op) {}
        }
        HStack(spacing: 8) {
            CalcButton("AC", type: .function) {}
            CalcButton("±", type: .function) {}
            CalcButton("%", type: .function) {}
            CalcButton("÷", type: .op) {}
        }
        CalcButton("=", type: .equals) {}
            .frame(height: 56)
    }
    .padding()
}
