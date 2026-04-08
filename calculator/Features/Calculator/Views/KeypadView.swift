//
//  KeypadView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct KeypadView: View {
    let onCharacter: (String) -> Void
    let onOperator: (String) -> Void
    let onDelete: () -> Void
    let onClear: () -> Void
    let onPercent: () -> Void
    let onEquals: () -> Void
    let onUndo: () -> Void
    var operatorOnRight: Bool = true
    var canUndo: Bool = false

    @State private var undoBounceTrigger: Int = 0

    private let spacing = NumoSpacing.keypadGap

    var body: some View {
        VStack(spacing: spacing) {
            // Row 1: C  %  ⌫  ÷
            keyRow {
                if operatorOnRight {
                    CalcButton("C", type: .function) { onClear() }
                    CalcButton("%", type: .function) { onPercent() }
                    deleteButton
                    CalcButton("÷", type: .op) { onOperator("÷") }
                } else {
                    CalcButton("÷", type: .op) { onOperator("÷") }
                    CalcButton("C", type: .function) { onClear() }
                    CalcButton("%", type: .function) { onPercent() }
                    deleteButton
                }
            }

            // Row 2: 7  8  9  ×
            keyRow {
                if operatorOnRight {
                    numberGroup("7", "8", "9")
                    CalcButton("×", type: .op) { onOperator("×") }
                } else {
                    CalcButton("×", type: .op) { onOperator("×") }
                    numberGroup("7", "8", "9")
                }
            }

            // Row 3: 4  5  6  −
            keyRow {
                if operatorOnRight {
                    numberGroup("4", "5", "6")
                    CalcButton("−", type: .op) { onOperator("-") }
                } else {
                    CalcButton("−", type: .op) { onOperator("-") }
                    numberGroup("4", "5", "6")
                }
            }

            // Row 4: 1  2  3  +
            keyRow {
                if operatorOnRight {
                    numberGroup("1", "2", "3")
                    CalcButton("+", type: .op) { onOperator("+") }
                } else {
                    CalcButton("+", type: .op) { onOperator("+") }
                    numberGroup("1", "2", "3")
                }
            }

            // Row 5: Undo  0  .  =
            keyRow {
                if operatorOnRight {
                    undoButton
                    CalcButton("0") { onCharacter("0") }
                    CalcButton(".", type: .function) { onCharacter(".") }
                    CalcButton("=", type: .equals) { onEquals() }
                } else {
                    CalcButton("=", type: .equals) { onEquals() }
                    CalcButton(".", type: .function) { onCharacter(".") }
                    CalcButton("0") { onCharacter("0") }
                    undoButton
                }
            }
        }
        .padding(.vertical, NumoSpacing.xxs)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func keyRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: spacing) {
            content()
        }
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private func numberGroup(_ a: String, _ b: String, _ c: String) -> some View {
        CalcButton(a) { onCharacter(a) }
        CalcButton(b) { onCharacter(b) }
        CalcButton(c) { onCharacter(c) }
    }

    // MARK: - Undo Button

    @State private var undoPressed = false

    private var undoButton: some View {
        Image(systemName: "arrow.uturn.backward")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(canUndo ? NumoColors.textPrimary : NumoColors.textPrimary.opacity(0.3))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .symbolEffect(.bounce, options: .speed(1.5), value: undoBounceTrigger)
            .background(
                GeometryReader { geo in
                    let r = min(geo.size.width, geo.size.height) * 0.22
                    RoundedRectangle(cornerRadius: r, style: .continuous)
                        .fill(NumoColors.keyPressHighlight)
                }
                .opacity(undoPressed ? 1 : 0)
                .animation(NumoAnimations.keyHighlight, value: undoPressed)
            )
            .scaleEffect(undoPressed ? 0.95 : 1.0)
            .animation(NumoAnimations.buttonPress, value: undoPressed)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !undoPressed { undoPressed = true }
                    }
                    .onEnded { value in
                        undoPressed = false
                        let dist = hypot(value.translation.width, value.translation.height)
                        guard canUndo, dist < 20 else { return }
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.8)
                        undoBounceTrigger += 1
                        onUndo()
                    }
            )
            .accessibilityLabel(String(localized: "撤销"))
            .accessibilityHint(String(localized: "撤销上一步操作"))
            .accessibilityAddTraits(.isButton)
            .accessibilityRemoveTraits(.isImage)
    }

    // MARK: - Delete Button with long-press

    private var deleteButton: some View {
        var btn = CalcButton("⌫", type: .function) { onDelete() }
        btn.onLongPressDelete = { onDelete() }
        btn.onLongPressClear = { onClear() }
        return btn
    }
}


#Preview {
    KeypadView(
        onCharacter: { _ in },
        onOperator: { _ in },
        onDelete: {},
        onClear: {},
        onPercent: {},
        onEquals: {},
        onUndo: {},
        canUndo: true
    )
    .frame(height: 350)
    .padding()
}
