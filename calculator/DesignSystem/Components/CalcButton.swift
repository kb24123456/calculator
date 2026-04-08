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

    @State private var isPressed = false

    // Delete long-press state
    @State private var isLongPressing = false
    @State private var longPressTimer: Timer?
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
        } else {
            standardContent
        }
    }

    // MARK: - Standard Button (number, op, function, equals)

    private var standardContent: some View {
        buttonLabel
            .background(pressHighlight)
            .scaleEffect(isPressed ? 0.88 : 1.0)
            .animation(NumoAnimations.buttonPress, value: isPressed)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed { isPressed = true }
                    }
                    .onEnded { value in
                        isPressed = false
                        let dist = hypot(value.translation.width, value.translation.height)
                        if dist < 20 {
                            triggerHaptic()
                            action()
                        }
                    }
            )
    }

    // MARK: - Delete Button (with long press rapid-delete)

    private var deleteButtonContent: some View {
        ZStack(alignment: .top) {
            buttonLabel
                .background(pressHighlight)
                .scaleEffect(isPressed ? 0.88 : 1.0)
                .animation(NumoAnimations.buttonPress, value: isPressed)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isPressed {
                                isPressed = true
                                // Start long-press detection after 0.3s
                                longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                                    DispatchQueue.main.async {
                                        startRapidDelete()
                                    }
                                }
                            }
                        }
                        .onEnded { value in
                            let dist = hypot(value.translation.width, value.translation.height)
                            if !isLongPressing && dist < 20 {
                                triggerHaptic()
                                action()
                            }
                            isPressed = false
                            longPressTimer?.invalidate()
                            longPressTimer = nil
                            stopRapidDelete()
                        }
                )

            // Clear bubble after sustained long press
            if showClearBubble {
                Text("AC")
                    .font(NumoTypography.bodySmall.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, NumoSpacing.sm)
                    .padding(.vertical, NumoSpacing.xxs)
                    .background(
                        Capsule().fill(NumoColors.chipSelected)
                    )
                    .contentShape(Capsule())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                let dist = hypot(value.translation.width, value.translation.height)
                                if dist < 30 {
                                    onLongPressClear?()
                                    isPressed = false
                                    longPressTimer?.invalidate()
                                    longPressTimer = nil
                                    stopRapidDelete()
                                }
                            }
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.5).combined(with: .opacity).combined(with: .offset(y: 10)),
                        removal: .opacity
                    ))
                    .offset(y: -36)
            }
        }
    }

    // MARK: - Button Label

    @ViewBuilder
    private var buttonLabel: some View {
        switch type {
        case .number:
            Text(label)
                .font(NumoTypography.keypadLarge)
                .foregroundStyle(NumoColors.textPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        }
    }

    // MARK: - Press Highlight

    @ViewBuilder
    private var pressHighlight: some View {
        if type == .number || type == .function || type == .op {
            GeometryReader { geo in
                let r = min(geo.size.width, geo.size.height) * 0.22
                ZStack {
                    RoundedRectangle(cornerRadius: r, style: .continuous)
                        .fill(NumoColors.keyPressHighlight)
                    RoundedRectangle(cornerRadius: r, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.45), .clear],
                                center: .init(x: 0.5, y: 0.35),
                                startRadius: 0,
                                endRadius: max(geo.size.width, geo.size.height) * 0.5
                            )
                        )
                }
            }
            .opacity(isPressed ? 1 : 0)
            .animation(NumoAnimations.keyHighlight, value: isPressed)
        }
    }

    // MARK: - Long Press Delete

    private func startRapidDelete() {
        isLongPressing = true
        deleteCount = 0

        deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { timer in
            DispatchQueue.main.async {
                deleteCount += 1
                onLongPressDelete?()
                triggerHaptic()

                if deleteCount == 5 {
                    timer.invalidate()
                    deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                        DispatchQueue.main.async {
                            deleteCount += 1
                            onLongPressDelete?()

                            if deleteCount >= 15 && !showClearBubble {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    showClearBubble = true
                                }
                            }
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
