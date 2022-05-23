//
//  PostCellViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

// PostCellViewModel
// This class is the viewModel for any post cell
// It handles likes
class PostCellViewModel {
    
    // MARK: - Publishers
    @Published var isLiked: Bool = false
    @Published var imageData: Data?
    @Published var workoutModel: WorkoutModel?
    @Published var savedWorkoutModel: SavedWorkoutModel?
    
    var completedLikeButtonAction = PassthroughSubject<Void,Never>()
    
    var errorWorkout = PassthroughSubject<Error,Never>()
    
    var errorLikingPost = PassthroughSubject<Error,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    var post: DisplayablePost! // The post that this view model is responsible for
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func likedPost() {
        switch post {
        case is PostModel:
            like(post as! PostModel)
        case is GroupPost:
            groupLike(post as! GroupPost)
        default:
            break
        }
    }
    
    func like(_ post: PostModel) {
        let likeModels = LikeTransportLayer(postID: post.id).postLike(post: post)
        apiService.multiLocationUpload(data: likeModels) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                LikeCache.shared.upload(postID: post.id)
                self.addLikedPostToCache(post)
                self.completedLikeButtonAction.send(())
            case .failure(let error):
                self.errorLikingPost.send(error)
            }
        }
    }
    func groupLike(_ groupPost: GroupPost) {
        let likeModels = LikeTransportLayer(postID: groupPost.id).groupPostLike(post: groupPost)
        apiService.multiLocationUpload(data: likeModels) { [weak self] result in
            switch result {
            case .success(()):
                LikeCache.shared.upload(postID: groupPost.id)
                self?.completedLikeButtonAction.send(())
            case .failure(let error):
                self?.errorLikingPost.send(error)
            }
        }
    }

    
    // MARK: - Functions
    func checkLike() {
        DispatchQueue.global(qos: .background).async {
            let likeModel = LikeSearchModel(postID: self.post.id)
            LikeCache.shared.load(from: likeModel) { [weak self] result in
                guard let liked = try? result.get() else {return}
                self?.isLiked = liked
            }
        }
    }
    func loadProfileImage() {
        DispatchQueue.global(qos: .background).async {
            let profileImageModel = ProfileImageDownloadModel(id: self.post.posterID)
            ImageCache.shared.load(from: profileImageModel) { [weak self] result in
                let imageData = try? result.get().pngData()
                self?.imageData = imageData
            }
        }
    }
    func checkWorkout() {
        guard let workoutID = post.workoutID else {return}
        DispatchQueue.global(qos: .background).async {
            let searchModel = WorkoutKeyModel(id: workoutID, assignID: self.post.posterID)
            WorkoutLoader.shared.load(from: searchModel) { [weak self] result in
                switch result {
                case .success(let workoutModel):
                    self?.workoutModel = workoutModel
                case .failure(let error):
                    self?.errorWorkout.send(error)
                }
            }
        }
    }
    func checkSavedWorkout() {
        guard let savedID = post.savedWorkoutID else {return}
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
    func addLikedPostToCache(_ post: PostModel) {
        var newPost = post
        newPost.likeCount += 1
        PostLoader.shared.add(newPost)
    }
}
