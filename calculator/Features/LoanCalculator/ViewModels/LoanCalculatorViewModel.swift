//
//  LoanCalculatorViewModel.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

@Observable
final class LoanCalculatorViewModel {
    var amountText: String = ""         // 万元
    var termMonths: Int = 360           // 30年
    var annualRateText: String = "3.45" // LPR
    var method: RepaymentMethod = .equalInstallment
    var result: LoanResult?
    var showSchedule: Bool = false

    static let termPresets = [
        (label: "5年", months: 60),
        (label: "10年", months: 120),
        (label: "15年", months: 180),
        (label: "20年", months: 240),
        (label: "25年", months: 300),
        (label: "30年", months: 360),
    ]

    static let ratePresets = [
        (label: "LPR 3.45%", rate: "3.45"),
        (label: "公积金 2.85%", rate: "2.85"),
    ]

    func calculate() {
        let cleaned = amountText.withoutGroupingSeparators
        guard let amountWan = Decimal(string: cleaned),
              let rate = Decimal(string: annualRateText),
              amountWan > 0 else {
            result = nil
            return
        }

        let principal = amountWan * 10000 // 万元 → 元
        let params = LoanParameters(principal: principal, annualRate: rate, termMonths: termMonths, method: method)
        result = LoanEngine.calculate(params)
    }
}
