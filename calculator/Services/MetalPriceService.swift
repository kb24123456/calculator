//
//  MetalPriceService.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

struct MetalPrice {
    let goldPerGram: Decimal
    let silverPerGram: Decimal
    let lastUpdated: Date?
    let isLive: Bool
}

protocol MetalPriceServiceProtocol: Sendable {
    func fetchPrices() async throws -> MetalPrice
}

/// Fetches intraday XAU/XAG vs CNY from Stooq (free, no key, minute-level).
/// Falls back to fawazahmed0 (daily) if Stooq is unavailable.
actor MetalPriceServiceImpl: MetalPriceServiceProtocol {
    private let session: URLSession
    private var cached: MetalPrice?
    private var lastFetched: Date?

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPrices() async throws -> MetalPrice {
        if let lastFetched, Date().timeIntervalSince(lastFetched) < Constants.API.exchangeRateCacheMaxAge,
           let cached {
            return cached
        }

        // Try Stooq first (real-time), fall back to fawazahmed0 (daily)
        let price: MetalPrice
        do {
            price = try await fetchFromStooq()
        } catch {
            price = try await fetchFromFawazahmed0()
        }

        cached = price
        lastFetched = Date()
        return price
    }

    // MARK: - Stooq (primary, intraday)

    private func fetchFromStooq() async throws -> MetalPrice {
        async let goldOz = fetchStooqClose(symbol: "xaucny")
        async let silverOz = fetchStooqClose(symbol: "xagcny")

        let (gold, silver) = try await (goldOz, silverOz)

        // Only mark as live if Stooq returned today's data (Shanghai timezone).
        // Before market open, Stooq still returns yesterday's close — isLive stays false.
        let today = stooqToday()
        let isLive = gold.date == today

        let gramsPerOz = Constants.PreciousMetals.gramsPerTroyOunce
        return MetalPrice(
            goldPerGram:   (Decimal(gold.close)   / gramsPerOz).rounded(to: 2),
            silverPerGram: (Decimal(silver.close) / gramsPerOz).rounded(to: 4),
            lastUpdated: Date(),
            isLive: isLive
        )
    }

    /// Today's date string in Asia/Shanghai, matching Stooq's date field format (yyyy-MM-dd).
    private func stooqToday() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "Asia/Shanghai")
        return f.string(from: Date())
    }

    /// Stooq response has a broken "volume": field with no value — strip it before decoding.
    private func fetchStooqClose(symbol: String) async throws -> (close: Double, date: String) {
        guard let url = URL(string: Constants.PreciousMetals.stooqBaseURL + symbol) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = Constants.PreciousMetals.metalPriceTimeout

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        // Fix malformed JSON: remove `,"volume":` and the trailing brace issue
        guard var json = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        // Remove the volume key which has no value, e.g. `,"volume":}`  or `,"volume":}]}`
        json = json.replacingOccurrences(
            of: #",\s*"volume"\s*:"#,
            with: "",
            options: NSString.CompareOptions.regularExpression
        )
        guard let fixedData = json.data(using: String.Encoding.utf8) else {
            throw URLError(.cannotDecodeContentData)
        }

        let decoded = try JSONDecoder().decode(StooqResponse.self, from: fixedData)
        guard let sym = decoded.symbols.first, let close = sym.close, close > 0 else {
            throw URLError(.cannotParseResponse)
        }
        return (close, sym.date)
    }

    // MARK: - fawazahmed0 (fallback, daily)

    private func fetchFromFawazahmed0() async throws -> MetalPrice {
        async let goldCNY = fetchFawazahmed0Rate(symbol: "xau",
                                                  base: Constants.PreciousMetals.metalPriceFallbackBaseURL)
        async let silverCNY = fetchFawazahmed0Rate(symbol: "xag",
                                                    base: Constants.PreciousMetals.metalPriceFallbackBaseURL)

        let (goldPerOz, silverPerOz) = try await (goldCNY, silverCNY)

        let gramsPerOz = Constants.PreciousMetals.gramsPerTroyOunce
        return MetalPrice(
            goldPerGram:   (Decimal(goldPerOz)   / gramsPerOz).rounded(to: 2),
            silverPerGram: (Decimal(silverPerOz) / gramsPerOz).rounded(to: 4),
            lastUpdated: Date(),
            isLive: false   // daily data, not intraday
        )
    }

    private func fetchFawazahmed0Rate(symbol: String, base: String) async throws -> Double {
        guard let url = URL(string: "\(base)/\(symbol).json") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = Constants.PreciousMetals.metalPriceTimeout

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            // Try mirror
            guard let mirrorURL = URL(string: "\(Constants.PreciousMetals.metalPriceFallbackMirrorURL)/\(symbol).json") else {
                throw URLError(.badURL)
            }
            var mirrorRequest = URLRequest(url: mirrorURL)
            mirrorRequest.timeoutInterval = Constants.PreciousMetals.metalPriceTimeout
            let (mirrorData, mirrorResponse) = try await session.data(for: mirrorRequest)
            guard let mirrorHttp = mirrorResponse as? HTTPURLResponse, mirrorHttp.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            return try decodeRates(from: mirrorData)
        }

        return try decodeRates(from: data)
    }

    /// Decode `{ "date": "...", "xau": { "cny": 32811.7, ... } }` → CNY rate
    private func decodeRates(from data: Data) throws -> Double {
        let decoded = try JSONDecoder().decode(MetalRateResponse.self, from: data)
        guard let cny = decoded.rates["cny"] else {
            throw URLError(.cannotParseResponse)
        }
        return cny
    }
}

// MARK: - Response Models

private struct StooqResponse: Decodable {
    let symbols: [StooqSymbol]
}

private struct StooqSymbol: Decodable {
    let symbol: String
    let date: String
    let time: String?
    let open: Double?
    let high: Double?
    let low: Double?
    let close: Double?
}

private struct MetalRateResponse: Decodable {
    let rates: [String: Double]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        var found: [String: Double]?
        for key in container.allKeys where key.stringValue != "date" {
            found = try container.decode([String: Double].self, forKey: key)
            break
        }
        guard let rates = found else {
            throw DecodingError.dataCorrupted(.init(codingPath: [],
                debugDescription: "No rates object found"))
        }
        self.rates = rates
    }
}

private struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    init(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { self.intValue = intValue; self.stringValue = "\(intValue)" }
}
