//
//  ChineseUppercaseViewModel.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

@Observable
final class ChineseUppercaseViewModel {
    var inputAmount: String = ""
    var uppercaseResult: String = ""
    var isOutOfRange: Bool = false

    func updateFromLastResult(_ lastResult: Decimal?) {
        guard let value = lastResult else { return }
        inputAmount = ExpressionFormatter.format(value)
        convert()
    }

    func convert() {
        let cleaned = inputAmount.withoutGroupingSeparators
        guard !cleaned.isEmpty, let amount = Decimal(string: cleaned) else {
            uppercaseResult = ""
            isOutOfRange = false
            return
        }

        if let result = ChineseUppercaseConverter.convert(amount) {
            uppercaseResult = result
            isOutOfRange = false
        } else {
            uppercaseResult = ""
            isOutOfRange = true
        }
    }
}
