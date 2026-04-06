//
//  UnitCategory.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

enum UnitCategory: String, CaseIterable, Identifiable {
    case area = "area"
    case weight = "weight"
    case length = "length"
    case dataStorage = "dataStorage"
    case temperature = "temperature"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .area: String(localized: "面积")
        case .weight: String(localized: "重量")
        case .length: String(localized: "长度")
        case .dataStorage: String(localized: "数据")
        case .temperature: String(localized: "温度")
        }
    }

    var hudTitle: String {
        switch self {
        case .area: String(localized: "面积换算")
        case .weight: String(localized: "重量换算")
        case .length: String(localized: "长度换算")
        case .dataStorage: String(localized: "数据换算")
        case .temperature: String(localized: "温度换算")
        }
    }

    var sfSymbol: String {
        switch self {
        case .length: "ruler"
        case .weight: "scalemass"
        case .area: "square.on.square"
        case .temperature: "thermometer.medium"
        case .dataStorage: "internaldrive"
        }
    }

    var units: [UnitDefinition] {
        switch self {
        case .area: UnitDefinition.areaUnits
        case .weight: UnitDefinition.weightUnits
        case .length: UnitDefinition.lengthUnits
        case .dataStorage: UnitDefinition.dataStorageUnits
        case .temperature: UnitDefinition.temperatureUnits
        }
    }
}

struct UnitDefinition: Identifiable, Hashable {
    let id: String
    let nameKey: String
    let symbol: String
    let toBaseFactor: Decimal      // multiply to convert TO base unit
    let fromBaseOffset: Decimal    // add after conversion from base (temperature)
    let toBaseOffset: Decimal      // subtract before conversion to base (temperature)

    init(id: String, nameKey: String, symbol: String, toBaseFactor: Decimal, fromBaseOffset: Decimal = 0, toBaseOffset: Decimal = 0) {
        self.id = id
        self.nameKey = nameKey
        self.symbol = symbol
        self.toBaseFactor = toBaseFactor
        self.fromBaseOffset = fromBaseOffset
        self.toBaseOffset = toBaseOffset
    }

    func toBase(_ value: Decimal) -> Decimal {
        (value - toBaseOffset) * toBaseFactor
    }

    func fromBase(_ value: Decimal) -> Decimal {
        value / toBaseFactor + fromBaseOffset
    }

    // MARK: - Area (base: m²)
    static let areaUnits: [UnitDefinition] = [
        .init(id: "sqm", nameKey: "平方米", symbol: "m²", toBaseFactor: 1),
        .init(id: "sqkm", nameKey: "平方千米", symbol: "km²", toBaseFactor: 1_000_000),
        .init(id: "hectare", nameKey: "公顷", symbol: "ha", toBaseFactor: 10_000),
        .init(id: "mu", nameKey: "亩", symbol: "亩", toBaseFactor: Decimal(string: "666.6667")!),
        .init(id: "sqft", nameKey: "平方英尺", symbol: "ft²", toBaseFactor: Decimal(string: "0.09290304")!),
        .init(id: "sqmi", nameKey: "平方英里", symbol: "mi²", toBaseFactor: Decimal(string: "2589988.11")!),
        .init(id: "acre", nameKey: "英亩", symbol: "ac", toBaseFactor: Decimal(string: "4046.8564224")!),
    ]

    // MARK: - Weight (base: g)
    static let weightUnits: [UnitDefinition] = [
        .init(id: "mg", nameKey: "毫克", symbol: "mg", toBaseFactor: Decimal(string: "0.001")!),
        .init(id: "g", nameKey: "克", symbol: "g", toBaseFactor: 1),
        .init(id: "kg", nameKey: "千克", symbol: "kg", toBaseFactor: 1000),
        .init(id: "t", nameKey: "吨", symbol: "t", toBaseFactor: 1_000_000),
        .init(id: "jin", nameKey: "斤", symbol: "斤", toBaseFactor: 500),
        .init(id: "liang", nameKey: "两", symbol: "两", toBaseFactor: 50),
        .init(id: "lb", nameKey: "磅", symbol: "lb", toBaseFactor: Decimal(string: "453.59237")!),
        .init(id: "oz", nameKey: "盎司", symbol: "oz", toBaseFactor: Decimal(string: "28.3495231")!),
    ]

    // MARK: - Length (base: m)
    static let lengthUnits: [UnitDefinition] = [
        .init(id: "mm", nameKey: "毫米", symbol: "mm", toBaseFactor: Decimal(string: "0.001")!),
        .init(id: "cm", nameKey: "厘米", symbol: "cm", toBaseFactor: Decimal(string: "0.01")!),
        .init(id: "m", nameKey: "米", symbol: "m", toBaseFactor: 1),
        .init(id: "km", nameKey: "千米", symbol: "km", toBaseFactor: 1000),
        .init(id: "inch", nameKey: "英寸", symbol: "in", toBaseFactor: Decimal(string: "0.0254")!),
        .init(id: "ft", nameKey: "英尺", symbol: "ft", toBaseFactor: Decimal(string: "0.3048")!),
        .init(id: "mile", nameKey: "英里", symbol: "mi", toBaseFactor: Decimal(string: "1609.344")!),
        .init(id: "nmi", nameKey: "海里", symbol: "nmi", toBaseFactor: 1852),
    ]

    // MARK: - Data Storage (base: Byte)
    static let dataStorageUnits: [UnitDefinition] = [
        .init(id: "bit", nameKey: "Bit", symbol: "bit", toBaseFactor: Decimal(string: "0.125")!),
        .init(id: "byte", nameKey: "Byte", symbol: "B", toBaseFactor: 1),
        .init(id: "kb", nameKey: "KB", symbol: "KB", toBaseFactor: 1024),
        .init(id: "mb", nameKey: "MB", symbol: "MB", toBaseFactor: 1_048_576),
        .init(id: "gb", nameKey: "GB", symbol: "GB", toBaseFactor: 1_073_741_824),
        .init(id: "tb", nameKey: "TB", symbol: "TB", toBaseFactor: Decimal(string: "1099511627776")!),
        .init(id: "pb", nameKey: "PB", symbol: "PB", toBaseFactor: Decimal(string: "1125899906842624")!),
    ]

    // MARK: - Temperature (base: Celsius)
    static let temperatureUnits: [UnitDefinition] = [
        .init(id: "celsius", nameKey: "摄氏度", symbol: "°C", toBaseFactor: 1),
        .init(id: "fahrenheit", nameKey: "华氏度", symbol: "°F", toBaseFactor: Decimal(5) / Decimal(9), fromBaseOffset: 32, toBaseOffset: 32),
        .init(id: "kelvin", nameKey: "开尔文", symbol: "K", toBaseFactor: 1, fromBaseOffset: Decimal(string: "273.15")!, toBaseOffset: Decimal(string: "273.15")!),
    ]
}
