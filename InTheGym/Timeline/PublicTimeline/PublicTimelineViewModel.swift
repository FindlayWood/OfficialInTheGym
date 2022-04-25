//
//  PublicTimelineViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class PublicTimelineViewModel {
    
    // MARK: - Publishers
    var postPublisher = CurrentValueSubject<[post],Never>([])
    
    var savedWorkouts = CurrentValueSubject<[SavedWorkoutModel],Never>([])
    
    var clipPublisher = CurrentValueSubject<[ClipModel],Never>([])
    
    var followerCountPublisher = CurrentValueSubject<Int,Never>(0)
    
    var followingCountPublisher = CurrentValueSubject<Int,Never>(0)
    
    var isFollowingPublisher = CurrentValueSubject<Bool,Never>(false)
    
    var errorLikingPost = PassthroughSubject<Error,Never>()
    
    var errorFetchingWorkouts = PassthroughSubject<Error,Never>()
    
    var workoutSelected = PassthroughSubject<WorkoutModel,Never>()
    
    var savedWorkoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    
    var userSelected = PassthroughSubject<Users,Never>()
    
    var reloadListener = PassthroughSubject<post,Never>()
    
    var followSuccess = PassthroughSubject<Bool,Never>()

    
    // MARK: - Properties
    
    var apiService: FirebaseDatabaseManagerService
    

    
    // the user to view, passed from coordinator
    var user: Users!

    
    // MARK: - Initializer
    
    // Note: apiService has a default value in case this constructor is executed without passing parameters
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    
    // MARK: - Fetch Posts
    func fetchPosts(){
        let postRefModel = PostReferencesModel(id: user.uid)
        apiService.fetchKeys(from: postRefModel) { [weak self] result in
            guard let postKeys = try? result.get() else {return}
            self?.loadPosts(from: postKeys)
        }
    }
    
    func loadPosts(from keys: [String]) {
        let models = keys.map { PostKeyModel(id: $0)}
        PostLoader.shared.loadRange(from: models) { [weak self] result in
            switch result {
            case .success(let posts):
                self?.postPublisher.send(posts)
            case .failure(_):
                print("failed")
                break
            }
        }
    }
    
    // MARK: - Fetching functions
    func fetchWorkoutKeys() {
        let referencesModel = SavedWorkoutCreatorKeyModel(id: user.uid)
        apiService.fetchKeys(from: referencesModel) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let keys):
                self.loadWorkouts(from: keys)
            case .failure(let error):
                self.errorFetchingWorkouts.send(error)
            }
        }
    }
    
    func loadWorkouts(from keys: [String]) {
        let savedKeysModel = keys.map { SavedWorkoutKeyModel(id: $0) }
        apiService.fetchRange(from: savedKeysModel, returning: SavedWorkoutModel.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let savedWorkoutModels):
                let models = savedWorkoutModels.filter { $0.isPrivate == false }
                self.savedWorkouts.send(models)
            case .failure(let error):
                self.errorFetchingWorkouts.send(error)
            }
        }
    }
    
    // MARK: - Fetch Clips
    func fetchClipKeys() {
        let searchModel = UserClipsModel(id: user.uid)
        apiService.fetchInstance(of: searchModel, returning: KeyClipModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.loadClips(from: models)
            case .failure(_):
                break
            }
        }
    }
    private func loadClips(from keys: [KeyClipModel]) {
        apiService.fetchRange(from: keys, returning: ClipModel.self) { [weak self] result in
            switch result {
            case .success(var models):
                models.sort { $0.time < $1.time }
                self?.clipPublisher.send(models)
            case .failure(_):
                break
            }
        }
    }
    
    // MARK: - Liking Posts
//    func likeCheck(_ post: post) {
//        let likeCheck = PostLikesModel(postID: post.id)
//        apiService.checkExistence(of: likeCheck) { [weak self] result in
//            switch result {
//            case .success(let liked):
//                if !liked {
//                    self?.like(post)
//                }
//            case .failure(let error):
//                self?.errorLikingPost.send(error)
//            }
//        }
//    }
//
//    func like(_ post: post) {
//        let likeModels = LikeTransportLayer(postID: post.id).postLike(post: post)
//        apiService.multiLocationUpload(data: likeModels) { [weak self] result in
//            switch result {
//            case .success(()):
//                LikesAPIService.shared.LikedPostsCache[post.id] = true
//            case .failure(let error):
//                self?.errorLikingPost.send(error)
//            }
//        }
//    }


    
    
    // MARK: - Retreive Functions
    func getWorkout(from tappedPost: post) {
        if let workoutID = tappedPost.workoutID {
            let keyModel = WorkoutKeyModel(id: workoutID, assignID: tappedPost.posterID)
            WorkoutLoader.shared.load(from: keyModel) { [weak self] result in
                guard let workout = try? result.get() else {return}
                self?.workoutSelected.send(workout)
            }
        }
        else if let savedWorkoutID = tappedPost.savedWorkoutID {
            let keyModel = SavedWorkoutKeyModel(id: savedWorkoutID)
            SavedWorkoutLoader.shared.load(from: keyModel) { [weak self] result in
                guard let workout = try? result.get() else {return}
                self?.savedWorkoutSelected.send(workout)
            }
        }
    }
    
    func getUser(from tappedPost: post) {
        let userSearchModel = UserSearchModel(uid: tappedPost.posterID)
        UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
            guard let user = try? result.get() else {return}
            if user != UserDefaults.currentUser {
                self?.userSelected.send(user)
            }
        }
    }
    
    
    
    // MARK: - Actions
//    func follow() {
//        let followModel = FollowModel(id: user.uid)
//        let points = followModel.getUploadPoints()
//        apiService.multiLocationUpload(data: points) { [weak self] result in
//            switch result {
//            case .success(()):
//                self?.followSuccess.send(true)
//            case .failure(_):
//                self?.followSuccess.send(false)
//            }
//        }
//    }
}
