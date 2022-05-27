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
    @Published var isLoading: Bool = false
    @Published var postsToShow: [PostModel] = []
    var postPublisher = CurrentValueSubject<[PostModel],Never>([])
    
    var errorLoadingPosts = PassthroughSubject<Void,Never>()
    
    var errorLikingPost = PassthroughSubject<Error,Never>()
    
    var errorFetchingWorkouts = PassthroughSubject<Error,Never>()
    
    var workoutSelected = PassthroughSubject<WorkoutModel,Never>()
    
    var savedWorkoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    
    var userSelected = PassthroughSubject<Users,Never>()
    
    var reloadListener = PassthroughSubject<PostModel,Never>()

    // MARK: - Properties
    var storedPosts: [PostModel] = []
    var storedLikedPosts: [PostModel] = []
    var fetchedPosts: Bool = false
    var fetchedLikedPosts: Bool = false
    var currentIndex: Int = 0
    
    var apiService: FirebaseDatabaseManagerService
    
    // the user to view, passed from coordinator
    var user: Users!

    
    // MARK: - Initializer
    
    // Note: apiService has a default value in case this constructor is executed without passing parameters
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    func switchSegment(to index: Int) {
        postsToShow = []
        currentIndex = index
        if index == 0 {
            fetchPostRefs()
        } else {
            fetchLikedPostRefs()
        }
    }
    func refresh() {
        fetchedPosts = false
        fetchedLikedPosts = false
        if currentIndex == 0 {
            fetchPostRefs()
        } else {
            fetchLikedPostRefs()
        }
    }
    
    // MARK: - Fetching functions
    func fetchPostRefs() {
        if fetchedPosts {
            postsToShow = storedPosts
        } else {
            isLoading = false
            let postRefModel = PostReferencesModel(id: user.uid)
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
    }
    func loadPosts(from keys: [String]) {
        let models = keys.map { PostKeyModel(id: $0)}
        PostLoader.shared.loadRange(from: models) { [weak self] result in
            switch result {
            case .success(let posts):
                self?.storedPosts = posts
                self?.postsToShow = posts
                self?.isLoading = false
                self?.fetchedPosts = true
            case .failure(_):
                self?.errorLoadingPosts.send(())
                self?.isLoading = false
            }
        }

    }
    // MARK: - Fetch Like Posts
    func fetchLikedPostRefs() {
        if fetchedLikedPosts {
            postsToShow = storedLikedPosts
        } else {
            isLoading = true
            let fetchModel = FetchLikedPostsModel(id: user.uid)
            apiService.fetchKeys(from: fetchModel) { [weak self] result in
                switch result {
                case .success(let keys):
                    self?.loadLikedPosts(from: keys)
                case .failure(_):
                    self?.errorLoadingPosts.send(())
                    self?.isLoading = false
                }
            }
        }
    }
    func loadLikedPosts(from keys: [String]) {
        let models = keys.map { PostKeyModel(id: $0)}
        PostLoader.shared.loadRange(from: models) { [weak self] result in
            switch result {
            case .success(let posts):
                self?.storedLikedPosts = posts
                self?.postsToShow = posts
                self?.isLoading = false
                self?.fetchedLikedPosts = true
            case .failure(_):
                self?.errorLoadingPosts.send(())
                self?.isLoading = false
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
