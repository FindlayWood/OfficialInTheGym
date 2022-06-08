//
//  DescriptionsCellViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class DescriptionsCellViewModel {
    // MARK: - Publishers
    @Published var imageData: Data?
    var votedPublishers = PassthroughSubject<Bool,Never>()
    // MARK: - Properties
    var descriptionModel: DisplayableComment!
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Actions
    func likeButtonAction() {
        switch descriptionModel {
        case is WorkoutCommentModel:
            likeWorkoutComment()
        case is ExerciseCommentModel:
            likeExerciseComment()
        default:
            break
        }
    }
    // MARK: - Functions
    func loadProfileImage() {
        DispatchQueue.global(qos: .background).async {
            let profileImageModel = ProfileImageDownloadModel(id: self.descriptionModel.posterID)
            ImageCache.shared.load(from: profileImageModel) { [weak self] result in
                let imageData = try? result.get().pngData()
                self?.imageData = imageData
            }
        }
    }
    func likeExerciseComment() {
        guard let model = descriptionModel as? ExerciseCommentModel else {return}
        let points = model.votePoints()
        apiService.multiLocationUpload(data: points) { result in
            switch result {
            case .success(()):
                VoteCache.shared.upload(descriptionID: model.id)
            case .failure(_):
                break
            }
        }
    }
    func likeWorkoutComment() {
        guard let model = descriptionModel as? WorkoutCommentModel else {return}
        let points = model.uploadPoints()
        apiService.multiLocationUpload(data: points) { result in
            switch result {
            case .success(_):
                VoteCache.shared.upload(descriptionID: model.id)
            case .failure(_):
                break
            }
        }
    }
    func checkVote() {
        let searchModel = CommentLikeSearchModel(commentID: descriptionModel.id, userID: UserDefaults.currentUser.uid)
        VoteCache.shared.load(from: searchModel) { [weak self] result in
            switch result {
            case .success(let voted):
                self?.votedPublishers.send(voted)
            case .failure(_):
                break
            }
        }
    }
}
