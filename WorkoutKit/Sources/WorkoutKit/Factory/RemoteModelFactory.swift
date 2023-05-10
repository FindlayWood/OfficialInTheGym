//
//  File.swift
//  
//
//  Created by Findlay-Personal on 08/05/2023.
//

import Foundation

protocol RemoteModelFactory {
    func makeRemoteWorkoutModel(title: String, isPrivate: Bool, exerciseCount: Int, exercises: [RemoteExerciseModel]) -> RemoteWorkoutModel
}

extension Factory: RemoteModelFactory {
    func makeRemoteWorkoutModel(title: String, isPrivate: Bool, exerciseCount: Int, exercises: [RemoteExerciseModel]) -> RemoteWorkoutModel {
        return RemoteWorkoutModel(title: title, creatorID: userService.currentUserUID, assignedBy: userService.currentUserUID, assignedTo: userService.currentUserUID, isPrivate: isPrivate, exerciseCount: exerciseCount, exercises: exercises)
    }
}

// MARK: - Preview
class PreviewRemoteModelFactory: RemoteModelFactory {
    func makeRemoteWorkoutModel(title: String, isPrivate: Bool, exerciseCount: Int, exercises: [RemoteExerciseModel]) -> RemoteWorkoutModel {
        return RemoteWorkoutModel(title: title, creatorID: "", assignedBy: "", assignedTo: "", isPrivate: isPrivate, exerciseCount: exerciseCount)
    }
}
