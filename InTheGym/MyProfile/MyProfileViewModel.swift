//
//  MyProfileViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine


class MyProfileViewModel {
    
    // MARK: - Publishers
    var postPublisher = CurrentValueSubject<[post],Never>([])
    
    var followerCountPublisher = CurrentValueSubject<Int,Never>(0)
    
    var followingCountPublisher = CurrentValueSubject<Int,Never>(0)
    
    var errorLoadingPosts = PassthroughSubject<Void,Never>()
    
    var workoutSelected = PassthroughSubject<WorkoutModel,Never>()
    
    var savedWorkoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    
    var userSelected = PassthroughSubject<Users,Never>()
    
    var errorLikingPost = PassthroughSubject<Error,Never>()
    
    var reloadListener = PassthroughSubject<post,Never>()
    
    
    // MARK: - Properties
    
    var currentProfileModel: UserProfileModel = UserProfileModel(user: UserDefaults.currentUser)
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    
    // MARK: - Fetching functions
    func fetchPostRefs() {
        let postRefModel = PostReferencesModel(id: UserDefaults.currentUser.uid)
        apiService.fetchKeys(from: postRefModel) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.loadPosts(from: keys)
            case .failure(_):
                self?.errorLoadingPosts.send(())
            }
        }
    }
    
    func loadPosts(from keys: [String]) {
        let models = keys.map { PostKeyModel(id: $0)}
        PostLoader.shared.loadRange(from: models) { [weak self] result in
            switch result {
            case .success(let posts):
                self?.postPublisher.send(posts)
            case .failure(_):
                self?.errorLoadingPosts.send(())
            }
        }
    }
    
    // MARK: - Fetch Follower Count
    func getFollowerCount() {
        let followerModel = FollowersModel(id: UserDefaults.currentUser.uid)
        apiService.childCount(of: followerModel) { [weak self] result in
            switch result {
            case .success(let count):
                print("Followers = \(count)")
                self?.currentProfileModel.followers = count
                self?.followerCountPublisher.send(count)
            case .failure(_):
                break
            }
        }
        let followingModel = FollowingModel(id: UserDefaults.currentUser.uid)
        apiService.childCount(of: followingModel) { [weak self] result in
            switch result {
            case .success(let count):
                print("Following = \(count)")
                self?.currentProfileModel.following = count
                self?.followingCountPublisher.send(count)
            case .failure(_):
                break
            }
        }
    }

    
    // MARK: - Actions
    

    
    // MARK: - Liking Posts
    func likeCheck(_ post: post) {
        let likeCheck = PostLikesModel(postID: post.id)
        apiService.checkExistence(of: likeCheck) { [weak self] result in
            switch result {
            case .success(let liked):
                if !liked {
                    self?.like(post)
                }
            case .failure(let error):
                self?.errorLikingPost.send(error)
            }
        }
    }
    
    func like(_ post: post) {
        let likeModels = LikeTransportLayer(postID: post.id).postLike(post: post)
        apiService.multiLocationUpload(data: likeModels) { [weak self] result in
            switch result {
            case .success(()):
                LikesAPIService.shared.LikedPostsCache[post.id] = true
            case .failure(let error):
                self?.errorLikingPost.send(error)
            }
        }
    }


    
    
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

}
