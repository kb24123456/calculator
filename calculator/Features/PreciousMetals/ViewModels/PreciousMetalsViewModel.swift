//
//  PreciousMetalsViewModel.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/9.
//

import SwiftUI

/// 买入模式三向输入：¥ → 克重、金克重 → ¥、银克重 → ¥
enum PreciousMetalsInputField { case money, gold, silver }

@Observable
final class PreciousMetalsViewModel {
    var mode: PreciousMetalsMode = .purchase

    // MARK: - Active input (purchase mode only)

    var activeInput: PreciousMetalsInputField = .money

    // MARK: - Raw input (always routed here by keypad)

    var inputAmount: String = ""

    // MARK: - Purchase mode outputs

    var goldGrams: String = ""
    var silverGrams: String = ""
    /// Computed ¥ when gold or silver is the active input
    var moneyResult: String = ""

    // MARK: - Salary mode output

    var matchedRank: AncientRank?

    // MARK: - Price state

    var metalPrice: MetalPrice = MetalPrice(
        goldPerGram: Constants.PreciousMetals.fallbackGoldPricePerGram,
        silverPerGram: Constants.PreciousMetals.fallbackSilverPricePerGram,
        lastUpdated: nil,
        isLive: false
    )
    var isLoading: Bool = false
    var loadFailed: Bool = false

    private let service: MetalPriceServiceProtocol = MetalPriceServiceImpl()

    // MARK: - Load

    func loadPrices() async {
        isLoading = true
        loadFailed = false
        do {
            metalPrice = try await service.fetchPrices()
            convert()
        } catch {
            loadFailed = true
        }
        isLoading = false
    }

    // MARK: - Convert dispatch

    func convert() {
        switch mode {
        case .purchase:
            switch activeInput {
            case .money:  convertFromMoney()
            case .gold:   convertFromGold()
            case .silver: convertFromSilver()
            }
        case .salary:
            convertSalary()
        }
    }

    private func convertFromMoney() {
        let cleaned = inputAmount.withoutGroupingSeparators
        guard !cleaned.isEmpty, let value = Decimal(string: cleaned), value > 0 else {
            goldGrams = ""; silverGrams = ""; return
        }
        goldGrams   = ExpressionFormatter.format(value / metalPrice.goldPerGram,  maxDecimalPlaces: 2)
        silverGrams = ExpressionFormatter.format(value / metalPrice.silverPerGram, maxDecimalPlaces: 2)
        moneyResult = ""
    }

    private func convertFromGold() {
        let cleaned = inputAmount.withoutGroupingSeparators
        guard !cleaned.isEmpty, let grams = Decimal(string: cleaned), grams > 0 else {
            moneyResult = ""; silverGrams = ""; return
        }
        let money = grams * metalPrice.goldPerGram
        moneyResult = ExpressionFormatter.format(money, maxDecimalPlaces: 2)
        silverGrams = ExpressionFormatter.format(money / metalPrice.silverPerGram, maxDecimalPlaces: 2)
        goldGrams   = ""
    }

    private func convertFromSilver() {
        let cleaned = inputAmount.withoutGroupingSeparators
        guard !cleaned.isEmpty, let grams = Decimal(string: cleaned), grams > 0 else {
            moneyResult = ""; goldGrams = ""; return
        }
        let money = grams * metalPrice.silverPerGram
        moneyResult = ExpressionFormatter.format(money, maxDecimalPlaces: 2)
        goldGrams   = ExpressionFormatter.format(money / metalPrice.goldPerGram,  maxDecimalPlaces: 2)
        silverGrams = ""
    }

    private func convertSalary() {
        let cleaned = inputAmount.withoutGroupingSeparators
        guard !cleaned.isEmpty, let value = Decimal(string: cleaned) else {
            matchedRank = nil; return
        }
        matchedRank = AncientRank.find(monthlySalary: value)
    }

    // MARK: - Active side management

    func setActive(_ field: PreciousMetalsInputField) {
        guard activeInput != field else { return }
        activeInput = field
        inputAmount = ""
        goldGrams   = ""
        silverGrams = ""
        moneyResult = ""
    }

    // MARK: - Clipboard fill

    func updateFromLastResult(_ lastResult: Decimal?) {
        guard let value = lastResult else { return }
        activeInput = .money
        inputAmount = ExpressionFormatter.format(value)
        convert()
    }
}
