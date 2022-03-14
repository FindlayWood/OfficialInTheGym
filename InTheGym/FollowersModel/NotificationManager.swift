//
//  NotificationManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class NotificationManager {
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
//    var delegate: NotificationDelegate
//
//    init(delegate: NotificationDelegate){
//        self.delegate = delegate
//    }
//
//    func upload(withCompletionBlock: @escaping (Result<Bool, Error>) -> Void) {
//        let notificationReference = Database.database().reference().child("Notifications").child(delegate.toUserID!).childByAutoId()
//        notificationReference.setValue(delegate.toObject()) { error, snapshot in
//            if let error = error {
//                withCompletionBlock(.failure(error))
//            } else {
//                withCompletionBlock(.success(true))
//            }
//        }
//    }
    
    
//    func send(_ type: NotificationType, to: String, postID: String? = nil, groupID: String? = nil, workoutID: String? = nil, savedWorkoutID: String? = nil) {
//        let newNotification = NotificationModel(to: to, postID: postID, groupID: groupID, workoutID: workoutID, savedWorkoutID: savedWorkoutID, type: type)
//    }
    func send(_ type: CreateNotificationType, completion: @escaping ((Result<NotificationModel,Error>) -> Void)) {
        var notification: NotificationModel!
        switch type {
        case .acceptedRequest(let sendTo):
            notification = .init(to: sendTo, type: .AcceptedRequest)
        case .likedPost(let sendTo, let postID):
            notification = .init(to: sendTo, postID: postID, type: .LikedPost)
        case .sentRequest(let sendTo):
            notification = .init(to: sendTo, type: .NewRequest)
        }
        apiService.uploadTimeOrderedModel(model: notification) { [weak self] result in
            completion(result)
        }
    }
}
