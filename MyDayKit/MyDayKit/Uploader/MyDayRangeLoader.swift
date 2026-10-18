//
//  MyDayRangeLoader.swift
//  MyDayKit
//
//  Created by Findlay Wood on 17/10/2026.
//

import Foundation

/// Every day document between two dates, inclusive, in one read — for the date strip's markers.
///
/// **Not `MyDayLoader` called once per date.** The strip spans 33 days and day files are only
/// kept locally for a week, so a per-date load is a remote read per day, most of them for days
/// with no document at all. A range is one query that returns only the days that exist; a day
/// missing from the result has nothing on it.
public protocol MyDayRangeLoader {
    func loadDays(from start: Date, to end: Date) async throws -> [MyDayFullDayModel]
}

/// Loads nothing, so previews and anything built without a real store draw an unmarked strip.
public struct EmptyMyDayRangeLoader: MyDayRangeLoader {
    public init() {}

    public func loadDays(from start: Date, to end: Date) async throws -> [MyDayFullDayModel] {
        []
    }
}
