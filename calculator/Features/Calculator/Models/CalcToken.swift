//
//  CalcToken.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

enum Operator: String, CaseIterable {
    case add = "+"
    case subtract = "-"
    case multiply = "×"
    case divide = "÷"
    case percent = "%"

    var precedence: Int {
        switch self {
        case .add, .subtract: 1
        case .multiply, .divide, .percent: 2
        }
    }

    var isLeftAssociative: Bool { true }
}

enum ScientificFunction: String, CaseIterable {
    case sin, cos, tan
    case asin, acos, atan
    case ln, log
    case sqrt = "√"
    case factorial = "!"
}

enum CalcToken: Equatable {
    case number(Decimal)
    case op(Operator)
    case function(ScientificFunction)
    case openParen
    case closeParen
    case unaryMinus
}
