//
//  DisplayNotificationsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class DisplayNotificationsViewModel {
    
    // MARK: - Publishers
    var notificationsPublisher = CurrentValueSubject<[NotificationModel],Never>([])
    
    var destinationPublisher = PassthroughSubject<NotificationDestination,Never>()

    var errorPublisher = PassthroughSubject<Error,Never>()
    
    // MARK: - Properties
    
    let navigationTitle = "Notifications"
    
    var apiService: FirebaseDatabaseManagerService

    
    // MARK: - Constructor
    
    // Note: apiService has a default value in case this constructor is executed without passing parameters
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
 
    
    // MARK: - Fetching functions
    func fetchNotifications() {
        apiService.fetch(NotificationModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.notificationsPublisher.send(models)
            case .failure(let error):
                self?.errorPublisher.send(error)
            }
        }
    }
    
    // MARK: - Actions
    func notificationSelected(_ model: NotificationModel) {
        switch model.type {
        case .LikedPost, .Reply:
            // post
            guard let postID = model.postID else {return}
            let postSearchModel = PostKeyModel(id: postID)
            PostLoader.shared.load(from: postSearchModel) { [weak self] result in
                guard let post = try? result.get() else {return}
                self?.destinationPublisher.send(.post(post))
            }
        case .Followed:
            // user page
            let userSearchModel = UserSearchModel(uid: model.fromUserID)
            UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
                guard let user = try? result.get() else {return}
                self?.destinationPublisher.send(.user(user))
            }
        case .GroupLikedPost, .GroupReply:
            // group post
            guard let groupID = model.groupID,
                  let postID = model.postID else {return}
            let groupPostSearchModel = GroupPostSearchModel(groupID: groupID, postID: postID)
        case .NewRequest:
            // request page
            self.destinationPublisher.send(.newRequest)
        case .AcceptedRequest:
            // player detail page
            let userSearchModel = UserSearchModel(uid: model.fromUserID)
            UsersLoader.shared.load(from: userSearchModel) { [weak self] result in
                guard let user = try? result.get() else {return}
                self?.destinationPublisher.send(.acceptedRequest(user))
            }
        case .NewWorkout:
            // workouts
            self.destinationPublisher.send(.newWorkout)
        }
    }
}

enum NotificationDestination {
    case post(PostModel)
    case groupPost(GroupPost)
    case user(Users)
    case newRequest
    case acceptedRequest(Users)
    case newWorkout
}
