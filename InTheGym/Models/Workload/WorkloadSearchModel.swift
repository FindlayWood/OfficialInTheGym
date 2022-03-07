//
//  WorkloadSearchModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Score Search Model
/// Model to search for workload of given user
struct WorkloadSearchModel {
    
    /// The userID of user to search workload
    var id: String
}
extension WorkloadSearchModel: FirebaseInstance {
    var internalPath: String {
        return "Workloads/\(id)"
    }
}
