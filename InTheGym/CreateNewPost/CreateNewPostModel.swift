//
//  CreateNewPostModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

struct CreateNewPostModel: Encodable {
    var id: String = ""
    var username: String = ""
    var posterID: String = ""
    var time: TimeInterval = 0
    var text: String = ""
    var likeCount: Int = 0
    var replyCount: Int = 0
    var attachedPhoto: attachedPhoto?
    var attachedClip: attachedClip?
    var attachedWorkout: attachedWorkout?
    var isPrivate: Bool = false
}

