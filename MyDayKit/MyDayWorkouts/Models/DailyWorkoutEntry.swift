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

    public init(
        id: String = UUID().uuidString,
        template: WorkoutTemplateModel,
        assignedDate: Date,
        status: DailyWorkoutStatus = .planned,
        sessionId: String? = nil,
        startedAt: Date? = nil,
        sessionRecord: WorkoutSessionRecord? = nil
    ) {
        self.id = id
        self.template = template
        self.assignedDate = assignedDate
        self.status = status
        self.sessionId = sessionId
        self.startedAt = startedAt
        self.sessionRecord = sessionRecord
    }
}

public enum DailyWorkoutStatus: String, Codable {
    case planned
    case inProgress
    case completed
    case incomplete
}
