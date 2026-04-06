//
//  IncomeTaxViewModel.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

@Observable
final class IncomeTaxViewModel {
    var monthlySalaryText: String = ""
    var socialInsurance = SocialInsuranceConfig()
    var specialDeductionsText: String = "0"
    var result: TaxResult?
    var showBreakdown: Bool = false
    var housingFundPercent: Double = 7  // slider 5-12

    func calculate() {
        let cleaned = monthlySalaryText.withoutGroupingSeparators
        guard let salary = Decimal(string: cleaned), salary > 0 else {
            result = nil
            return
        }

        socialInsurance.housingFundRate = Decimal(housingFundPercent) / 100

        let specialDeductions = Decimal(string: specialDeductionsText.withoutGroupingSeparators) ?? 0

        result = ChineseTaxCalculator.calculate(
            monthlyGross: salary,
            socialInsurance: socialInsurance,
            monthlySpecialDeductions: specialDeductions
        )
    }
}
