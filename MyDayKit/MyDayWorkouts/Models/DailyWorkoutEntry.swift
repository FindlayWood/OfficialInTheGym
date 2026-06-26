//
//  DailyWorkoutEntry.swift
//  MyDayKit
//
//  Created by Findlay Wood on 15/06/2026.
//

import Foundation

public struct DailyWorkoutEntry: Identifiable, Codable {
    public let id: String
    public let template: WorkoutTemplateModel
    public let assignedDate: Date
    public var status: DailyWorkoutStatus
    public var sessionId: String?

    public init(
        id: String = UUID().uuidString,
        template: WorkoutTemplateModel,
        assignedDate: Date,
        status: DailyWorkoutStatus = .planned,
        sessionId: String? = nil
    ) {
        self.id = id
        self.template = template
        self.assignedDate = assignedDate
        self.status = status
        self.sessionId = sessionId
    }
}

public enum DailyWorkoutStatus: String, Codable {
    case planned
    case inProgress
    case completed
    case incomplete
}
