//
//  ClipModels.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
    
class clipDataModel: Codable {
    var storageURL: String!
    var clipKey: String!
    var exerciseName: String!
    
    private let storageString = "storageURL"
    private let keyString = "clipKey"
    private let exerciseString = "exerciseName"

    init?(data: [String: AnyObject]) {
        self.storageURL = data[storageString] as? String
        self.clipKey = data[keyString] as? String
        self.exerciseName = data[exerciseString] as? String
    }

    func toObject() -> [String: AnyObject] {
        let object = [storageString: storageURL,
                      keyString: clipKey,
                      exerciseString: exerciseName] as [String: AnyObject]
        return object
    }
}

struct mainClipModel: Codable {
    var storageURL: String
    var exerciseName: String
    var time: TimeInterval
    var workoutID: String
    var userID: String
}


