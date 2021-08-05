//
//  FirebaseVideoUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

enum ClipUploadError: Error {
    case storageUploadFail
    case urlDownloadFail
    case clipUploadFail
    case userClipUploadFail
    case workoutUploadFail
    case exerciseUploadFail
    case unknown
}

struct clipUploadingData {
    var workoutID: String
    var exerciseName: String
    var exercisePosition: Int
    var videoURL: URL
    var isPrivate: Bool
}

struct clipSuccessData {
    var clipKey: String
    var storageURL: String
    var exerciseName: String
}

class FirebaseVideoUploader {
    
    static var shared = FirebaseVideoUploader()
    private init() {}
    let storage = Storage.storage().reference().child("Clips")
    let baseRef = Database.database().reference().child("Clips")
    let userRef = Database.database().reference().child("UserClips")
    let workoutRef = Database.database().reference().child("Workouts")
    let exerciseRef = Database.database().reference().child("ExerciseClips")
    
    private let storageURLString = "storageURL"
    private let clipKeyString = "clipKey"
    private let exerciseString = "exerciseName"
    
    typealias escapingClip = Result<clipSuccessData, ClipUploadError>
    
    
    func upload(uploadData: clipUploadingData,
                completion: @escaping (escapingClip) -> Void,
                progressCompletion: @escaping (Double) -> Void) {
        
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let clipID = uploadData.workoutID + uploadData.exercisePosition.description + UUID().uuidString
        let storageRef = storage.child(userID).child(clipID)
        
        let uploadTask = storageRef.putFile(from: uploadData.videoURL, metadata: nil)
        
//        let uploadTask = storageRef.putFile(from: uploadData.videoURL, metadata: nil) { data, error in
//            if let error = error {
//                print(error.localizedDescription)
//                completion(.failure(.storageUploadFail))
//            } else {
//                storageRef.downloadURL { downloadedURL, urlError in
//                    if let error = urlError {
//                        print(error.localizedDescription)
//                        completion(.failure(.urlDownloadFail))
//                    } else {
//                        self.uploadClip(storageURL: downloadedURL!.absoluteString, uploadData: uploadData, completion: completion)
//                    }
//                }
//            }
//        }
        
        uploadTask.observe(.success) { snapshot in
            storageRef.downloadURL { [weak self] downloadedURL, error in
                guard let self = self else {return}
                if error != nil {
                    completion(.failure(.urlDownloadFail))
                } else {
                    self.uploadClip(storageURL: downloadedURL!.absoluteString, uploadData: uploadData, completion: completion)
                }
            }
        }
        
        uploadTask.observe(.progress) { snapahot in
            let percentComplete = 100.0 * Double(snapahot.progress!.completedUnitCount) / Double(snapahot.progress!.totalUnitCount)
            progressCompletion(percentComplete)
            print(percentComplete)
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                completion(.failure(.storageUploadFail))
                switch (StorageErrorCode(rawValue: error.code)) {
                case .objectNotFound:
                    break
                case .unauthorized:
                    break
                case .unauthenticated:
                    break
                case .cancelled:
                    break
                case .unknown:
                    break
                default:
                    break
                }
            }
        }
        
    }
    
    private func uploadClip(storageURL: String, uploadData: clipUploadingData, completion: @escaping (escapingClip) -> Void) {
        let clipRef = baseRef.childByAutoId()
        guard let clipKey = clipRef.key,
              let userID = Auth.auth().currentUser?.uid
        else {
            return
        }
        
        let clipData = [storageURLString: storageURL,
                        "userID": userID,
                        "exerciseName": uploadData.exerciseName,
                        "time": ServerValue.timestamp(),
                        "workoutID": uploadData.workoutID,
                        "isPrivate": uploadData.isPrivate] as [String : Any]
        
        clipRef.setValue(clipData) { [weak self] error, databaseReference in
            guard let self = self else {return}
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.clipUploadFail))
            } else {
                self.uploadToWorkout(clipKey: clipKey, storageURL: storageURL, uploadData: uploadData, completion: completion)
            }
        }
    }
    
    private func uploadToWorkout(clipKey: String, storageURL: String, uploadData: clipUploadingData, completion: @escaping (escapingClip) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let clipData = [storageURLString: storageURL,
                        clipKeyString: clipKey,
                        exerciseString: uploadData.exerciseName]
        workoutRef.child(userID).child(uploadData.workoutID).child("clipData").childByAutoId().setValue(clipData) { [weak self] error, databaseReference in
            guard let self = self else {return}
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.workoutUploadFail))
            } else {
                self.uploadToUserClips(clipKey: clipKey, uploadData: uploadData, storageURL: storageURL, completion: completion)
            }
        }
    }
    
    private func uploadToUserClips(clipKey: String, uploadData: clipUploadingData, storageURL: String, completion: @escaping (escapingClip) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let clipData = [storageURLString: storageURL,
                        clipKeyString: clipKey]
        userRef.child(userID).childByAutoId().setValue(clipData) { error, databaseReference in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.userClipUploadFail))
            } else {
                self.uploadToExerciseClips(clipKey: clipKey, storageURL: storageURL, uploadData: uploadData, completion: completion)
            }
        }
    }
    
    private func uploadToExerciseClips(clipKey: String, storageURL: String, uploadData: clipUploadingData, completion: @escaping (escapingClip) -> Void) {
        let clipData = [storageURLString: storageURL,
                        clipKeyString: clipKey]
        exerciseRef.child(uploadData.exerciseName).childByAutoId().setValue(clipData) { error, databaseReference in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.exerciseUploadFail))
            } else {
                let addingData = clipSuccessData(clipKey: clipKey,
                                                 storageURL: storageURL,
                                                 exerciseName: uploadData.exerciseName)
                completion(.success(addingData))
            }
        }
    }
}
