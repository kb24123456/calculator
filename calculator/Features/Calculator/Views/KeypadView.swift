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
    let onAns: () -> Void
    var operatorOnRight: Bool = true

    private let spacing = NumoSpacing.keypadGap

    var body: some View {
        VStack(spacing: spacing) {
            // Row 1: C  %  ⌫  ÷
            keyRow {
                CalcButton("C", type: .function) { onClear() }
                CalcButton("%", type: .function) { onPercent() }
                deleteButton
                CalcButton("÷", type: .op) { onOperator("÷") }
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

            // Row 5: Ans  0  .  =
            keyRow {
                if operatorOnRight {
                    CalcButton("Ans", type: .function) { onAns() }
                    CalcButton("0") { onCharacter("0") }
                    CalcButton(".", type: .function) { onCharacter(".") }
                    CalcButton("=", type: .equals) { onEquals() }
                } else {
                    CalcButton("=", type: .equals) { onEquals() }
                    CalcButton(".", type: .function) { onCharacter(".") }
                    CalcButton("0") { onCharacter("0") }
                    CalcButton("Ans", type: .function) { onAns() }
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
        onAns: {}
    )
    .frame(height: 350)
    .padding()
}
