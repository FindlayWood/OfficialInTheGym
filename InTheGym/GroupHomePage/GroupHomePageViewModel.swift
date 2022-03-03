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
    
    var workoutSelected = PassthroughSubject<WorkoutModel,Never>()
    var savedWorkoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    var userSelected = PassthroughSubject<Users,Never>()

    var errorLiking = PassthroughSubject<Void,Never>()
    
    weak var groupListener: GroupPostListener?
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService
    
    var currentGroup: GroupModel!
    
    var postsLoadedSuccessfully: Bool = false
    var membersLoadedSuccessfully: Bool = false
    var groupLeaderLoadedSuccessfully: Bool = false
    
    
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetching Functions
    func loadPosts() {
        let groupPostsModel = GroupPostsModel(groupID: currentGroup.uid)
        apiService.fetchInstance(of: groupPostsModel, returning: GroupPost.self) { [weak self] result in
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
    }
    
    func loadHeaderImage() {
        ImageCache.shared.load(from: ProfileImageDownloadModel(id: currentGroup.uid)) { [weak self] result in
            guard let image = try? result.get() else {return}
            self?.headerImagePublisher.send(image)
        }
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
    }


    func getBarImage() -> UIImage {
        return UIImage(systemName: "ellipsis")!
    }
    
    func isCurrentUserLeader() -> Bool {
        let leader = leaderPublisher.value
        return leader == UserDefaults.currentUser
    }
    
    func getGroupInfo() -> MoreGroupInfoModel {
        let info = MoreGroupInfoModel(leader: leaderPublisher.value,
                                      headerImage: headerImagePublisher.value,
                                      description: currentGroup.description,
                                      groupName: currentGroup.username,
                                      groupID: currentGroup.uid,
                                      leaderID: currentGroup.leader)
        return info
    }
    
    // MARK: - Actions

    
    // MARK: - Send Notifications
    
    // MARK: - Retreive Functions
    func getWorkout(from tappedPost: GroupPost) {
        if let workoutID = tappedPost.workoutID {
            let keyModel = WorkoutKeyModel(id: workoutID)
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
    
    func getUser(from tappedPost: GroupPost) {
        let userSearchModel = UserSearchModel(uid: tappedPost.posterID)
        UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
            guard let user = try? result.get() else {return}
            if user != UserDefaults.currentUser {
                self?.userSelected.send(user)
            }
        }
    }
    
    // MARK: - Like
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

}

