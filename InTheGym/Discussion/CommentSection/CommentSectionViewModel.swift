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
    
    var uploadingNewComment = PassthroughSubject<Bool,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService
    
    var attachedWorkout: SavedWorkoutModel?
    
    var commentText: String = ""
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Functions
    func loadGeneric<T: FirebaseInstance>(for postGeneric: T) {
        apiService.fetchInstance(of: postGeneric, returning: Comment.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let comments):
                self.comments.send(comments)
            case .failure(let error):
                self.errorFetchingComments.send(error)
            }
        }
    }
    
    func upload<T: FirebaseInstance>(_ object: T, autoID: Bool) {
        apiService.upload(data: object, autoID: autoID) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                self.uploadingNewComment.send(true)
            case .failure(_):
                self.uploadingNewComment.send(false)
            }
        }
    }
    
    // MARK: - Actions
    func sendPressed(_ mainPostID: String) {
        let newComment = Comment(id: UUID().uuidString,
                                 username: FirebaseAuthManager.currentlyLoggedInUser.username,
                                 time: Date().timeIntervalSince1970,
                                 message: commentText,
                                 posterID: FirebaseAuthManager.currentlyLoggedInUser.uid,
                                 postID: mainPostID,
                                 attachedWorkoutSavedID: attachedWorkout?.savedID)
        
        print(newComment)
    }
    
    func updateCommentText(with text: String) {
        commentText = text
    }
    
    func likeCheck(_ post: GroupPost) {
        let likeCheck = PostLikesModel(postID: post.id)
        apiService.checkExistence(of: likeCheck) { [weak self] result in
            switch result {
            case .success(let liked):
                if !liked {
                    self?.like(post: post)
                }
            case .failure(let error):
                self?.errorFetchingComments.send(error)
            }
        }
    }
    func like(post: GroupPost) {
        let likeModels = LikeTransportLayer(postID: post.id).groupPostLike(post: post)
        apiService.multiLocationUpload(data: likeModels) { [weak self] result in
            switch result {
            case .success(()):
                LikesAPIService.shared.LikedPostsCache[post.id] = true
                print("successfully liked")
            case .failure(let error):
                //TODO: - Show like error
                print(error.localizedDescription)
            }
        }
    }
    func sendNotifications() {
        
    }
}
