//
//  StatsHistoryWindow.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// How many days of `DailyTotal`s STATS is given — **the one definition**, read by the app's
/// `StatsKitDailyTotalsLoader` when it fetches, and by `InjuryLoadReport` to know whether the
/// weeks before an injury were fetched at all.
///
/// It used to live only in the loader. The injury page needs it too: an injury that started
/// more than `days - 28` days ago has a "before" window reaching past the fetched data, and a
/// ratio worked out over data that was never fetched reads too high. Two copies of the number
/// would drift the first time the window changed.
public enum StatsHistoryWindow {
    /// The widest range any screen computes from: 60 days shown plus 28 of chronic history,
    /// rounded up for headroom. See `StatsKitDailyTotalsLoader`.
    public static let days = 120
}
