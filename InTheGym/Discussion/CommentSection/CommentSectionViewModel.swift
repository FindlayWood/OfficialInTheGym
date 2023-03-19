//
//  CommentSectionViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class CommentSectionViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var text: String = ""
    @Published var placeholder: String = "enter text..."
    
    @Published var attachedWorkout: WorkoutModel?
    @Published private(set) var attachedSavedWorkout: SavedWorkoutModel?
    @Published var attachedClip: ClipModel?
    @Published private(set) var taggedUsers: [Users] = []
    @Published private(set) var isPrivate: Bool = false
    
    @Published var successfullyPosted: Bool?
    @Published var errorPosting: Error?
    
    @Published var comments: [Comment] = []
    
    var errorFetchingComments = PassthroughSubject<Error,Never>()
    
    var uploadingNewComment = PassthroughSubject<Comment,Never>()
    
    var errorUploadingComment = PassthroughSubject<Void,Never>()
    
    var errorLiking = PassthroughSubject<Void,Never>()
    
    /// this is called when the tectview should be cleared
    var clearTextPublisher = PassthroughSubject<Void,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService
    
    var commentText: String = ""
    
    var mainPost: PostModel!
    
    var mainGroupPost: GroupPost!
    
    lazy var mainPostReplyModel = PostReplies(postID: mainPost.id)
    
    lazy var groupPostReplyModel = PostReplies(postID: mainGroupPost.id)
    
    var listener: PostListener?
    
    var groupListener: GroupPostListener?
    
    var workoutSelected = PassthroughSubject<WorkoutModel,Never>()
    
    var savedWorkoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    
    var userSelected = PassthroughSubject<Users,Never>()
    
    
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Functions
    func loadGeneric<T: FirebaseInstance>(for postGeneric: T) {
        isLoading = true
        apiService.fetchInstance(of: postGeneric, returning: Comment.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(var comments):
                comments.sort { $0.time < $1.time }
                self.comments = comments
                self.isLoading = false
            case .failure(let error):
                self.errorFetchingComments.send(error)
                self.isLoading = false
            }
        }
    }
    // MARK: - Methods
    func updateAttachedTaggedUser(_ user: Users) {
        if !taggedUsers.contains(where: { $0.uid == user.uid }) {
            taggedUsers.append(user)
        }
    }
    func removeTaggedUsers(at offsets: IndexSet) {
        taggedUsers.remove(atOffsets: offsets)
    }
    func updateAttachedSavedWorkout(with model: SavedWorkoutModel) {
        attachedSavedWorkout = model
    }
    func removeAttachedSavedWorkout() {
        attachedSavedWorkout = nil
    }
    func updateAttachedWorkout(with model: WorkoutModel) {
        attachedWorkout = model
    }
    func updatePrivacy(to isPrivate: Bool) {
        self.isPrivate = isPrivate
    }
    // MARK: - Actions
    func sendPressed() {
        self.isLoading = true
        let tagged: [String]? = taggedUsers.map { $0.uid }
        let newComment = Comment(id: UUID().uuidString,
                                 username: UserDefaults.currentUser.username,
                                 time: Date().timeIntervalSince1970,
                                 message: text,
                                 posterID: UserDefaults.currentUser.uid,
                                 postID: mainPost.id,
                                 attachedWorkoutSavedID: attachedWorkout?.id,
                                 taggedUsers: tagged)
 
        let uploadModel = UploadCommentModel(comment: newComment)
        let points = uploadModel.uploadPoints()
        apiService.multiLocationUpload(data: points) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                self.isLoading = false
                self.addedReply(newComment)
            case .failure(_):
                self.errorUploadingComment.send(())
                self.isLoading = false
            }
        }
    }
    func addedReply(_ comment: Comment) {
        mainPost.replyCount += 1
        listener?.send(mainPost)
        PostLoader.shared.add(mainPost)
        uploadingNewComment.send(comment)
    }
    func likedMainPost() {
        mainPost.likeCount += 1
    }
    func groupSendPressed() {
        self.isLoading = true
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
                self.isLoading = false
                self.addedGroupReply(newComment)
            case .failure(_):
                self.errorUploadingComment.send(())
                self.isLoading = false
            }
        }
    }
    func addedGroupReply(_ comment: Comment) {
        mainGroupPost.replyCount += 1
        groupListener?.send(mainGroupPost)
        uploadingNewComment.send(comment)
    }
    func likedMainGroupPost() {
        mainGroupPost.likeCount += 1
    }
    
    func updateCommentText(with text: String) {
        self.text = text
    }
    
    // MARK: - Like Check
    func likeCheck(_ post: PostModel) {
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
                self?.groupListener?.send(post)
            case .failure(_):
                self?.errorLiking.send(())
            }
        }
    }
    // MARK: - Like Post
    func like(_ post: PostModel) {
        let likeModels = LikeTransportLayer(postID: post.id).postLike(post: post)
        apiService.multiLocationUpload(data: likeModels) { [weak self] result in
            switch result {
            case .success(()):
                LikesAPIService.shared.LikedPostsCache[post.id] = true
                self?.listener?.send(post)
            case .failure(_):
                self?.errorLiking.send(())
            }
        }
    }
    
    func sendNotifications() {
        
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
    
    func getUser(from tappedPost: PostModel) {
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
