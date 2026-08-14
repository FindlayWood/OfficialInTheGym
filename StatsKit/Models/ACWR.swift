//
//  ACWR.swift
//  StatsKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

// MARK: - ACWR
/// Acute:Chronic Workload Ratio — recent training load against the baseline the
/// body has adapted to.
///
/// **This is the only ACWR calculation in the module.** There were four: the
/// home card, the workload detail screen, `MetricACWR`, and the per-exercise
/// weekly chart, each with its own windowing. Two of them disagreed on what the
/// chronic window even was, so the same training could read "optimal" on one
/// screen and "high risk" on the next. What varies legitimately is the *load
/// series* going in — see `TrainingLoadMetric` — not the arithmetic.
public struct ACWR {
    public let acute: Double
    public let chronic: Double
    public let ratio: Double?

    public init(acute: Double, chronic: Double, ratio: Double?) {
        self.acute = acute
        self.chronic = chronic
        self.ratio = ratio
    }

    public enum Zone {
        case optimal, caution, danger, low, insufficient

        /// The zone a known ratio falls in.
        ///
        /// **The only place the zone boundaries are written down.** The charts
        /// colour each plotted point by its own ratio, and before this they each
        /// carried a private `acwrColor(_:)` repeating these four numbers — so
        /// the boundaries existed in three places and the colours in four.
        public init(ratio: Double) {
            switch ratio {
            case ..<0.8:    self = .low
            case 0.8..<1.3: self = .optimal
            case 1.3..<1.5: self = .caution
            default:        self = .danger
            }
        }

        /// **The matte palette, not the system colours.** See the note on
        /// `Color.matteGreen`: `.red` / `.orange` / `.green` at full saturation
        /// read as system alerts next to `darkColor` and made the louder zones
        /// look more urgent than the marker's position warranted.
        ///
        /// This stays the mapping — which zone is which colour — while
        /// `Color+Extension` holds the values, the same split brand colours use.
        public var color: Color {
            switch self {
            case .optimal:      return .matteGreen
            case .caution:      return .matteAmber
            case .danger:       return .matteRed
            case .low:          return .matteBlue
            case .insufficient: return .secondary
            }
        }

        public var label: String {
            switch self {
            case .optimal:      return "Optimal"
            case .caution:      return "Caution"
            case .danger:       return "High risk"
            case .low:          return "Low load"
            case .insufficient: return "Not enough data"
            }
        }

        public var explanation: String {
            switch self {
            case .optimal:
                return "Your training load is well balanced against your baseline."
            case .caution:
                return "Recent load is elevated. Consider managing intensity."
            case .danger:
                return "Recent load significantly exceeds baseline. Risk of overtraining is elevated."
            case .low:
                return "Recent load is below baseline. Consider gradually increasing training."
            case .insufficient:
                return "Not enough training history. Keep logging to build your baseline."
            }
        }
    }

    public var zone: Zone {
        guard let ratio else { return .insufficient }
        return Zone(ratio: ratio)
    }

    public var formattedRatio: String {
        guard let ratio else { return "—" }
        return String(format: "%.2f", ratio)
    }
}

// MARK: - Rolling calculation
public extension ACWR {

    /// Mean daily load over the acute window, divided by mean daily load over
    /// the chronic window, both ending on `day`.
    ///
    /// **Rest days count as zero, in both windows.** Averaging over the length
    /// of the window rather than over the days that had training is the whole
    /// point: it is what makes a deload week actually read as a drop, instead of
    /// a week of one hard session reading the same as a week of five.
    ///
    /// A day missing from `loadByDay` is a zero-load day. `ratio` is `nil` — and
    /// the zone `.insufficient` — when the chronic window holds no load at all,
    /// which is the honest answer rather than dividing by zero and calling the
    /// result a risk assessment.
    ///
    /// - Note: `loadByDay` must reach back `chronicDays` before `day`, or the
    ///   chronic mean is computed over data that was never fetched and comes out
    ///   too low — inflating the ratio. See `StatsKitDailyTotalsLoader`.
    static func rolling(
        loadByDay: [String: Double],
        endingOn day: Date = .now,
        acuteDays: Int = 7,
        chronicDays: Int = 28
    ) -> ACWR {
        func meanDailyLoad(over days: Int) -> Double {
            let total = (0..<days).reduce(0.0) { sum, offset in
                sum + (loadByDay[StatsDay.key(daysAgo: offset, from: day)] ?? 0)
            }
            return total / Double(days)
        }

        let acute = meanDailyLoad(over: acuteDays)
        let chronic = meanDailyLoad(over: chronicDays)

        guard chronic > 0 else {
            return ACWR(acute: acute, chronic: chronic, ratio: nil)
        }
        return ACWR(acute: acute, chronic: chronic, ratio: acute / chronic)
    }
}
