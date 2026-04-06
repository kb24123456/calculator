//
//  DateResult.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

enum DateCalcMode: String, CaseIterable {
    case difference
    case offset
    case workday
}

struct DateDifferenceResult {
    let days: Int
    let weeks: Int
    let remainingDays: Int
}

struct DateOffsetResult {
    let resultDate: Date
    let weekday: String
}
