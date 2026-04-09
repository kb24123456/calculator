//
//  UnitConverterViewModel.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

enum UnitInputSide { case source, target }

@Observable
final class UnitConverterViewModel {
    var selectedCategory: UnitCategory = .length
    var sourceUnit: UnitDefinition
    var targetUnit: UnitDefinition

    // MARK: - Active side

    var activeInput: UnitInputSide = .source

    // MARK: - Raw inputs

    var sourceValue: String = ""
    var targetValue: String = ""

    // MARK: - Computed results

    /// Shown in target half when source is active
    var convertedValue: String = ""
    /// Shown in source half when target is active
    var sourceResult: String = ""

    init() {
        let units = UnitCategory.length.units
        sourceUnit = units[2]  // m
        targetUnit = units[3]  // km
    }

    // MARK: - Convert dispatch

    func convert() {
        switch activeInput {
        case .source: convertFromSource()
        case .target: convertFromTarget()
        }
    }

    func convertFromSource() {
        let cleaned = sourceValue.withoutGroupingSeparators
        guard !cleaned.isEmpty, let value = Decimal(string: cleaned) else {
            convertedValue = ""
            return
        }
        convertedValue = compute(value: value, from: sourceUnit, to: targetUnit)
    }

    func convertFromTarget() {
        let cleaned = targetValue.withoutGroupingSeparators
        guard !cleaned.isEmpty, let value = Decimal(string: cleaned) else {
            sourceResult = ""
            return
        }
        sourceResult = compute(value: value, from: targetUnit, to: sourceUnit)
    }

    private func compute(value: Decimal, from: UnitDefinition, to: UnitDefinition) -> String {
        let base = from.toBase(value)
        let result = to.fromBase(base)
        return ExpressionFormatter.format(result, maxDecimalPlaces: 6)
    }

    // MARK: - Active side management

    func setActive(_ side: UnitInputSide) {
        guard activeInput != side else { return }
        activeInput = side
        convert()
    }

    // MARK: - Swap

    func swapUnits() {
        let temp = sourceUnit
        sourceUnit = targetUnit
        targetUnit = temp
        activeInput = .source
        targetValue = ""
        sourceResult = ""
        convertFromSource()
    }

    // MARK: - Category

    func selectCategory(_ category: UnitCategory) {
        selectedCategory = category
        let units = category.units
        sourceUnit = units[0]
        targetUnit = units.count > 1 ? units[1] : units[0]
        activeInput = .source
        targetValue = ""
        sourceResult = ""
        convert()
    }

    // MARK: - Clipboard fill

    func updateFromLastResult(_ lastResult: Decimal?) {
        guard let value = lastResult else { return }
        activeInput = .source
        sourceValue = ExpressionFormatter.format(value)
        convertFromSource()
    }
}
