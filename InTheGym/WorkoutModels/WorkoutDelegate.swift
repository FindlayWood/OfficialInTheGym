//
//  WorkoutDelegate.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol WorkoutDelegate {
    var title: String! {get}
    var creatorID: String! {get}
    var createdBy: String! {get}
    var savedID: String! {get}
    var workoutID: String? {get set}
    var exercises: [WorkoutType]? {get set}
    var liveWorkout: Bool! {get set}
    var fromDiscover: Bool! {get set}
    var clipData: [clipDataModel]? {get set}
    func toObject() -> [String:AnyObject]
}
extension WorkoutDelegate {
    func convertToUploadWorkout() -> [String: AnyObject] {
        var object = toObject()
        object.removeValue(forKey: "Views")
        object.removeValue(forKey: "NumberOfCompletes")
        object.removeValue(forKey: "NumberOfDownloads")
        object.removeValue(forKey: "TotalScore")
        object.removeValue(forKey: "TotalTime")
        return object
    }
}

protocol Completeable: WorkoutDelegate {
    var completed: Bool! {get set}
    var startTime: TimeInterval? {get set}
    var score: Int? {get set}
    var workload: Int? {get set}
    var timeToComplete: String? {get set}
    var assigned: Bool! {get}
}
