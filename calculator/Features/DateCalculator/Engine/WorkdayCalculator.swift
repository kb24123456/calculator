//
//  WorkdayCalculator.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

struct WorkdayCalculator {
    /// Calculate the date after N workdays from start date.
    /// If includeHolidays is true, skips Chinese holidays and includes compensatory workdays.
    static func addWorkdays(
        from startDate: Date,
        count: Int,
        forward: Bool = true,
        includeHolidays: Bool = false
    ) -> (resultDate: Date, calendarDays: Int, skippedDays: Int) {
        let calendar = Calendar.current
        let direction = forward ? 1 : -1
        var currentDate = startDate
        var workdaysAdded = 0
        var calendarDays = 0
        var skippedDays = 0

        while workdaysAdded < count {
            currentDate = calendar.date(byAdding: .day, value: direction, to: currentDate)!
            calendarDays += 1

            let isWeekend = calendar.isDateInWeekend(currentDate)

            if includeHolidays {
                let dateStr = formatDateForLookup(currentDate)
                let year = calendar.component(.year, from: currentDate)
                let yearData = ChineseHolidayData.holidays(for: year)

                if yearData.holidays.contains(dateStr) {
                    // Official holiday — skip
                    skippedDays += 1
                    continue
                } else if yearData.compensatoryWorkdays.contains(dateStr) {
                    // Compensatory workday (weekend that IS a workday) — count
                    workdaysAdded += 1
                    continue
                }
            }

            if isWeekend {
                skippedDays += 1
                continue
            }

            workdaysAdded += 1
        }

        return (currentDate, calendarDays, skippedDays)
    }

    /// Days between two dates, counting only workdays.
    static func workdaysBetween(from startDate: Date, to endDate: Date, includeHolidays: Bool = false) -> Int {
        let calendar = Calendar.current
        var count = 0
        var current = startDate

        let isForward = endDate >= startDate
        let direction = isForward ? 1 : -1

        while (isForward ? current < endDate : current > endDate) {
            current = calendar.date(byAdding: .day, value: direction, to: current)!

            let isWeekend = calendar.isDateInWeekend(current)

            if includeHolidays {
                let dateStr = formatDateForLookup(current)
                let year = calendar.component(.year, from: current)
                let yearData = ChineseHolidayData.holidays(for: year)

                if yearData.holidays.contains(dateStr) {
                    continue
                } else if yearData.compensatoryWorkdays.contains(dateStr) {
                    count += 1
                    continue
                }
            }

            if !isWeekend {
                count += 1
            }
        }

        return count
    }

    private static func formatDateForLookup(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
