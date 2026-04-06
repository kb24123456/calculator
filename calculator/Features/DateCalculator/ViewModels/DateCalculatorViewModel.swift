//
//  DateCalculatorViewModel.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

@Observable
final class DateCalculatorViewModel {
    var mode: DateCalcMode = .difference

    // Difference
    var startDate: Date = .now
    var endDate: Date = .now
    var differenceResult: DateDifferenceResult?

    // Offset
    var offsetStartDate: Date = .now
    var offsetDays: String = ""
    var offsetForward: Bool = true
    var offsetResult: Date?

    // Workday
    var workdayStartDate: Date = .now
    var workdayCount: String = ""
    var workdayForward: Bool = true
    var includeHolidays: Bool = true
    var workdayResult: Date?
    var workdayCalendarDays: Int = 0
    var workdaySkippedDays: Int = 0

    func calculateDifference() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        let totalDays = components.day ?? 0
        let absDays = abs(totalDays)
        differenceResult = DateDifferenceResult(
            days: totalDays,
            weeks: absDays / 7,
            remainingDays: absDays % 7
        )
    }

    func calculateOffset() {
        guard let days = Int(offsetDays), days > 0 else {
            offsetResult = nil
            return
        }
        let direction = offsetForward ? days : -days
        offsetResult = Calendar.current.date(byAdding: .day, value: direction, to: offsetStartDate)
    }

    func calculateWorkday() {
        guard let count = Int(workdayCount), count > 0 else {
            workdayResult = nil
            return
        }
        let result = WorkdayCalculator.addWorkdays(
            from: workdayStartDate,
            count: count,
            forward: workdayForward,
            includeHolidays: includeHolidays
        )
        workdayResult = result.resultDate
        workdayCalendarDays = result.calendarDays
        workdaySkippedDays = result.skippedDays
    }
}
