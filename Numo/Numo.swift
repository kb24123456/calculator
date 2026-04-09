//
//  Numo.swift
//  Numo
//
//  Created by 廖云丰 on 2026/4/9.
//

import WidgetKit
import SwiftUI

// MARK: - Gold Price Widget

struct GoldPriceProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> GoldPriceEntry {
        GoldPriceEntry(date: Date(), configuration: GoldPriceIntent(), pricePerGram: 980, isLive: false)
    }

    func snapshot(for configuration: GoldPriceIntent, in context: Context) async -> GoldPriceEntry {
        let price = await fetchGoldPrice()
        return GoldPriceEntry(date: Date(), configuration: configuration, pricePerGram: price.price, isLive: price.isLive)
    }

    func timeline(for configuration: GoldPriceIntent, in context: Context) async -> Timeline<GoldPriceEntry> {
        let price = await fetchGoldPrice()
        let entry = GoldPriceEntry(date: Date(), configuration: configuration, pricePerGram: price.price, isLive: price.isLive)
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func fetchGoldPrice() async -> (price: Double, isLive: Bool) {
        // Try Stooq API for XAUCNY
        let urlString = "https://stooq.com/q/l/?f=sd2t2ohlcv&h&e=json&s=xaucny"
        guard let url = URL(string: urlString) else { return (980, false) }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            var json = String(data: data, encoding: String.Encoding.utf8) ?? ""
            // Fix malformed Stooq JSON (empty "volume": field)
            json = json.replacingOccurrences(
                of: #",\s*"volume"\s*:"#,
                with: "",
                options: NSString.CompareOptions.regularExpression
            )
            guard let fixedData = json.data(using: String.Encoding.utf8) else { return (980, false) }

            let response = try JSONDecoder().decode(StooqResponse.self, from: fixedData)
            if let symbol = response.symbols.first, let close = symbol.close {
                let gramsPerOz = 31.1035
                let pricePerGram = close / gramsPerOz
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                f.timeZone = TimeZone(identifier: "Asia/Shanghai")
                let isLive = symbol.date == f.string(from: Date())
                return (pricePerGram, isLive)
            }
        } catch {}

        return (980, false)
    }
}

// Stooq JSON models (simplified for widget)
private struct StooqResponse: Decodable {
    let symbols: [StooqSymbol]
}

private struct StooqSymbol: Decodable {
    let close: Double?
    let date: String?
}

struct GoldPriceEntry: TimelineEntry {
    let date: Date
    let configuration: GoldPriceIntent
    let pricePerGram: Double
    let isLive: Bool
}

struct GoldPriceWidgetView: View {
    var entry: GoldPriceEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .medium))
                Text("Au")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                Spacer()
                if entry.isLive {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.system(size: 9))
                }
            }
            .foregroundStyle(.secondary)

            Spacer(minLength: 2)

            // Price
            Text("¥\(formattedPrice)")
                .font(.system(size: family == .systemSmall ? 28 : 34, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            // Unit
            Text("每克")
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            Spacer(minLength: 2)

            // Timestamp
            Text(entry.date, style: .time)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: entry.pricePerGram)) ?? "—"
    }
}

struct GoldPriceWidget: Widget {
    let kind: String = "GoldPriceWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: GoldPriceIntent.self, provider: GoldPriceProvider()) { entry in
            GoldPriceWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("金价")
        .description("实时黄金价格（元/克）")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Currency Pair Widget

struct CurrencyPairProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CurrencyPairEntry {
        CurrencyPairEntry(date: Date(), configuration: CurrencyPairIntent(), rate: 7.25, isLive: false)
    }

    func snapshot(for configuration: CurrencyPairIntent, in context: Context) async -> CurrencyPairEntry {
        let result = await fetchRate(source: configuration.sourceCurrency, target: configuration.targetCurrency)
        return CurrencyPairEntry(date: Date(), configuration: configuration, rate: result.rate, isLive: result.isLive)
    }

    func timeline(for configuration: CurrencyPairIntent, in context: Context) async -> Timeline<CurrencyPairEntry> {
        let result = await fetchRate(source: configuration.sourceCurrency, target: configuration.targetCurrency)
        let entry = CurrencyPairEntry(date: Date(), configuration: configuration, rate: result.rate, isLive: result.isLive)
        // Refresh every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func fetchRate(source: String, target: String) async -> (rate: Double, isLive: Bool) {
        let urlString = "https://api.frankfurter.app/latest?from=\(source)&to=\(target)"
        guard let url = URL(string: urlString) else { return (7.25, false) }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if let rates = json?["rates"] as? [String: Double],
               let rate = rates[target] {
                return (rate, true)
            }
        } catch {}

        return (7.25, false)
    }
}

struct CurrencyPairEntry: TimelineEntry {
    let date: Date
    let configuration: CurrencyPairIntent
    let rate: Double
    let isLive: Bool
}

struct CurrencyPairWidgetView: View {
    var entry: CurrencyPairEntry

    private var source: String { entry.configuration.sourceCurrency }
    private var target: String { entry.configuration.targetCurrency }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "coloncurrencysign.arrow.trianglehead.counterclockwise.rotate.90")
                    .font(.system(size: 11, weight: .medium))
                Text("\(source)/\(target)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                Spacer()
                if entry.isLive {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.system(size: 9))
                }
            }
            .foregroundStyle(.secondary)

            Spacer(minLength: 2)

            // Rate
            Text(formattedRate)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            // Description
            Text("1 \(source) =")
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)

            Spacer(minLength: 2)

            // Timestamp
            Text(entry.date, style: .time)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var formattedRate: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: entry.rate)) ?? "—"
    }
}

struct CurrencyPairWidget: Widget {
    let kind: String = "CurrencyPairWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: CurrencyPairIntent.self, provider: CurrencyPairProvider()) { entry in
            CurrencyPairWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("汇率")
        .description("实时货币汇率")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    GoldPriceWidget()
} timeline: {
    GoldPriceEntry(date: .now, configuration: GoldPriceIntent(), pricePerGram: 982.35, isLive: true)
}
