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
    @Published var isLoading: Bool = false
    
    var postPublisher = CurrentValueSubject<[PostModel],Never>([])
    
    var savedWorkouts = CurrentValueSubject<[SavedWorkoutModel],Never>([])
    
    var clipPublisher = CurrentValueSubject<[ClipModel],Never>([])
    
    var followerCountPublisher = CurrentValueSubject<Int,Never>(0)
    
    var followingCountPublisher = CurrentValueSubject<Int,Never>(0)
    
    var errorLoadingPosts = PassthroughSubject<Void,Never>()
    
    var errorFetchingWorkouts = PassthroughSubject<Error,Never>()
    
    var workoutSelected = PassthroughSubject<WorkoutModel,Never>()
    
    var savedWorkoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    
    var userSelected = PassthroughSubject<Users,Never>()
    
    var errorLikingPost = PassthroughSubject<Error,Never>()
    
    var reloadListener = PassthroughSubject<PostModel,Never>()
    
    
    // MARK: - Properties
    var selectedCellIndex: IndexPath?
    
    var currentProfileModel: UserProfileModel = UserProfileModel(user: UserDefaults.currentUser)
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    
    // MARK: - Fetching functions
    func fetchPostRefs() {
        isLoading = false
        let postRefModel = PostReferencesModel(id: UserDefaults.currentUser.uid)
        apiService.fetchKeys(from: postRefModel) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.loadPosts(from: keys)
            case .failure(_):
                self?.errorLoadingPosts.send(())
                self?.isLoading = false
            }
        }
    }
    
    func loadPosts(from keys: [String]) {
        let models = keys.map { PostKeyModel(id: $0)}
        PostLoader.shared.loadRange(from: models) { [weak self] result in
            switch result {
            case .success(let posts):
                self?.postPublisher.send(posts)
                self?.isLoading = false
            case .failure(_):
                self?.errorLoadingPosts.send(())
                self?.isLoading = false
            }
        }
    }
    
    // MARK: - Fetching functions
    func fetchWorkoutKeys() {
        let referencesModel = SavedWorkoutsReferences(id: UserDefaults.currentUser.uid)
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
                self.savedWorkouts.send(savedWorkoutModels)
            case .failure(let error):
                self.errorFetchingWorkouts.send(error)
            }
        }
    }
    
    // MARK: - Fetch Clips
    func fetchClipKeys() {
        let searchModel = UserClipsModel(id: UserDefaults.currentUser.uid)
        apiService.fetchInstance(of: searchModel, returning: KeyClipModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.loadClips(from: models)
            case .failure(_):
                break
            }
        }
    }
    func loadClips(from keys: [KeyClipModel]) {
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
    func likeCheck(_ post: PostModel) {
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
    
    func like(_ post: PostModel) {
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
    func getWorkout(from tappedPost: PostModel) {
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
    
    func getUser(from tappedPost: PostModel) {
        let userSearchModel = UserSearchModel(uid: tappedPost.posterID)
        UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
            guard let user = try? result.get() else {return}
            if user != UserDefaults.currentUser {
                self?.userSelected.send(user)
            }
        }
    }

}
