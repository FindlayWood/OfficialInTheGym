//
//  ExerciseStatsSaveModel.swift
//  MyDayKit
//
//  Created by Findlay Wood on 12/11/2025.
//

import Foundation

public struct ExerciseStatsSaveModel: Codable {
    public let id: String
    public let exerciseID: String
    public let exerciseName: String
    public let dateComplete: Date
    public let reps: Int
    public let weight: Double
    public let time: Int
}
