//
//  GroupHomePageViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class GroupHomePageViewModel {
    
    // MARK: - Publishers
    var postsPublisher = CurrentValueSubject<[GroupPost],Never>([])
    var errorLoadingPosts = PassthroughSubject<Error,Never>()
    var leaderPublisher = CurrentValueSubject<Users,Never>(Users.nilUser)
    var leaderErrorPublisher = PassthroughSubject<Error,Never>()
    var headerImagePublisher = CurrentValueSubject<UIImage?,Never>(nil)
    
    // MARK: - Callbacks
    var reloadPostsTableViewClosure: (() -> ())?
    var reloadMembersTableViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    var reloadHeaderImageClosure: (() -> ())?
    var updateNavigationTitleImage: (() -> ())?
    var groupLeaderLoadedClosure: (() -> ())?
    var errorLikingPostClosure: (() -> ())?
        // user actions callbacks
    var tappedUserReturnedClosure: ((Users) -> ())?
    var tappedWorkoutClosure: ((WorkoutDelegate) -> ())?
    
    // MARK: - Properties
    var apiService: FirebaseAPIGroupServiceProtocol
    
    var currentGroup: GroupModel!
    
    var posts: [GroupPost] = [] {
        didSet {
            reloadPostsTableViewClosure?()
        }
    }
    
    var numberOfPosts: Int {
        return posts.count
    }
    
    var members: [Users] = [] {
        didSet {
            reloadMembersTableViewClosure?()
        }
    }
    var numberOfMembers: Int = 0 {
        didSet {
            reloadMembersTableViewClosure?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            updateLoadingStatusClosure?()
        }
    }
    
    var headerImage: UIImage? {
        didSet {
            reloadHeaderImageClosure?()
        }
    }
    
    var headerImageInView: Bool = true {
        didSet {
            if headerImageInView != oldValue {
                updateNavigationTitleImage?()
            }
        }
    }
    var groupLeader: Users! {
        didSet {
            groupLeaderLoadedClosure?()
        }
    }
    
    var postsLoadedSuccessfully: Bool = false
    var membersLoadedSuccessfully: Bool = false
    var groupLeaderLoadedSuccessfully: Bool = false
    
    // MARK: - Errors
    var likingPostError: Error? {
        didSet {
            errorLikingPostClosure?()
        }
    }
    
    
    // MARK: - Initializer
    init(apiService: FirebaseAPIGroupServiceProtocol = FirebaseAPIGroupService.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetching Functions
    func loadPosts() {
        let groupPostsModel = GroupPostsModel(groupID: currentGroup.uid)
        FirebaseDatabaseManager.shared.fetchInstance(of: groupPostsModel, returning: GroupPost.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(var posts):
                posts.sort { $0.time > $1.time }
//                self.posts = posts.sorted(by:  { $0.time > $1.time })
                self.postsPublisher.send(posts)
                self.postsLoadedSuccessfully = true
            case .failure(let error):
                self.errorLoadingPosts.send(error)
            }
        }
        
        
//        let endpoint = PostEndpoints.getGroupPosts(groupID: groupID)
//        apiService.loadPosts(from: endpoint) { [weak self] result in
//            guard let self = self else {return}
//            switch result {
//            case .success(let loadedPosts):
//                self.posts = loadedPosts.sorted(by: { $0.time > $1.time })
//                self.postsLoadedSuccessfully = true
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
    }
        
//    func loadMembers(from groupID: String) {
//        apiService.loadGroupMemberCount(from: groupID) { [weak self] result in
//            guard let self = self else {return}
//            switch result {
//            case .success(let returnedMemberCount):
//                self.numberOfMembers = returnedMemberCount
//                self.membersLoadedSuccessfully = true
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//    }
    
    func loadHeaderImage() {
        ImageCache.shared.load(from: ProfileImageDownloadModel(id: currentGroup.uid)) { [weak self] result in
            guard let image = try? result.get() else {return}
            self?.headerImagePublisher.send(image)
        }
//        ImageAPIService.shared.getProfileImage(for: groupID) { [weak self] image in
//            guard let self = self else {return}
//            if let headerImage = image {
//                self.headerImage = headerImage
//            }
//        }
    }
    
    func loadGroupLeader() {
        let userSearchModel = UserSearchModel(uid: currentGroup.leader)
        UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
            switch result {
            case .success(let user):
                self?.leaderPublisher.send(user)
            case .failure(let error):
                self?.leaderErrorPublisher.send(error)
            }
        }
//        UserIDToUser.transform(userID: userID) { [weak self] leader in
//            guard let self = self else {return}
//            self.groupLeader = leader
//            self.groupLeaderLoadedSuccessfully = true
//        }
    }
    
    func getPostData(at indexPath: IndexPath) -> GroupPost {
        return posts[indexPath.row]
    }
    func getGroupImage(with groupID: String) -> UIImage? {
        return nil
    }
    func getBarImage() -> UIImage {
        return UIImage(systemName: "ellipsis")!
//        if #available(iOS 13.0, *) {
//            return UIImage(systemName: "ellipsis")!
//        } else {
//            return UIImage(named: "more_icon")!
//        }
    }
    func isCurrentUserLeader() -> Bool {
        let leader = leaderPublisher.value
        return leader == UserDefaults.currentUser
    }
    
    // MARK: - Actions
        
//    func likePost(at indexPath: IndexPath) {
////        let likedPost = getPostData(at: indexPath)
////        let likeEndPoint = LikePostEndpoint.likePost(post: likedPost)
////        likedPost.likeCount += 1
////        apiService.likePost(from: likeEndPoint) { [weak self] result in
////            guard let self = self else {return}
////            switch result {
////            case .success(()):
////                LikesAPIService.shared.LikedPostsCache.removeObject(forKey: likedPost.id as NSString)
////                LikesAPIService.shared.LikedPostsCache.setObject(1, forKey: likedPost.id as NSString)
////                self.sendLikeNotification(for: likedPost)
////            case .failure(let error):
////                print(error.localizedDescription)
////                self.likingPostError = error
////            }
////        }
//    }
//
//    func userTapped(at indexPath: IndexPath) {
//        let tappedPost = getPostData(at: indexPath)
//        let posterID = tappedPost.posterID
//        UserIDToUser.transform(userID: posterID) { [weak self] user in
//            guard let self = self else {return}
//            if user.uid != FirebaseAuthManager.currentlyLoggedInUser.uid {
//                self.tappedUserReturnedClosure?(user)
//            }
//        }
//    }
//
//    func workoutTapped(at indexPath: IndexPath) {
//        let tappedPost = getPostData(at: indexPath)
//        guard let attachedWorkout = tappedPost.attachedWorkout else {return}
//        apiService.returnTappedWorkout(from: attachedWorkout) { [weak self] result in
//            guard let self = self else {return}
//            switch result {
//            case .success(let returnedWorkout):
//                self.tappedWorkoutClosure?(returnedWorkout)
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//    }
    
    // MARK: - Send Notifications
//    func sendLikeNotification(for post: post) {
//        let groupID = currentGroup.uid
//        let posterID = post.posterID
//        let postID = post.id
//        if posterID != FirebaseAuthManager.currentlyLoggedInUser.uid {
//            let notification = NotificationGroupLikedPost(from: FirebaseAuthManager.currentlyLoggedInUser.uid, to: posterID, postID: postID, groupID: groupID)
//            let uploadNotification = NotificationManager(delegate: notification)
//            uploadNotification.upload { _ in
//
//            }
//        }
//    }
}

