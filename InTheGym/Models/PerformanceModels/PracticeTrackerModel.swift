//
//  PracticeTrackerModel.swift
//  InTheGym
//
//  Created by Findlay-Personal on 03/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct PracticeTrackerModel {
    var id: String
    var userID: String
    var date: TimeInterval
    var overallRating: Int
    var technicalRating: Int
    var tacticalRating: Int
    var physicalRating: Int
    var mentalRating: Int
    var notes: String
    var workloadRatio: RatioModel?
    var mostRecentWorkload: WorkloadModel?
    var wellnessStatus: WellnessAnswersModel?
    var cmjModel: CMJModel?
}
extension PracticeTrackerModel: FirebaseTimeOrderedModel {
    var internalPath: String {
        "PracticeTracking/\(userID)"
    }
}


struct PracticeTrackerSearchModel {
    
    /// user id of user to search for
    var id: String
}
extension PracticeTrackerSearchModel: FirebaseInstance {
    var internalPath: String {
        "PracticeTracking/\(id)"
    }
}
