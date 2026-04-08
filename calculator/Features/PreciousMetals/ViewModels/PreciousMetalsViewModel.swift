//
//  PreciousMetalsViewModel.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/9.
//

import SwiftUI

@Observable
final class PreciousMetalsViewModel {
    var mode: PreciousMetalsMode = .purchase

    // Input (shared across modes)
    var inputAmount: String = ""

    // Purchase mode outputs
    var goldGrams: String = ""
    var silverGrams: String = ""

    // Salary mode output
    var matchedRank: AncientRank?

    // Price state
    var metalPrice: MetalPrice = MetalPrice(
        goldPerGram: Constants.PreciousMetals.fallbackGoldPricePerGram,
        silverPerGram: Constants.PreciousMetals.fallbackSilverPricePerGram,
        lastUpdated: nil,
        isLive: false
    )
    var isLoading: Bool = false
    var loadFailed: Bool = false   // true if last fetch failed (showing fallback)

    private let service: MetalPriceServiceProtocol = MetalPriceServiceImpl()

    func loadPrices() async {
        isLoading = true
        loadFailed = false
        do {
            metalPrice = try await service.fetchPrices()
            convert()
        } catch {
            loadFailed = true   // keep existing prices (fallback or last live)
        }
        isLoading = false
    }

    func convert() {
        switch mode {
        case .purchase:
            convertPurchase()
        case .salary:
            convertSalary()
        }
    }

    private func convertPurchase() {
        let cleaned = inputAmount.withoutGroupingSeparators
        guard !cleaned.isEmpty, let value = Decimal(string: cleaned), value > 0 else {
            goldGrams = ""
            silverGrams = ""
            return
        }

        let gold = value / metalPrice.goldPerGram
        let silver = value / metalPrice.silverPerGram

        goldGrams = ExpressionFormatter.format(gold, maxDecimalPlaces: 2)
        silverGrams = ExpressionFormatter.format(silver, maxDecimalPlaces: 2)
    }

    private func convertSalary() {
        let cleaned = inputAmount.withoutGroupingSeparators
        guard !cleaned.isEmpty, let value = Decimal(string: cleaned) else {
            matchedRank = nil
            return
        }
        matchedRank = AncientRank.find(monthlySalary: value)
    }

    func updateFromLastResult(_ lastResult: Decimal?) {
        guard let value = lastResult else { return }
        inputAmount = ExpressionFormatter.format(value)
        convert()
    }
}
