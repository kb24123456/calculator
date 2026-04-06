//
//  TaxBracket.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

struct TaxBracket {
    let lowerBound: Decimal   // cumulative annual taxable income lower bound
    let upperBound: Decimal   // cumulative annual taxable income upper bound
    let rate: Decimal         // percentage
    let quickDeduction: Decimal

    /// China's 7-level progressive tax brackets (annual cumulative)
    static let brackets: [TaxBracket] = [
        TaxBracket(lowerBound: 0,       upperBound: 36000,   rate: 3,  quickDeduction: 0),
        TaxBracket(lowerBound: 36000,   upperBound: 144000,  rate: 10, quickDeduction: 2520),
        TaxBracket(lowerBound: 144000,  upperBound: 300000,  rate: 20, quickDeduction: 16920),
        TaxBracket(lowerBound: 300000,  upperBound: 420000,  rate: 25, quickDeduction: 31920),
        TaxBracket(lowerBound: 420000,  upperBound: 660000,  rate: 30, quickDeduction: 52920),
        TaxBracket(lowerBound: 660000,  upperBound: 960000,  rate: 35, quickDeduction: 85920),
        TaxBracket(lowerBound: 960000,  upperBound: Decimal.greatestFiniteMagnitude, rate: 45, quickDeduction: 181920),
    ]
}

struct SocialInsuranceConfig {
    var pensionRate: Decimal = Decimal(string: "0.08")!       // 8%
    var medicalRate: Decimal = Decimal(string: "0.02")!       // 2%
    var unemploymentRate: Decimal = Decimal(string: "0.005")!  // 0.5%
    var housingFundRate: Decimal = Decimal(string: "0.07")!    // 7% (adjustable 5-12%)

    var totalRate: Decimal {
        pensionRate + medicalRate + unemploymentRate + housingFundRate
    }
}

struct TaxResult {
    let monthlyGross: Decimal
    let monthlySocialInsurance: Decimal
    let monthlySpecialDeductions: Decimal
    let monthlyTax: [Decimal]          // 12 months
    let monthlyNetSalary: [Decimal]    // 12 months
    let annualGross: Decimal
    let annualTax: Decimal
    let annualNet: Decimal
    let effectiveTaxRate: Decimal
}
