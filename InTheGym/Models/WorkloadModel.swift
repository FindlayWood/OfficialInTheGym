//
//  WorkloadModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Workload Model
///Model to upload workload to Firebase
struct WorkloadModel {
    var id: String
    var endTime: TimeInterval
    var rpe: Int
    var timeToComplete: Int
    var workload: Int
    var workoutID: String
}

extension WorkloadModel: FirebaseInstance {
    var internalPath: String {
        return "Workloads/\(UserDefaults.currentUser.uid)/\(id)"
    }
}
