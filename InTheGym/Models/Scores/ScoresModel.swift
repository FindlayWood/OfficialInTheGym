//
//  ScoresModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Score Model
/// Model to store all scores
/// Can be used to upload score to self
struct ScoresModel {
    var id: String
    var score: Int
}
extension ScoresModel: FirebaseTimeOrderedModel {
    var internalPath: String {
        return "Scores/\(UserDefaults.currentUser.uid)"
    }
}

