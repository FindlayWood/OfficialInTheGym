//
//  WorkoutSetRecord.swift
//  MyDayKit
//
//  Created by Findlay Wood on 28/06/2026.
//

import Foundation

public struct WorkoutSetRecord: Identifiable, Codable {
    public let id: String           // matches WorkoutSetModel.id
    public var isCompleted: Bool
    public var reps: Int?
    public var weight: Double?
    public var weightUnit: WeightUnit?
    public var time: Int?
    public var distance: Double?
    public var distanceUnit: DistanceUnit?
    public var completedAt: Date?

    public init(
        id: String,
        isCompleted: Bool = false,
        reps: Int? = nil,
        weight: Double? = nil,
        weightUnit: WeightUnit? = nil,
        time: Int? = nil,
        distance: Double? = nil,
        distanceUnit: DistanceUnit? = nil,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.isCompleted = isCompleted
        self.reps = reps
        self.weight = weight
        self.weightUnit = weightUnit
        self.time = time
        self.distance = distance
        self.distanceUnit = distanceUnit
        self.completedAt = completedAt
    }
}
