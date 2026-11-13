//
//  ProfileWorkout+TestHelpers.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 12/11/2026.
//

import Foundation
@testable import ProfileKit

extension ProfileWorkout {

    static func make(id: String = "w1", createdBy: String? = "me", isPublic: Bool = true) -> ProfileWorkout {
        ProfileWorkout(
            workoutId: id,
            title: "Saturday Upper",
            createdBy: createdBy,
            exerciseCount: 5,
            createdAt: Date(timeIntervalSince1970: 1_800_000_000),
            isPublic: isPublic
        )
    }
}
