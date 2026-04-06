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
    var previousExpression: String = ""
    var isError: Bool = false
    var errorShakeTrigger: Int = 0

    /// Whether there's a state that can be undone
    var canUndo: Bool { !undoStack.isEmpty }

    // MARK: - Undo Stack

    private struct CalcSnapshot {
        let previousExpression: String
        let currentResult: String
        let expressionString: String
    }

    private var undoStack: [CalcSnapshot] = []

    /// The formatted display of the expression
    var displayExpression: String {
        expressionString.isEmpty ? "0" : expressionString
    }

    // MARK: - Input

    func appendCharacter(_ char: String) {
        guard expressionString.count < Constants.Calculator.maxExpressionLength else { return }

        beginNewInput()

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
            return
        }

        isError = false
        expressionString += char
    }

    func appendOperator(_ op: String) {
        beginNewInput()
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
    }

    func appendParenthesis() {
        beginNewInput()
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
    }

    func deleteBackward() {
        guard !expressionString.isEmpty else { return }
        beginNewInput()
        expressionString.removeLast()
        isError = false
    }

    func clear() {
        expressionString = ""
        currentResult = ""
        previousExpression = ""
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
    }

    func applyPercent() {
        beginNewInput()
        expressionString += "%"
    }

    func calculateAndCommit(modelContext: ModelContext, appState: AppState) {
        guard !expressionString.isEmpty else { return }

        do {
            let tokens = try ExpressionParser.parse(expressionString)
            let result = try ExpressionEvaluator.evaluate(tokens)
            let formatted = ExpressionFormatter.format(result)

            // Save the expression that produced this result
            previousExpression = expressionString
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
            previousExpression = ""
        }
    }

    // MARK: - Undo

    func undo() {
        guard let snapshot = undoStack.popLast() else { return }
        previousExpression = snapshot.previousExpression
        currentResult = snapshot.currentResult
        expressionString = snapshot.expressionString
    }

    // MARK: - Helpers

    /// Transition from result-display mode back to expression-input mode.
    /// Saves the current result state to the undo stack so user can come back.
    private func beginNewInput() {
        guard !currentResult.isEmpty else { return }

        // Save result state for undo
        undoStack.append(CalcSnapshot(
            previousExpression: previousExpression,
            currentResult: currentResult,
            expressionString: expressionString
        ))

        // Clear result display — switches back to expression-only mode
        currentResult = ""
        previousExpression = ""
    }

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
