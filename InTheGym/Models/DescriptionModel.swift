//
//  DescriptionModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Description Model
///Model for exercise description
class DescriptionModel: Codable, Hashable {
    
    var id: String
    var exercise: String
    var username: String
    var posterID: String
    var time: TimeInterval
    var description: String
    var vote: Int
    
    init(exercise: String, description: String) {
        self.id = UUID().uuidString
        self.exercise = exercise
        self.username = UserDefaults.currentUser.username
        self.posterID = UserDefaults.currentUser.uid
        self.time = Date().timeIntervalSince1970
        self.description = description
        self.vote = 0
    }
    
    static func == (lhs: DescriptionModel, rhs: DescriptionModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
extension DescriptionModel: FirebaseInstance {
    var internalPath: String {
        return "ExerciseDescriptions/\(exercise)/\(id)"
    }
}

// MARK: - Descriptions
/// Model to search for all descriptions for a given exercise
struct Descriptions {
    var exercise: String
}
extension Descriptions: FirebaseInstance {
    var internalPath: String {
        return "ExerciseDescriptions/\(exercise)"
    }
}


