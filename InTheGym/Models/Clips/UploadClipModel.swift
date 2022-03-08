//
//  UploadClipModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation


struct UploadClipModel {
    var workout: WorkoutModel?
    var exercise: ExerciseModel
    var id: String = UUID().uuidString
    var storageURL: String
    var isPrivate: Bool
    
    func getUploadPoints() -> [FirebaseMultiUploadDataPoint] {
        var uploadPoints = [FirebaseMultiUploadDataPoint]()
        uploadPoints.append(FirebaseMultiUploadDataPoint(value: getClipModel(), path: clipPath))
        uploadPoints.append(FirebaseMultiUploadDataPoint(value: getKeyClipModel(), path: exerciseClipPath))
        uploadPoints.append(FirebaseMultiUploadDataPoint(value: getKeyClipModel(), path: userClipPath))
        if workout != nil {
            uploadPoints.append(FirebaseMultiUploadDataPoint(value: getWorkoutClipModel(), path: workoutPath))
        }
        return uploadPoints
    }
    
    func getClipModel() -> ClipModel {
        var model =  ClipModel(id: id,
                         storageURL: storageURL,
                         exerciseName: exercise.exercise,
                         time: Date().timeIntervalSince1970,
                         userID: UserDefaults.currentUser.uid,
                         isPrivate: isPrivate)
        if let workout = workout {
            model.workoutID = workout.id
        }
        return model
    }
    
    func getWorkoutClipModel() -> WorkoutClipModel {
        return WorkoutClipModel(storageURL: storageURL,
                                clipKey: id,
                                exerciseName: exercise.exercise)
    }
    
    func getKeyClipModel() -> KeyClipModel {
        return KeyClipModel(clipKey: id, storageURL: storageURL)
    }
}
// MARK: - Paths
private extension UploadClipModel {
    var workoutPath: String {
        guard let workout = workout else {return ""}
        return "Workouts/\(UserDefaults.currentUser.uid)/\(workout.id)/clipData/\(workout.clipData?.count ?? 0)"
    }
    var clipPath: String {
        return "Clips/\(id)"
    }
    var exerciseClipPath: String {
        return "ExerciseClips/\(exercise.exercise)/\(id)"
    }
    var userClipPath: String {
        return "UserClips/\(UserDefaults.currentUser.uid)/\(id)"
    }
}
