//
//  PlayerTimelineViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class PlayerTimelineViewModel {
    
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    
    var thinkingTimeActivePublisher = PassthroughSubject<Bool,Never>()
    
    var postPublisher = CurrentValueSubject<[PostModel],Never>([])
    
    var workoutSelected = PassthroughSubject<WorkoutModel,Never>()
    
    var savedWorkoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    
    var userSelected = PassthroughSubject<Users,Never>()
    
    var subscriptions = Set<AnyCancellable>()
    
    var errorLikingPost = PassthroughSubject<Error,Never>()
    
    var reloadListener = PassthroughSubject<PostModel,Never>()
    
    var deletePostListener = PassthroughSubject<PostModel,Never>()

    // MARK: - Properties
    var selectedCellIndex: IndexPath?
    
    var apiService: FirebaseDatabaseManagerService

    
    //MARK: - Initialiser
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }

    // MARK: - Fetch Posts
    func fetchPosts() {
        isLoading = true
        apiService.fetch(PostModel.self) { [weak self] result in
            guard let self = self else {return}
            do {
                let posts = try result.get()
                self.filterPosts(posts)
            } catch {
                print(String(describing: error))
                self.isLoading = false
            }
        }
    }
    func filterPosts(_ posts: [PostModel]) {
        var postsToShow = [PostModel]()
        let dispatchGroup = DispatchGroup()
        for post in posts {
            dispatchGroup.enter()
            if post.posterID == UserDefaults.currentUser.uid {
                postsToShow.append(post)
                dispatchGroup.leave()
            } else {
                timeLineAlgorithm(post) { show in
                    defer { dispatchGroup.leave() }
                    if show { postsToShow.append(post)}
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            postsToShow.sort(by: {$0.time > $1.time})
            self.postPublisher.send(postsToShow)
            self.addPostsToCache(postsToShow)
            self.isLoading = false
        }
    }
    func addPostsToCache(_ posts: [PostModel]) {
        let _ = posts.map { PostLoader.shared.add($0) }
    }
    
    struct FollowingCheckModel: FirebaseInstance {
        var id: String
        var internalPath: String {
            return "Following/\(UserDefaults.currentUser.uid)/\(id)"
        }
    }
    
    // MARK: - TimeLine Algorithm
    func timeLineAlgorithm(_ post: PostModel, completion: @escaping (Bool) -> Void) {
        let followingModel = FollowingCheckModel(id: post.posterID)
        apiService.checkExistence(of: followingModel) { result in
            do {
                let following = try result.get()
                if following {
                    completion(true)
                } else if !post.isPrivate && post.likeCount > 10 {
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                print(String(describing: error))
                completion(false)
            }
        }
    }

 
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

    // MARK: - Delete Post
    func deletePost(_ post: PostModel) {
        let deletePostModel = FirebaseMultiUploadDataPoint(value: nil, path: "Posts/\(post.id)")
        let deletePostRefModel = FirebaseMultiUploadDataPoint(value: nil, path: "PostSelfReferences/\(post.posterID)/\(post.id)")
        Task {
            do {
                try await apiService.multiLocationUploadAsync(data: [deletePostModel, deletePostRefModel])
                print("deleted")
            }
            catch {
                print(String(describing: error))
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
    

 
    
    // MARK: - Thinking Time Check
    func checkForThinkingTime() {
        FirebaseDatabaseManager.shared.fetchSingleModel(ThinkingTimeCheckModel.self) { [weak self] result in
            guard let model = try? result.get() else {return}
            self?.thinkingTimeActivePublisher.send(model.isActive)
        }
    }
    
}
