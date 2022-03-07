//
//  ScoreSearchModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Score Search Model
/// Model to search for scores of given user
struct ScoreSearchModel {
    
    /// The userID of user to search scores
    var id: String
}
extension ScoreSearchModel: FirebaseInstance {
    var internalPath: String {
        return "Scores/\(id)"
    }
}
