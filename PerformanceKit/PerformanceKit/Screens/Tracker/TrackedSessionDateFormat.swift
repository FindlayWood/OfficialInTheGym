//
//  TrackedSessionDateFormat.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// "d MMM yyyy", the app target's `getMonthYearFormat()`, which every tracker
/// date was drawn with.
enum TrackedSessionDateFormat {

    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
}
