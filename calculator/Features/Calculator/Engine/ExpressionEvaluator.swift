//
//  ExpressionEvaluator.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

enum EvaluationError: Error, Equatable {
    case divisionByZero
    case unmatchedParentheses
    case invalidExpression
    case overflow
    case domainError(String)
}

struct ExpressionEvaluator {

    /// Evaluate an array of CalcTokens using the Shunting-yard algorithm.
    /// Returns a Decimal result. All arithmetic uses Decimal for financial precision.
    static func evaluate(_ tokens: [CalcToken]) throws -> Decimal {
        guard !tokens.isEmpty else {
            throw EvaluationError.invalidExpression
        }

        // Pre-process: handle contextual percentage
        let processed = preprocessPercentage(tokens)

        // Shunting-yard: convert infix to postfix (RPN)
        var outputQueue: [CalcToken] = []
        var operatorStack: [CalcToken] = []

        for token in processed {
            switch token {
            case .number:
                outputQueue.append(token)

            case .op(let op):
                while let top = operatorStack.last {
                    if case .op(let topOp) = top,
                       (topOp.precedence > op.precedence) ||
                       (topOp.precedence == op.precedence && op.isLeftAssociative) {
                        outputQueue.append(operatorStack.removeLast())
                    } else if case .function = top {
                        outputQueue.append(operatorStack.removeLast())
                    } else {
                        break
                    }
                }
                operatorStack.append(token)

            case .function:
                operatorStack.append(token)

            case .openParen:
                operatorStack.append(token)

            case .closeParen:
                while let top = operatorStack.last {
                    if case .openParen = top {
                        operatorStack.removeLast()
                        // If top of stack is a function, pop it to output
                        if let fn = operatorStack.last, case .function = fn {
                            outputQueue.append(operatorStack.removeLast())
                        }
                        break
                    } else {
                        outputQueue.append(operatorStack.removeLast())
                    }
                }

            case .unaryMinus:
                operatorStack.append(token)
            }
        }

        while let top = operatorStack.popLast() {
            if case .openParen = top {
                throw EvaluationError.unmatchedParentheses
            }
            outputQueue.append(top)
        }

        // Evaluate postfix
        var stack: [Decimal] = []

        for token in outputQueue {
            switch token {
            case .number(let value):
                stack.append(value)

            case .op(let op):
                guard stack.count >= 2 else {
                    throw EvaluationError.invalidExpression
                }
                let right = stack.removeLast()
                let left = stack.removeLast()
                let result = try applyOperator(op, left: left, right: right)
                stack.append(result)

            case .unaryMinus:
                guard let value = stack.popLast() else {
                    throw EvaluationError.invalidExpression
                }
                stack.append(-value)

            case .function(let fn):
                guard let value = stack.popLast() else {
                    throw EvaluationError.invalidExpression
                }
                let result = try applyFunction(fn, value: value)
                stack.append(result)

            case .openParen, .closeParen:
                throw EvaluationError.invalidExpression
            }
        }

        guard stack.count == 1 else {
            throw EvaluationError.invalidExpression
        }

        return stack[0]
    }

    // MARK: - Operators

    private static func applyOperator(_ op: Operator, left: Decimal, right: Decimal) throws -> Decimal {
        switch op {
        case .add:
            return left + right
        case .subtract:
            return left - right
        case .multiply:
            return left * right
        case .divide:
            guard right != 0 else { throw EvaluationError.divisionByZero }
            return left / right
        case .percent:
            // Should be pre-processed, but fallback
            return left * right / 100
        }
    }

    // MARK: - Functions

    private static func applyFunction(_ fn: ScientificFunction, value: Decimal) throws -> Decimal {
        let doubleVal = NSDecimalNumber(decimal: value).doubleValue
        let result: Double

        switch fn {
        case .sin: result = Darwin.sin(doubleVal)
        case .cos: result = Darwin.cos(doubleVal)
        case .tan: result = Darwin.tan(doubleVal)
        case .asin:
            guard doubleVal >= -1 && doubleVal <= 1 else {
                throw EvaluationError.domainError("asin requires input in [-1, 1]")
            }
            result = Darwin.asin(doubleVal)
        case .acos:
            guard doubleVal >= -1 && doubleVal <= 1 else {
                throw EvaluationError.domainError("acos requires input in [-1, 1]")
            }
            result = Darwin.acos(doubleVal)
        case .atan: result = Darwin.atan(doubleVal)
        case .ln:
            guard doubleVal > 0 else {
                throw EvaluationError.domainError("ln requires positive input")
            }
            result = Darwin.log(doubleVal)
        case .log:
            guard doubleVal > 0 else {
                throw EvaluationError.domainError("log requires positive input")
            }
            result = Darwin.log10(doubleVal)
        case .sqrt:
            guard doubleVal >= 0 else {
                throw EvaluationError.domainError("sqrt requires non-negative input")
            }
            result = Darwin.sqrt(doubleVal)
        case .factorial:
            let intVal = Int(doubleVal)
            guard doubleVal == Double(intVal) && intVal >= 0 && intVal <= 170 else {
                throw EvaluationError.domainError("factorial requires non-negative integer ≤ 170")
            }
            var f: Decimal = 1
            if intVal >= 2 {
                for i in 2...intVal {
                    f *= Decimal(i)
                }
            }
            return f
        }

        guard result.isFinite else {
            throw EvaluationError.overflow
        }

        return Decimal(result)
    }

    // MARK: - Percentage Pre-processing

    /// Contextual percentage handling:
    /// - `10%` alone → `0.1`
    /// - `200+10%` → `200 × (1 + 10/100)` = `220`
    /// - `200-10%` → `200 × (1 - 10/100)` = `180`
    /// - `200×10%` → `200 × 0.1` = `20`
    private static func preprocessPercentage(_ tokens: [CalcToken]) -> [CalcToken] {
        var result: [CalcToken] = []

        var i = 0
        while i < tokens.count {
            let token = tokens[i]

            if case .op(.percent) = token {
                // Find the number before %
                if let lastNumberIndex = result.lastIndex(where: { if case .number = $0 { return true }; return false }),
                   case .number(let percentValue) = result[lastNumberIndex] {
                    // Check what's before the percent number
                    let beforeNumber = lastNumberIndex > 0 ? result[lastNumberIndex - 1] : nil

                    if case .op(let prevOp) = beforeNumber, (prevOp == .add || prevOp == .subtract) {
                        // Pattern: X + Y% → X × (1 + Y/100)
                        // Pattern: X - Y% → X × (1 - Y/100)
                        // Remove the operator and the number, then append × (1 op Y/100)
                        let opToken = result[lastNumberIndex - 1]
                        result.removeLast() // remove number(Y)
                        result.removeLast() // remove op(+/-)
                        result.append(.op(.multiply))
                        result.append(.openParen)
                        result.append(.number(1))
                        result.append(opToken)
                        result.append(.number(percentValue / 100))
                        result.append(.closeParen)
                    } else {
                        // Standalone or after × ÷: just divide by 100
                        result[lastNumberIndex] = .number(percentValue / 100)
                    }
                }
            } else {
                result.append(token)
            }
            i += 1
        }

        return result
    }
}
