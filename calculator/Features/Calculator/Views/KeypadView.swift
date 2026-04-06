//
//  KeypadView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct KeypadView: View {
    let viewModel: CalculatorViewModel
    let onEquals: () -> Void

    private let spacing = NumoSpacing.keypadGap

    var body: some View {
        VStack(spacing: spacing) {
            // Row 1: C  ⌫  %  ÷
            HStack(spacing: spacing) {
                CalcButton("C", type: .function) { viewModel.clear() }
                CalcButton("⌫", type: .function) { viewModel.deleteBackward() }
                CalcButton("%", type: .function) { viewModel.applyPercent() }
                CalcButton("÷", type: .op) { viewModel.appendOperator("÷") }
            }
            .frame(maxHeight: .infinity)

            // Row 2: 7  8  9  ×
            HStack(spacing: spacing) {
                CalcButton("7") { viewModel.appendCharacter("7") }
                CalcButton("8") { viewModel.appendCharacter("8") }
                CalcButton("9") { viewModel.appendCharacter("9") }
                CalcButton("×", type: .op) { viewModel.appendOperator("×") }
            }
            .frame(maxHeight: .infinity)

            // Row 3: 4  5  6  -
            HStack(spacing: spacing) {
                CalcButton("4") { viewModel.appendCharacter("4") }
                CalcButton("5") { viewModel.appendCharacter("5") }
                CalcButton("6") { viewModel.appendCharacter("6") }
                CalcButton("−", type: .op) { viewModel.appendOperator("-") }
            }
            .frame(maxHeight: .infinity)

            // Row 4: 1  2  3  +
            HStack(spacing: spacing) {
                CalcButton("1") { viewModel.appendCharacter("1") }
                CalcButton("2") { viewModel.appendCharacter("2") }
                CalcButton("3") { viewModel.appendCharacter("3") }
                CalcButton("+", type: .op) { viewModel.appendOperator("+") }
            }
            .frame(maxHeight: .infinity)

            // Row 5: 00  0  .  =
            HStack(spacing: spacing) {
                CalcButton("00") { viewModel.appendCharacter("00") }
                CalcButton("0") { viewModel.appendCharacter("0") }
                CalcButton(".", type: .function) { viewModel.appendCharacter(".") }
                CalcButton("=", type: .equals) { onEquals() }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.vertical, NumoSpacing.xs)
    }
}

#Preview {
    KeypadView(viewModel: CalculatorViewModel()) {}
        .frame(height: 400)
        .padding()
}
