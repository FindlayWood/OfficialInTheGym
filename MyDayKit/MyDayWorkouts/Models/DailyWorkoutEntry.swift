//
//  DailyWorkoutEntry.swift
//  MyDayKit
//
//  Created by Findlay Wood on 15/06/2026.
//

import Foundation

public struct DailyWorkoutEntry: Identifiable, Codable, Hashable {
    public static func == (lhs: DailyWorkoutEntry, rhs: DailyWorkoutEntry) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
    public let id: String
    public let template: WorkoutTemplateModel
    public let assignedDate: Date
    public var status: DailyWorkoutStatus
    public var sessionId: String?
    public var startedAt: Date?
    public var sessionRecord: WorkoutSessionRecord?

    /// Where this workout came from: the coach who assigned it, and the
    /// assignment the athlete accepted. `nil` on both means the athlete added
    /// it themselves, which is every entry written before assignment existed.
    ///
    /// **Provenance, not a type.** An assigned workout is performed by exactly
    /// the same flow as a self-started one — same entry, same session manager,
    /// same raw logs, same completed-session document. These two fields exist so
    /// the *presentation* can group assigned work separately and the coach can
    /// find it afterwards. Nothing in the session flow should branch on them; if
    /// something needs to, the modelling has gone wrong.
    public let assignedBy: String?
    public let assignmentId: String?

    public init(
        id: String = UUID().uuidString,
        template: WorkoutTemplateModel,
        assignedDate: Date,
        status: DailyWorkoutStatus = .planned,
        sessionId: String? = nil,
        startedAt: Date? = nil,
        sessionRecord: WorkoutSessionRecord? = nil,
        assignedBy: String? = nil,
        assignmentId: String? = nil
    ) {
        self.id = id
        self.template = template
        self.assignedDate = assignedDate
        self.status = status
        self.sessionId = sessionId
        self.startedAt = startedAt
        self.sessionRecord = sessionRecord
        self.assignedBy = assignedBy
        self.assignmentId = assignmentId
    }
}

public enum DailyWorkoutStatus: String, Codable {
    case planned
    case inProgress
    case completed
    case incomplete
}
