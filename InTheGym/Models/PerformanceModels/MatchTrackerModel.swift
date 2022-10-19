//
//  MatchTrackerModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct MatchTrackerModel {
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
extension MatchTrackerModel: FirebaseTimeOrderedModel {
    var internalPath: String {
        "MatchTracking/\(userID)"
    }
}


struct MatchTrackerSearchModel {
    
    /// user id of user to search for
    var id: String
}
extension MatchTrackerSearchModel: FirebaseInstance {
    var internalPath: String {
        "MatchTracking/\(id)"
    }
}
