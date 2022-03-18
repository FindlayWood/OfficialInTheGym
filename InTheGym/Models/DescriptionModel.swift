//
//  DescriptionModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

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
    
    func uploadPoints() -> [FirebaseMultiUploadDataPoint] {
        guard let data = self.toFirebaseJSON() else {return []}
        var points = [FirebaseMultiUploadDataPoint]()
        points.append(data)
        points.append(FirebaseMultiUploadDataPoint(value: true, path: myDescriptionsPath))
        return points
    }
    
    func votePoints() -> [FirebaseMultiUploadDataPoint] {
        var points = [FirebaseMultiUploadDataPoint]()
        points.append(FirebaseMultiUploadDataPoint(value: ServerValue.increment(1), path: votePath))
        points.append(FirebaseMultiUploadDataPoint(value: true, path: myVotesDescriptionPath))
        return points
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
    var myDescriptionsPath: String {
        return "MyDescriptions/\(UserDefaults.currentUser.uid)/\(exercise)/\(id)"
    }
    var votePath: String {
        return "ExerciseDescriptions/\(exercise)/\(id)/vote"
    }
    var myVotesDescriptionPath: String {
        return "MyDescriptionVotes/\(UserDefaults.currentUser.uid)/\(id)"
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


// MARK: - Vote Search Model
/// Search if current user has voted for given description
struct VoteSearchModel {
    var descriptionID: String
    var userID: String
}
extension VoteSearchModel: FirebaseInstance {
    var internalPath: String {
        return "MyDescriptionVotes/\(userID)/\(descriptionID)"
    }
}
