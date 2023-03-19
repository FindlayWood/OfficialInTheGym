//
//  CommentCellViewModel.swift
//  InTheGym
//
//  Created by Findlay-Personal on 18/03/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Combine
import UIKit

class CommentCellViewModel {
    
    // MARK: - Publishers
    @Published var isLiked: Bool = false
    @Published var profileImage: UIImage?
    @Published var userModel: Users?
    @Published var savedWorkoutModel: SavedWorkoutModel?
    
    var errorLikingPost = PassthroughSubject<Error,Never>()
    var errorWorkout = PassthroughSubject<Error,Never>()
    
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    var comment: Comment! // The comment that this view model is responsible for
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    func like() {
        let likeModels = LikeTransportLayer(postID: comment.id).commentLike(comment: comment)
        apiService.multiLocationUpload(data: likeModels) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                CommentLikeCache.shared.upload(commentID: self.comment.id)
            case .failure(let error):
                print(error.localizedDescription)
                print(String(describing: error))
                self.errorLikingPost.send(error)
            }
        }
    }
    
    // MARK: - Functions
    func checkLike() {
        DispatchQueue.global(qos: .background).async {
            let likeModel = LikedCommentSearchModel(commentID: self.comment.id)
            CommentLikeCache.shared.load(from: likeModel) { [weak self] result in
                guard let liked = try? result.get() else {return}
                self?.isLiked = liked
            }
        }
    }
    func loadProfileImage() {
        DispatchQueue.global(qos: .background).async {
            let profileImageModel = ProfileImageDownloadModel(id: self.comment.posterID)
            ImageCache.shared.load(from: profileImageModel) { [weak self] result in
                self?.profileImage = try? result.get()
            }
        }
    }
    func checkSavedWorkout() {
        guard let savedID = comment.attachedWorkoutSavedID else {return}
        DispatchQueue.global(qos: .background).async {
            let searchModel = SavedWorkoutKeyModel(id: savedID)
            SavedWorkoutLoader.shared.load(from: searchModel) { [weak self] result in
                switch result {
                case .success(let savedModel):
                    self?.savedWorkoutModel = savedModel
                case .failure(let error):
                    self?.errorWorkout.send(error)
                }
            }
        }
    }
    // MARK: - User Model
    func loadUserModel() {
        DispatchQueue.global(qos: .background).async {
            let userSearchModel = UserSearchModel(uid: self.comment.posterID)
            UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
                let userModel = try? result.get()
                DispatchQueue.main.async {
                    self?.userModel = userModel
                }
            }
        }
    }
}
