//
//  ScheduleItem.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation

/// What a schedule puts on the day.
///
/// **A workout is held by id, not as a copy of the template.** Until the user starts it, the card
/// shows the workout as it is now, so an edit made on Monday is on Tuesday's card. Starting it
/// saves a snapshot on the day, and only then is it fixed.
///
/// **A sport is always a training session.** A game has a result and a score that no schedule can
/// know, so games stay in the normal Add flow. `duration` is seconds, as on `SportSessionEntry`,
/// and only fills in the card: the user can change it, and nothing is recorded until they press
/// Done.
public enum ScheduleItem: Codable, Equatable, Sendable {
    case workout(templateId: String)
    case sport(sport: SportType, duration: Int)
}
