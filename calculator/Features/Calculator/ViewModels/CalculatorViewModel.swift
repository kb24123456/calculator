//
//  CalculatorViewModel.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI
import SwiftData

@Observable
final class CalculatorViewModel {
    var expressionString: String = ""
    var currentResult: String = ""
    var isError: Bool = false
    var errorShakeTrigger: Int = 0

    /// The formatted display of the expression
    var displayExpression: String {
        expressionString.isEmpty ? "0" : expressionString
    }

    // MARK: - Input

    func appendCharacter(_ char: String) {
        guard expressionString.count < Constants.Calculator.maxExpressionLength else { return }

        // Prevent multiple decimal points in current number
        if char == "." {
            let currentNumber = extractCurrentNumber()
            if currentNumber.contains(".") { return }
        }

        // Prevent leading zeros (except "0.")
        if char == "0" && extractCurrentNumber() == "0" { return }
        if char != "." && char != "0" && extractCurrentNumber() == "0" {
            // Replace the leading zero
            expressionString = String(expressionString.dropLast()) + char
            evaluate()
            return
        }

        isError = false
        expressionString += char
        evaluate()
    }

    func appendOperator(_ op: String) {
        isError = false

        // If expression ends with an operator, replace it
        if let last = expressionString.last, "+-×÷".contains(last) {
            expressionString = String(expressionString.dropLast()) + op
        } else if !expressionString.isEmpty {
            expressionString += op
        } else if op == "-" {
            // Allow negative number at start
            expressionString = "-"
        }
        evaluate()
    }

    func appendParenthesis() {
        let openCount = expressionString.filter { $0 == "(" }.count
        let closeCount = expressionString.filter { $0 == ")" }.count

        if let last = expressionString.last {
            if last.isNumber || last == ")" || last == "%" {
                if openCount > closeCount {
                    expressionString += ")"
                } else {
                    expressionString += "×("
                }
            } else {
                expressionString += "("
            }
        } else {
            expressionString += "("
        }
        evaluate()
    }

    func deleteBackward() {
        guard !expressionString.isEmpty else { return }
        expressionString.removeLast()
        isError = false
        evaluate()
    }

    func clear() {
        expressionString = ""
        currentResult = ""
        isError = false
    }

    func toggleSign() {
        guard !expressionString.isEmpty else { return }

        // Toggle sign of current number
        if expressionString.hasPrefix("-") {
            expressionString.removeFirst()
        } else {
            expressionString = "-" + expressionString
        }
        evaluate()
    }

    func applyPercent() {
        expressionString += "%"
        evaluate()
    }

    func calculateAndCommit(modelContext: ModelContext, appState: AppState) {
        guard !expressionString.isEmpty else { return }

        do {
            let tokens = try ExpressionParser.parse(expressionString)
            let result = try ExpressionEvaluator.evaluate(tokens)
            let formatted = ExpressionFormatter.format(result)
            currentResult = formatted

            // Save to history
            let record = CalculationRecord(
                expression: expressionString,
                result: formatted,
                resultDecimal: result
            )
            modelContext.insert(record)

            // Update shared state
            appState.lastResult = result

            // Replace expression with result for continued calculation
            expressionString = formatted.withoutGroupingSeparators
            isError = false
        } catch {
            isError = true
            errorShakeTrigger += 1
            currentResult = ""
        }
    }

    // MARK: - Live Evaluation

    private func evaluate() {
        guard !expressionString.isEmpty else {
            currentResult = ""
            return
        }

        do {
            let tokens = try ExpressionParser.parse(expressionString)
            let result = try ExpressionEvaluator.evaluate(tokens)
            currentResult = ExpressionFormatter.format(result)
            isError = false
        } catch {
            // During typing, errors are expected (incomplete expressions)
            currentResult = ""
        }
    }

    // MARK: - Helpers

    private func extractCurrentNumber() -> String {
        var number = ""
        for ch in expressionString.reversed() {
            if ch.isNumber || ch == "." {
                number = String(ch) + number
            } else {
                break
            }
        }
        return number
    }
}
