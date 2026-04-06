//
//  Date+Extensions.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

extension Date {
    /// Relative time description (e.g., "5分钟前", "2小时前", "昨天")
    var relativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: .now)
    }

    /// Format for display in history list sections
    var sectionHeader: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return String(localized: "今天")
        } else if calendar.isDateInYesterday(self) {
            return String(localized: "昨天")
        } else if calendar.isDate(self, equalTo: .now, toGranularity: .weekOfYear) {
            return String(localized: "本周")
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: self)
        }
    }
}
