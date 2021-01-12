//
//  Posts.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/12/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

struct Posts {
    var time : TimeInterval?
    var username : String?
    var posterID : String?
    var postID : String?
    var postType : postType?
    var workoutExerciseCount : String?
    var workoutScore : String?
    var workoutTime : String?
    var workoutTitle : String?
    var message : String?
    var isPrivate : Bool?
    
    
}

enum postType{
    case post
    case workout
    
}
