//
//  ChineseTaxCalculator.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

struct ChineseTaxCalculator {
    static let monthlyThreshold: Decimal = 5000

    /// Calculate monthly income tax using cumulative withholding method (累计预扣法).
    static func calculate(
        monthlyGross: Decimal,
        socialInsurance: SocialInsuranceConfig,
        monthlySpecialDeductions: Decimal = 0
    ) -> TaxResult? {
        guard monthlyGross > 0 else { return nil }

        let monthlySI = (monthlyGross * socialInsurance.totalRate).rounded(to: 2)
        let monthlyTaxableBase = monthlyGross - monthlyThreshold - monthlySI - monthlySpecialDeductions
        let effectiveTaxableBase = max(monthlyTaxableBase, 0)

        var monthlyTaxes: [Decimal] = []
        var monthlyNetSalaries: [Decimal] = []
        var cumulativeTax: Decimal = 0

        for month in 1...12 {
            let cumulativeTaxableIncome = effectiveTaxableBase * Decimal(month)

            // Find applicable bracket
            let tax = calculateCumulativeTax(cumulativeTaxableIncome)
            let monthTax = max(tax - cumulativeTax, 0).rounded(to: 2)
            cumulativeTax += monthTax

            monthlyTaxes.append(monthTax)

            let netSalary = monthlyGross - monthlySI - monthTax
            monthlyNetSalaries.append(netSalary)
        }

        let annualGross = monthlyGross * 12
        let annualTax = monthlyTaxes.reduce(0, +)
        let annualNet = annualGross - monthlySI * 12 - annualTax
        let effectiveTaxRate = annualGross > 0 ? (annualTax / annualGross * 100).rounded(to: 2) : 0

        return TaxResult(
            monthlyGross: monthlyGross,
            monthlySocialInsurance: monthlySI,
            monthlySpecialDeductions: monthlySpecialDeductions,
            monthlyTax: monthlyTaxes,
            monthlyNetSalary: monthlyNetSalaries,
            annualGross: annualGross,
            annualTax: annualTax,
            annualNet: annualNet,
            effectiveTaxRate: effectiveTaxRate
        )
    }

    /// Calculate cumulative tax using brackets and quick deduction method.
    private static func calculateCumulativeTax(_ cumulativeTaxableIncome: Decimal) -> Decimal {
        guard cumulativeTaxableIncome > 0 else { return 0 }

        for bracket in TaxBracket.brackets {
            if cumulativeTaxableIncome <= bracket.upperBound {
                return (cumulativeTaxableIncome * bracket.rate / 100 - bracket.quickDeduction).rounded(to: 2)
            }
        }

        // Should not reach here, but use the highest bracket
        let last = TaxBracket.brackets.last!
        return (cumulativeTaxableIncome * last.rate / 100 - last.quickDeduction).rounded(to: 2)
    }
}
