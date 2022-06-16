//
//  WorkloadModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Workload Model
struct WorkloadModel: Hashable {
    var id: String
    var endTime: TimeInterval
    var rpe: Int
    var timeToComplete: Int
    var workload: Int
    var customAddedWorkload: Int?
    var workoutID: String?
}
extension WorkloadModel: FirebaseTimeOrderedModel {
    var internalPath: String {
        return "Workloads/\(UserDefaults.currentUser.uid)"
    }
}

extension WorkloadModel {
    static let testExample = WorkloadModel(id: "1", endTime: 1, rpe: 1, timeToComplete: 1, workload: 1, workoutID: "1")
}
