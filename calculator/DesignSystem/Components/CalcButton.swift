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
    var onLongPressDelete: (() -> Void)?
    var onLongPressClear: (() -> Void)?

    @State private var isLongPressing = false
    @State private var deleteTimer: Timer?
    @State private var deleteCount = 0
    @State private var showClearBubble = false

    init(_ label: String, type: CalcButtonType = .number, span: Int = 1, action: @escaping () -> Void) {
        self.label = label
        self.type = type
        self.span = span
        self.action = action
    }

    var body: some View {
        if label == "⌫" {
            deleteButtonContent
        } else if type == .number {
            numberButtonContent
        } else {
            standardButtonContent
        }
    }

    // MARK: - Number Button (plain text + custom press highlight)

    private var numberButtonContent: some View {
        Button {
            triggerHaptic()
            action()
        } label: {
            Text(label)
                .font(NumoTypography.keypadLarge)
                .foregroundStyle(NumoColors.textPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(CalcButtonStyle(type: .number))
        .contentShape(Rectangle())
    }

    // MARK: - Standard Button (op, function, equals)

    private var standardButtonContent: some View {
        Button {
            triggerHaptic()
            action()
        } label: {
            nonNumberLabel
        }
        .buttonStyle(CalcButtonStyle(type: type))
        .contentShape(Rectangle())
    }

    // MARK: - Delete Button (with long press)

    private var deleteButtonContent: some View {
        ZStack(alignment: .top) {
            nonNumberLabel
                .contentShape(Rectangle())
                .onTapGesture {
                    triggerHaptic()
                    action()
                }
                .onLongPressGesture(minimumDuration: 0.3) {
                    // Long press recognized - start rapid delete
                    startRapidDelete()
                } onPressingChanged: { pressing in
                    if !pressing && isLongPressing {
                        stopRapidDelete()
                    }
                }

            // Clear bubble that appears after sustained long press
            if showClearBubble {
                Button {
                    onLongPressClear?()
                    stopRapidDelete()
                } label: {
                    Text("AC")
                        .font(NumoTypography.bodySmall.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, NumoSpacing.sm)
                        .padding(.vertical, NumoSpacing.xxs)
                        .background(
                            Capsule().fill(NumoColors.chipSelected)
                        )
                }
                .buttonStyle(.plain)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.5).combined(with: .opacity).combined(with: .offset(y: 10)),
                    removal: .opacity
                ))
                .offset(y: -36)
            }
        }
    }

    // MARK: - Non-number Label

    @ViewBuilder
    private var nonNumberLabel: some View {
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
            EmptyView() // handled by numberButtonContent
        }
    }

    // MARK: - Long Press Delete

    private func startRapidDelete() {
        isLongPressing = true
        deleteCount = 0

        // Initial medium-speed delete
        deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { timer in
            deleteCount += 1
            onLongPressDelete?()
            triggerHaptic()

            // After 5 deletes, accelerate
            if deleteCount == 5 {
                timer.invalidate()
                deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    deleteCount += 1
                    onLongPressDelete?()

                    // Show clear bubble after ~1.5s total
                    if deleteCount >= 15 && !showClearBubble {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            showClearBubble = true
                        }
                    }
                }
            }
        }
    }

    private func stopRapidDelete() {
        isLongPressing = false
        deleteTimer?.invalidate()
        deleteTimer = nil
        deleteCount = 0
        withAnimation(.easeOut(duration: 0.15)) {
            showClearBubble = false
        }
    }

    // MARK: - Haptics

    private func triggerHaptic() {
        let generator: UIImpactFeedbackGenerator
        let intensity: CGFloat
        switch type {
        case .number:
            generator = UIImpactFeedbackGenerator(style: .light)
            intensity = 0.8
        case .op:
            generator = UIImpactFeedbackGenerator(style: .medium)
            intensity = 1.0
        case .equals:
            generator = UIImpactFeedbackGenerator(style: .heavy)
            intensity = 1.0
        case .function:
            generator = UIImpactFeedbackGenerator(style: .medium)
            intensity = 0.8
        }
        generator.impactOccurred(intensity: intensity)
    }
}

// MARK: - Button Style (for non-number, non-glass keys)

private struct CalcButtonStyle: ButtonStyle {
    let type: CalcButtonType

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if type == .number || type == .function {
                        ZStack {
                            // Base dim layer
                            Circle()
                                .fill(NumoColors.keyPressHighlight)
                            // Specular highlight — radial white glow from center
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.white.opacity(0.45), .clear],
                                        center: .init(x: 0.5, y: 0.35),
                                        startRadius: 0,
                                        endRadius: 28
                                    )
                                )
                        }
                        .opacity(configuration.isPressed ? 1 : 0)
                        .animation(NumoAnimations.keyHighlight, value: configuration.isPressed)
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(NumoAnimations.buttonPress, value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 4) {
            CalcButton("7") {}
            CalcButton("8") {}
            CalcButton("9") {}
            CalcButton("×", type: .op) {}
        }
        .frame(height: 64)
        HStack(spacing: 4) {
            CalcButton("AC", type: .function) {}
            CalcButton("⌫", type: .function) {}
            CalcButton("%", type: .function) {}
            CalcButton("÷", type: .op) {}
        }
        .frame(height: 64)
        CalcButton("=", type: .equals) {}
            .frame(height: 64)
    }
    .padding()
}
