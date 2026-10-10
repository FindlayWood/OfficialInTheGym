//
//  JournalEntry+TestHelpers.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation
@testable import PerformanceKit

extension JournalEntry {

    static func make(id: String = "entry", date: Date = .fixed, entry: String = "Felt strong today") -> JournalEntry {
        JournalEntry(id: id, date: date, entry: entry)
    }
}

extension Date {

    /// 2026-10-10 12:00 UTC.
    static let fixed = Date(timeIntervalSince1970: 1_791_633_600)
}
