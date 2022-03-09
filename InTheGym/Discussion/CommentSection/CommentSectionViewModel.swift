//
//  CommentSectionViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class CommentSectionViewModel {
    // MARK: - Publishers
    var comments = CurrentValueSubject<[Comment],Never>([])
    var errorFetchingComments = PassthroughSubject<Error,Never>()
    
    var uploadingNewComment = PassthroughSubject<Comment,Never>()
    
    var errorUploadingComment = PassthroughSubject<Void,Never>()
    
    var errorLiking = PassthroughSubject<Void,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService
    
    var attachedWorkout: SavedWorkoutModel?
    
    var commentText: String = ""
    
    var mainPost: post!
    
    var mainGroupPost: GroupPost!
    
    lazy var mainPostReplyModel = PostReplies(postID: mainPost.id)
    
    lazy var groupPostReplyModel = PostReplies(postID: mainGroupPost.id)
    
    var listener: PostListener!
    
    var groupListener: GroupPostListener!
    
    var workoutSelected = PassthroughSubject<WorkoutModel,Never>()
    
    var savedWorkoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    
    var userSelected = PassthroughSubject<Users,Never>()
    
    var isLoading = CurrentValueSubject<Bool,Never>(false)
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Functions
    func loadGeneric<T: FirebaseInstance>(for postGeneric: T) {
        isLoading.send(true)
        apiService.fetchInstance(of: postGeneric, returning: Comment.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(var comments):
                comments.sort { $0.time > $1.time }
                self.comments.send(comments)
                self.isLoading.send(false)
            case .failure(let error):
                self.errorFetchingComments.send(error)
                self.isLoading.send(false)
            }
        }
    }
    
    // MARK: - Actions
    func sendPressed() {
        self.isLoading.send(true)
        let newComment = Comment(id: UUID().uuidString,
                                 username: UserDefaults.currentUser.username,
                                 time: Date().timeIntervalSince1970,
                                 message: commentText,
                                 posterID: UserDefaults.currentUser.uid,
                                 postID: mainPost.id,
                                 attachedWorkoutSavedID: attachedWorkout?.id)
 
        let uploadModel = UploadCommentModel(comment: newComment)
        let points = uploadModel.uploadPoints()
        apiService.multiLocationUpload(data: points) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                self.isLoading.send(false)
                self.mainPost.replyCount += 1
                self.uploadingNewComment.send(newComment)
                self.listener.send(self.mainPost)
            case .failure(_):
                self.errorUploadingComment.send(())
                self.isLoading.send(false)
            }
        }
    }
    
    func groupSendPressed() {
        self.isLoading.send(true)
        let newComment = Comment(id: UUID().uuidString,
                                 username: UserDefaults.currentUser.username,
                                 time: Date().timeIntervalSince1970,
                                 message: commentText,
                                 posterID: UserDefaults.currentUser.uid,
                                 postID: mainGroupPost.id,
                                 attachedWorkoutSavedID: attachedWorkout?.id)
        
        let uploadModel = UploadGroupCommentModel(comment: newComment, groupID: mainGroupPost.groupID)
        let points = uploadModel.uploadPoints()
        apiService.multiLocationUpload(data: points) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                self.uploadingNewComment.send(newComment)
                self.isLoading.send(false)
                self.mainGroupPost.replyCount += 1
                self.groupListener.send(self.mainGroupPost)
            case .failure(_):
                self.errorUploadingComment.send(())
                self.isLoading.send(false)
            }
        }
    }
    
    func updateCommentText(with text: String) {
        commentText = text
    }
    
    // MARK: - Like Check
    func likeCheck(_ post: post) {
        let likeCheck = PostLikesModel(postID: post.id)
        apiService.checkExistence(of: likeCheck) { [weak self] result in
            switch result {
            case .success(let liked):
                if !liked {
                    self?.like(post)
                }
            case .failure(_):
                self?.errorLiking.send(())
            }
        }
    }
    
    func groupLikeCheck(_ post: GroupPost) {
        let likeCheck = PostLikesModel(postID: post.id)
        apiService.checkExistence(of: likeCheck) { [weak self] result in
            switch result {
            case .success(let liked):
                if !liked {
                    self?.groupLike(post)
                }
            case .failure(_):
                self?.errorLiking.send(())
            }
        }
    }
    
    // MARK: - Like Group Post
    func groupLike(_ post: GroupPost) {
        let likeModels = LikeTransportLayer(postID: post.id).groupPostLike(post: post)
        apiService.multiLocationUpload(data: likeModels) { [weak self] result in
            switch result {
            case .success(()):
                LikesAPIService.shared.LikedPostsCache[post.id] = true
                self?.groupListener.send(post)
            case .failure(_):
                self?.errorLiking.send(())
            }
        }
    }
    // MARK: - Like Post
    func like(_ post: post) {
        let likeModels = LikeTransportLayer(postID: post.id).postLike(post: post)
        apiService.multiLocationUpload(data: likeModels) { [weak self] result in
            switch result {
            case .success(()):
                LikesAPIService.shared.LikedPostsCache[post.id] = true
                self?.listener.send(post)
            case .failure(_):
                self?.errorLiking.send(())
            }
        }
    }
    
    func sendNotifications() {
        
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
    
    func getWorkout(from tappedPost: GroupPost) {
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
    func getUser(from tappedPost: GroupPost) {
        let userSearchModel = UserSearchModel(uid: tappedPost.posterID)
        UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
            guard let user = try? result.get() else {return}
            if user != UserDefaults.currentUser {
                self?.userSelected.send(user)
            }
        }
    }
    func getUser(from tappedPost: Comment) {
        let userSearchModel = UserSearchModel(uid: tappedPost.posterID)
        UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
            guard let user = try? result.get() else {return}
            if user != UserDefaults.currentUser {
                self?.userSelected.send(user)
            }
        }
    }

}
