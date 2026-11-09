//
//  WorkoutTemplateModel+TestHelpers.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation
@testable import MyDayKit

extension WorkoutTemplateModel {

    static func fixture(id: String = "template", title: String = "Morning routine") -> WorkoutTemplateModel {
        WorkoutTemplateModel(
            id: id,
            title: title,
            description: nil,
            exercises: [],
            createdBy: "user",
            isPublic: false,
            tags: nil,
            estimatedDuration: nil,
            difficulty: nil,
            createdAt: Date(timeIntervalSince1970: 1_800_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_800_000_000)
        )
    }
}
