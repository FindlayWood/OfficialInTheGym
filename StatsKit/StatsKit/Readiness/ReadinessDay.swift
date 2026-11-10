//
//  ReadinessDay.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// One day's check-in, as the readinessFromMyDay function projects it:
/// `Users/{uid}/Readiness/{yyyy-MM-dd}`.
///
/// **Every field is optional.** A day may hold a rating with no check-in, and `readiness` is
/// only worked out when all four answers are there. **`readiness` is read, never recomputed** —
/// it is defined once in MyDayKit (`WellnessEntry.readinessScore`) and once in the function that
/// must match it; a third copy here is how the three would drift.
///
/// `id` is the MyDay day's key, the user's own day, read here as a `StatsDay` key — see
/// `StatsInjury` for why a day either side around midnight is accepted.
public struct ReadinessDay: Identifiable, Hashable, Sendable, Decodable {
    public let id: String
    public let sleep: Int?
    public let body: Int?
    public let focus: Int?
    public let mood: Int?
    public let readiness: Double?
    public let dayRPE: Int?

    public init(id: String, sleep: Int?, body: Int?, focus: Int?, mood: Int?, readiness: Double?, dayRPE: Int?) {
        self.id = id
        self.sleep = sleep
        self.body = body
        self.focus = focus
        self.mood = mood
        self.readiness = readiness
        self.dayRPE = dayRPE
    }

    private enum CodingKeys: String, CodingKey {
        case date, sleep, body, focus, mood, readiness, dayRPE
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .date)
        sleep = try container.decodeIfPresent(Int.self, forKey: .sleep)
        body = try container.decodeIfPresent(Int.self, forKey: .body)
        focus = try container.decodeIfPresent(Int.self, forKey: .focus)
        mood = try container.decodeIfPresent(Int.self, forKey: .mood)
        readiness = try container.decodeIfPresent(Double.self, forKey: .readiness)
        dayRPE = try container.decodeIfPresent(Int.self, forKey: .dayRPE)
    }
}
