//
//  UnitConverterViewModel.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

@Observable
final class UnitConverterViewModel {
    var selectedCategory: UnitCategory = .length
    var sourceValue: String = ""
    var sourceUnit: UnitDefinition
    var targetUnit: UnitDefinition
    var convertedValue: String = ""

    init() {
        let units = UnitCategory.length.units
        sourceUnit = units[2]  // m
        targetUnit = units[3]  // km
    }

    func convert() {
        let cleaned = sourceValue.withoutGroupingSeparators
        guard !cleaned.isEmpty, let value = Decimal(string: cleaned) else {
            convertedValue = ""
            return
        }

        let baseValue = sourceUnit.toBase(value)
        let result = targetUnit.fromBase(baseValue)
        convertedValue = ExpressionFormatter.format(result, maxDecimalPlaces: 6)
    }

    func swapUnits() {
        let temp = sourceUnit
        sourceUnit = targetUnit
        targetUnit = temp
        convert()
    }

    func selectCategory(_ category: UnitCategory) {
        selectedCategory = category
        let units = category.units
        sourceUnit = units[0]
        targetUnit = units.count > 1 ? units[1] : units[0]
        convert()
    }

    func updateFromLastResult(_ lastResult: Decimal?) {
        guard let value = lastResult else { return }
        sourceValue = ExpressionFormatter.format(value)
        convert()
    }
}
