//
//  LoanEngine.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

struct LoanEngine {
    /// Calculate loan repayment schedule.
    static func calculate(_ params: LoanParameters) -> LoanResult? {
        guard params.principal > 0, params.termMonths > 0, params.annualRate >= 0 else { return nil }

        let monthlyRate = params.annualRate / 100 / 12

        switch params.method {
        case .equalInstallment:
            return calculateEqualInstallment(principal: params.principal, monthlyRate: monthlyRate, months: params.termMonths)
        case .equalPrincipal:
            return calculateEqualPrincipal(principal: params.principal, monthlyRate: monthlyRate, months: params.termMonths)
        case .interestFirst:
            return calculateInterestFirst(principal: params.principal, monthlyRate: monthlyRate, months: params.termMonths)
        }
    }

    // MARK: - Equal Installment (等额本息)

    private static func calculateEqualInstallment(principal: Decimal, monthlyRate: Decimal, months: Int) -> LoanResult {
        if monthlyRate == 0 {
            // Zero interest
            let monthly = (principal / Decimal(months)).rounded(to: 2)
            var schedule: [AmortizationEntry] = []
            var remaining = principal
            for m in 1...months {
                let p = m == months ? remaining : monthly
                remaining -= p
                schedule.append(AmortizationEntry(month: m, payment: p, principal: p, interest: 0, remainingBalance: max(remaining, 0)))
            }
            return LoanResult(monthlyPayment: monthly, lastMonthPayment: nil, totalRepayment: principal, totalInterest: 0, principal: principal, schedule: schedule)
        }

        // M = P * r * (1+r)^n / ((1+r)^n - 1)
        let onePlusR = 1 + monthlyRate
        let onePlusRPowN = decimalPow(onePlusR, months)
        let monthlyPayment = (principal * monthlyRate * onePlusRPowN / (onePlusRPowN - 1)).rounded(to: 2)

        var schedule: [AmortizationEntry] = []
        var remaining = principal
        var totalInterest: Decimal = 0

        for m in 1...months {
            let interest = (remaining * monthlyRate).rounded(to: 2)
            let principalPart: Decimal
            if m == months {
                principalPart = remaining
            } else {
                principalPart = monthlyPayment - interest
            }
            remaining -= principalPart
            totalInterest += interest

            schedule.append(AmortizationEntry(
                month: m,
                payment: principalPart + interest,
                principal: principalPart,
                interest: interest,
                remainingBalance: max(remaining, 0)
            ))
        }

        let totalRepayment = principal + totalInterest

        return LoanResult(
            monthlyPayment: monthlyPayment,
            lastMonthPayment: nil,
            totalRepayment: totalRepayment,
            totalInterest: totalInterest,
            principal: principal,
            schedule: schedule
        )
    }

    // MARK: - Equal Principal (等额本金)

    private static func calculateEqualPrincipal(principal: Decimal, monthlyRate: Decimal, months: Int) -> LoanResult {
        let monthlyPrincipal = (principal / Decimal(months)).rounded(to: 2)
        var schedule: [AmortizationEntry] = []
        var remaining = principal
        var totalInterest: Decimal = 0

        for m in 1...months {
            let interest = (remaining * monthlyRate).rounded(to: 2)
            let p = m == months ? remaining : monthlyPrincipal
            let payment = p + interest
            remaining -= p
            totalInterest += interest

            schedule.append(AmortizationEntry(
                month: m,
                payment: payment,
                principal: p,
                interest: interest,
                remainingBalance: max(remaining, 0)
            ))
        }

        let totalRepayment = principal + totalInterest
        let firstPayment = schedule.first?.payment ?? 0
        let lastPayment = schedule.last?.payment ?? 0

        return LoanResult(
            monthlyPayment: firstPayment,
            lastMonthPayment: lastPayment,
            totalRepayment: totalRepayment,
            totalInterest: totalInterest,
            principal: principal,
            schedule: schedule
        )
    }

    // MARK: - Interest First (先息后本)
    // Every month pays interest only; full principal returned on last month.

    private static func calculateInterestFirst(principal: Decimal, monthlyRate: Decimal, months: Int) -> LoanResult {
        let monthlyInterest = (principal * monthlyRate).rounded(to: 2)
        var schedule: [AmortizationEntry] = []

        for m in 1...months {
            let isLast = m == months
            let principalPart: Decimal = isLast ? principal : 0
            let payment = monthlyInterest + principalPart
            let remaining: Decimal = isLast ? 0 : principal

            schedule.append(AmortizationEntry(
                month: m,
                payment: payment,
                principal: principalPart,
                interest: monthlyInterest,
                remainingBalance: remaining
            ))
        }

        let totalInterest   = monthlyInterest * Decimal(months)
        let totalRepayment  = principal + totalInterest
        let lastPayment     = monthlyInterest + principal

        return LoanResult(
            monthlyPayment:     monthlyInterest,   // regular monthly (interest only)
            lastMonthPayment:   lastPayment,       // last month repays principal too
            totalRepayment:     totalRepayment,
            totalInterest:      totalInterest,
            principal:          principal,
            schedule:           schedule
        )
    }
}
