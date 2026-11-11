//
//  ReminderPreferences.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// Every reminder the user can set, in one value. Stored on the device, per user — see
/// `ReminderPreferencesStore`.
///
/// **Everything is off until the user turns it on.** A reminder nobody asked for is the
/// notification prompt at launch again, which the app stopped doing for that reason.
///
/// **Decoding falls back field by field.** A reminder kind added later must not reset the ones
/// the user already set, so a missing key takes its default rather than failing the whole value.
public struct ReminderPreferences: Codable, Hashable, Sendable {
    public var checkIn: ReminderPreference
    public var dayRating: ReminderPreference

    public init(checkIn: ReminderPreference, dayRating: ReminderPreference) {
        self.checkIn = checkIn
        self.dayRating = dayRating
    }

    public static let `default` = ReminderPreferences(
        checkIn: ReminderPreference(isOn: false, time: .morning),
        dayRating: ReminderPreference(isOn: false, time: .evening)
    )

    public subscript(kind: ReminderKind) -> ReminderPreference {
        get {
            switch kind {
            case .checkIn: return checkIn
            case .dayRating: return dayRating
            }
        }
        set {
            switch kind {
            case .checkIn: checkIn = newValue
            case .dayRating: dayRating = newValue
            }
        }
    }

    /// Whether any reminder is on — the point at which notification permission matters.
    public var hasAnyOn: Bool {
        ReminderKind.allCases.contains { self[$0].isOn }
    }

    private enum CodingKeys: String, CodingKey {
        case checkIn, dayRating
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fallback = ReminderPreferences.default
        checkIn = (try? container.decodeIfPresent(ReminderPreference.self, forKey: .checkIn)) ?? fallback.checkIn
        dayRating = (try? container.decodeIfPresent(ReminderPreference.self, forKey: .dayRating)) ?? fallback.dayRating
    }
}
