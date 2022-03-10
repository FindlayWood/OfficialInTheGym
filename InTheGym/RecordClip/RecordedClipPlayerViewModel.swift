//
//  RecordedClipPlayerViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine
import UIKit

class RecordedClipPlayerViewModel {
    
    // MARK: - Publishers
    var successPublisher = PassthroughSubject<Bool,Never>()
    var errorPublisher = PassthroughSubject<ClipUploadError,Never>()
    var thumbnailGenerated = PassthroughSubject<UIImage,Never>()
    
    // MARK: - Properties
    var clipStorageModel: ClipStorageModel!
    
    var apiService: FirebaseDatabaseManagerService
    
    var storageAPI: FirebaseStorageManager
    
    var paused: Bool = false
    
    var isPrivate: Bool = false
    
    var workoutModel: WorkoutModel?
    
    var exerciseModel: ExerciseModel!
    
    weak var addDelegate: ClipAdding?
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared, storageAPI: FirebaseStorageManager = FirebaseStorageManager.shared) {
        self.apiService = apiService
        self.storageAPI = storageAPI
    }
    
    func removeFromFileManager() {
        let currentVideoURL = clipStorageModel.fileURL
        try? FileManager.default.removeItem(at: currentVideoURL)
    }
    
    
    func uploadClipToStorage() {
        storageAPI.fileUpload(model: clipStorageModel) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let fileURL):
                self.uploadToDatabase(with: fileURL)
            case .failure(_):
                // TODO: - Show Upload Error
                self.errorPublisher.send(.failedClipToStorage)
                break
            }
        }
    }
    
    func generateThumbnail(with id: String) {
        clipStorageModel.fileURL.generateThumbnail { [weak self] thumbnail in
            guard let self = self else {return}
            if let thumbnail = thumbnail {
                let thumbnailModel = ClipThumbnailModel(id: id, image: thumbnail)
                self.uploadThumbnail(thumbnailModel)
            } else {
                self.errorPublisher.send(.failedGenerateThumnail)
            }
        }
    }
    
    func uploadThumbnail(_ model: ClipThumbnailModel) {
        storageAPI.dataUpload(model: model) { [weak self] result in
            switch result {
            case .success(()):
                break
            case .failure(_):
                self?.errorPublisher.send(.failedUploadThumbnail)
            }
        }
    }
    
    // MARK: - Database Model Upload
    /// Upload the model to database with time ordered id
    /// Return model with id and then upload details
    func uploadToDatabase(with storageURL: String) {
        let clipModel = ClipModel(storageURL: storageURL, exerciseName: exerciseModel.exercise, workoutID: workoutModel?.id, isPrivate: isPrivate)
        apiService.uploadTimeOrderedModel(model: clipModel) { [weak self] result in
            switch result {
            case .success(let model):
                self?.uploadDatabaseDetails(from: model)
            case .failure(_):
                self?.errorPublisher.send(.failedDatabaseUpload)
            }
        }
        
//
//        let clipUploadModel = UploadClipModel(workout: workoutModel, exercise: exerciseModel, storageURL: storageURL, isPrivate: isPrivate)
//        let uploadPoints = clipUploadModel.getUploadPoints()
//        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
//            switch result {
//            case .success(()):
//                self?.generateThumbnail(with: clipUploadModel.id)
//                self?.removeFromFileManager()
//                self?.successPublisher.send(true)
//                self?.addDelegate.addClip(clipUploadModel.getClipModel())
//            case .failure(_):
//                // TODO: - Show Error
//                self?.successPublisher.send(false)
//                self?.errorPublisher.send(.failedDatabaseUpload)
//            }
//        }
    }
    
    func uploadDatabaseDetails(from model: ClipModel) {
        let clipUploadModel = UploadClipModel(workout: workoutModel, exercise: exerciseModel, id: model.id, storageURL: model.storageURL, isPrivate: model.isPrivate)
        let uploadPoints = clipUploadModel.getUploadPoints()
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            switch result {
            case .success(()):
                self?.generateThumbnail(with: model.id)
                self?.removeFromFileManager()
                self?.successPublisher.send(true)
                self?.addDelegate?.addClip(model)
            case .failure(_):
                self?.errorPublisher.send(.failedDatabaseUpload)
                self?.successPublisher.send(false)
            }
        }
    }
}
