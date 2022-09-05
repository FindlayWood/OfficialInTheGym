//
//  WorkoutStatsModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import UIKit

struct WorkoutStatsModel {
    
    var numberOfDownloads: Int = 0
    var numberOfCompletes: Int = 0
    var numberOfView: Int = 0
    var averageTimeToComplete: Double = 0
    var averageRPEScore: Double = 0
    
    init?(snapshot: DataSnapshot) {
        guard let snap = snapshot.value as? [String: AnyObject] else {return}
        
        self.numberOfDownloads = snap["NumberOfDownloads"] as? Int ?? 0
        self.numberOfCompletes = snap["NumberOfCompletes"] as? Int ?? 0
        self.numberOfView = snap["Views"] as? Int ?? 0
        let totalTime = snap["TotalTime"] as? Int ?? 0
        let totalRPEScore = snap["TotalScore"] as? Int ?? 0
        if self.numberOfCompletes != 0 {
            let averageTime = totalTime / self.numberOfCompletes
            self.averageTimeToComplete = Double(averageTime)
            let averageScore = totalRPEScore / self.numberOfCompletes
            self.averageRPEScore = Double(averageScore)
        }
    }
}

struct WorkoutStatCellModel {
    var image: UIImage
    var title: String
    var stat: String
}
