//
//  ExpressionParser.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

enum ParseError: Error, Equatable {
    case invalidCharacter(Character)
    case invalidNumber(String)
    case emptyExpression
    case unexpectedToken
}

struct ExpressionParser {

    /// Parse a user-input expression string into tokens.
    static func parse(_ input: String) throws -> [CalcToken] {
        let cleaned = input
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "*", with: "×")
            .replacingOccurrences(of: "/", with: "÷")

        guard !cleaned.isEmpty else {
            throw ParseError.emptyExpression
        }

        var tokens: [CalcToken] = []
        var index = cleaned.startIndex

        while index < cleaned.endIndex {
            let ch = cleaned[index]

            if ch.isDigit || ch == "." {
                let number = consumeNumber(from: cleaned, at: &index)
                guard let decimal = Decimal(string: number) else {
                    throw ParseError.invalidNumber(number)
                }
                insertImplicitMultiplication(into: &tokens)
                tokens.append(.number(decimal))
            } else if ch == "(" {
                insertImplicitMultiplication(into: &tokens)
                tokens.append(.openParen)
                index = cleaned.index(after: index)
            } else if ch == ")" {
                tokens.append(.closeParen)
                index = cleaned.index(after: index)
            } else if let op = operatorFrom(ch) {
                if op == .subtract && shouldTreatAsUnaryMinus(tokens: tokens) {
                    tokens.append(.unaryMinus)
                } else {
                    // Replace consecutive operators: keep the latest one
                    if case .op = tokens.last {
                        tokens.removeLast()
                    }
                    tokens.append(.op(op))
                }
                index = cleaned.index(after: index)
            } else if ch == "π" {
                insertImplicitMultiplication(into: &tokens)
                tokens.append(.number(Decimal(string: "3.14159265358979323846")!))
                index = cleaned.index(after: index)
            } else if ch == "e" && !isPartOfFunctionName(cleaned, at: index) {
                insertImplicitMultiplication(into: &tokens)
                tokens.append(.number(Decimal(string: "2.71828182845904523536")!))
                index = cleaned.index(after: index)
            } else if ch.isLetter {
                let name = consumeFunctionName(from: cleaned, at: &index)
                if let fn = ScientificFunction(rawValue: name) {
                    insertImplicitMultiplication(into: &tokens)
                    tokens.append(.function(fn))
                } else {
                    throw ParseError.invalidCharacter(ch)
                }
            } else if ch == "√" {
                insertImplicitMultiplication(into: &tokens)
                tokens.append(.function(.sqrt))
                index = cleaned.index(after: index)
            } else if ch == "!" {
                tokens.append(.function(.factorial))
                index = cleaned.index(after: index)
            } else {
                throw ParseError.invalidCharacter(ch)
            }
        }

        return tokens
    }

    // MARK: - Helpers

    private static func consumeNumber(from str: String, at index: inout String.Index) -> String {
        var result = ""
        var hasDecimal = false
        while index < str.endIndex {
            let ch = str[index]
            if ch.isDigit {
                result.append(ch)
                index = str.index(after: index)
            } else if ch == "." && !hasDecimal {
                hasDecimal = true
                result.append(ch)
                index = str.index(after: index)
            } else {
                break
            }
        }
        return result
    }

    private static func consumeFunctionName(from str: String, at index: inout String.Index) -> String {
        var name = ""
        while index < str.endIndex && str[index].isLetter {
            name.append(str[index])
            index = str.index(after: index)
        }
        return name
    }

    private static func operatorFrom(_ ch: Character) -> Operator? {
        switch ch {
        case "+": .add
        case "-", "−": .subtract
        case "×", "*": .multiply
        case "÷", "/": .divide
        case "%": .percent
        default: nil
        }
    }

    private static func shouldTreatAsUnaryMinus(tokens: [CalcToken]) -> Bool {
        guard let last = tokens.last else { return true }
        switch last {
        case .op, .openParen, .unaryMinus:
            return true
        default:
            return false
        }
    }

    private static func insertImplicitMultiplication(into tokens: inout [CalcToken]) {
        guard let last = tokens.last else { return }
        switch last {
        case .number, .closeParen:
            // e.g., "2(" or ")(" or "2π" → insert ×
            tokens.append(.op(.multiply))
        default:
            break
        }
    }

    private static func isPartOfFunctionName(_ str: String, at index: String.Index) -> Bool {
        // Check if "e" is the start of a function name like "exp"
        let remaining = str[index...]
        for fn in ScientificFunction.allCases {
            if remaining.hasPrefix(fn.rawValue) && fn.rawValue.count > 1 {
                return true
            }
        }
        return false
    }
}

private extension Character {
    var isDigit: Bool {
        self >= "0" && self <= "9"
    }
}
