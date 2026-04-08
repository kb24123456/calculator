//
//  LoanParameters.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

enum RepaymentMethod: String, CaseIterable {
    case equalInstallment  // 等额本息
    case equalPrincipal    // 等额本金
    case interestFirst     // 先息后本
}

struct LoanParameters {
    var principal: Decimal       // in 元
    var annualRate: Decimal      // percentage, e.g. 3.45
    var termMonths: Int
    var method: RepaymentMethod
}

struct LoanResult {
    let monthlyPayment: Decimal        // For equal installment (fixed). For equal principal, this is first month.
    let lastMonthPayment: Decimal?     // For equal principal only (last month payment)
    let totalRepayment: Decimal
    let totalInterest: Decimal
    let principal: Decimal
    let schedule: [AmortizationEntry]
}

struct AmortizationEntry: Identifiable {
    let id = UUID()
    let month: Int
    let payment: Decimal
    let principal: Decimal
    let interest: Decimal
    let remainingBalance: Decimal
}
