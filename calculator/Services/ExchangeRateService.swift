//
//  ExchangeRateService.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

protocol ExchangeRateServiceProtocol: Sendable {
    func fetchRates(base: String) async throws -> [String: Decimal]
}

actor ExchangeRateServiceImpl: ExchangeRateServiceProtocol {
    private let session: URLSession
    private var cachedRates: [String: Decimal] = [:]
    private var lastFetched: Date?

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchRates(base: String) async throws -> [String: Decimal] {
        // Return cache if fresh enough
        if let lastFetched, Date().timeIntervalSince(lastFetched) < Constants.API.exchangeRateCacheMaxAge,
           !cachedRates.isEmpty {
            return cachedRates
        }

        guard let url = URL(string: "\(Constants.API.exchangeRateBaseURL)?from=\(base)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = Constants.API.exchangeRateTimeout

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(FrankfurterResponse.self, from: data)

        var rates: [String: Decimal] = [:]
        for (key, value) in decoded.rates {
            rates[key] = Decimal(value)
        }

        cachedRates = rates
        lastFetched = Date()

        return rates
    }
}

private struct FrankfurterResponse: Decodable {
    let base: String
    let date: String
    let rates: [String: Double]
}
