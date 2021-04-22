//
//  WorkoutDelegate.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol WorkoutDelegate {
    var title:String! {get}
    var creatorID:String! {get}
    var savedID:String! {get}
    var workoutID:String? {get}
    var exercises:[exercise]? {get set}
    var completed:Bool! {get}
    var liveWorkout:Bool! {get set}
    var fromDiscover:Bool! {get set}
    func toObject() -> [String:AnyObject]
    
}

protocol Completeable {
    var completed:Bool!{get set}
}
