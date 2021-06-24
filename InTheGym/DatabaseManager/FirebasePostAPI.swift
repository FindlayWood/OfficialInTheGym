//
//  FirebasePostAPI.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

enum PostReplyError: Error {
    case failedToPost
    case failedToUpdateCount
    case failedToSendNotification
}

class FirebasePostAPI {
    typealias escapingResult = Result<Bool,PostReplyError>
    
    static let shared = FirebasePostAPI()
    
    private init(){}
    
    
    /// This function adds a comment/reply to a post
    /// - Parameters:
    ///   - post: this is the post that the comment/reply is being added to
    ///   - message: this is the context of the reply - just a string
    ///   - completion: this is the completion block to return true or an error
    func postReply(to post: PostProtocol, with message: String, and attachment: savedWorkoutDelegate?, completion: @escaping (Result<Bool,PostReplyError>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid,
              let username = ViewController.username,
              let postID = post.postID
        else {
            completion(.failure(.failedToPost))
            return
        }
        var replyData = ["time": ServerValue.timestamp(),
                         "posterID": userID,
                         "message": message,
                         "username": username] as [String: AnyObject]
        if let attachedWorkout = attachment {
            replyData["attachedWorkoutSavedID"] = attachedWorkout.workoutID as AnyObject
            replyData["attachedWorkoutCreator"] = attachedWorkout.createdBy as AnyObject
            replyData["attachedWorkoutCreatorID"] = attachedWorkout.creatorID as AnyObject
            replyData["attachedWorkoutExerciseCount"] = attachedWorkout.exercises?.count as AnyObject
            replyData["attachedWorkoutTitle"] = attachedWorkout.title as AnyObject
        }
        let replyRef = Database.database().reference().child("PostReplies").child(postID)
        replyRef.childByAutoId().setValue(replyData) { error, snapshot in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.failedToPost))
            } else {
                self.updateReplyCount(on: post, completion: completion)
            }
        }
    }
    
    func postGroupReply(to post: PostProtocol, with message: String, and attachment: savedWorkoutDelegate?, group groupID: String, completion: @escaping (escapingResult) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid,
              let username = ViewController.username,
              let postID = post.postID
        else {
            completion(.failure(.failedToPost))
            return
        }
        var replyData = ["time": ServerValue.timestamp(),
                         "posterID": userID,
                         "message": message,
                         "username": username] as [String: AnyObject]
        if let attachedWorkout = attachment {
            replyData["attachedWorkoutSavedID"] = attachedWorkout.workoutID as AnyObject
            replyData["attachedWorkoutCreator"] = attachedWorkout.createdBy as AnyObject
            replyData["attachedWorkoutCreatorID"] = attachedWorkout.creatorID as AnyObject
            replyData["attachedWorkoutExerciseCount"] = attachedWorkout.exercises?.count as AnyObject
            replyData["attachedWorkoutTitle"] = attachedWorkout.title as AnyObject
        }
        let replyRef = Database.database().reference().child("PostReplies").child(postID)
        replyRef.childByAutoId().setValue(replyData) { error, snapshot in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.failedToPost))
            } else {
                self.updateGroupReplyCount(on: post, group: groupID, completion: completion)
            }
        }
    }
    
    
    /// This function updates the reply count of the post using a transaction block - each reply updates the count by 1
    /// - Parameters:
    ///   - post: this is the post that the repl is being added to
    ///   - completion: this is the completion block to return true or an error
    private func updateReplyCount(on post: PostProtocol, completion: @escaping (Result<Bool,PostReplyError>) -> Void) {
        guard let postID = post.postID
        else {
            completion(.failure(.failedToUpdateCount))
            return
        }
        let replyCountRef = Database.database().reference().child("Posts").child(postID)
        
        replyCountRef.runTransactionBlock { (currentData) -> TransactionResult in
            if var post = currentData.value as? [String:AnyObject]{
                var replies = post["replyCount"] as? Int ?? 0
                replies += 1
                post["replyCount"] = replies as AnyObject
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { (error, committed, snapshot) in
            if let error = error{
                print(error.localizedDescription)
            } else {
                self.sendNotification(on: post, completion: completion)
            }
        }
    }
    
    private func updateGroupReplyCount(on post: PostProtocol, group groupID: String, completion: @escaping (escapingResult) -> Void) {
        guard let postID = post.postID
        else {
            completion(.failure(.failedToUpdateCount))
            return
        }
        let replyCountRef = Database.database().reference().child("GroupPosts").child(groupID).child(postID)
        
        replyCountRef.runTransactionBlock { (currentData) -> TransactionResult in
            if var post = currentData.value as? [String:AnyObject]{
                var replies = post["replyCount"] as? Int ?? 0
                replies += 1
                post["replyCount"] = replies as AnyObject
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { (error, committed, snapshot) in
            if let error = error{
                print(error.localizedDescription)
            } else {
                self.sendNotification(on: post, completion: completion)
            }
        }
    }
    
    
    /// This function sends a notification to the user who created the post
    /// - Parameters:
    ///   - post: this is the post that the reply has been added to
    ///   - completion: this is the completion block to return true or an error
    private func sendNotification(on post: PostProtocol, completion: @escaping (Result<Bool,PostReplyError>) -> Void) {
        guard let postID = post.postID,
              let posterID = post.posterID,
              let userID = Auth.auth().currentUser?.uid
        else {
            completion(.failure(.failedToSendNotification))
            return
        }
        
        if userID != posterID{
            let notification = NotificationReplied(from: userID, to: posterID, postID: postID)
            let uploadNotification = NotificationManager(delegate: notification)
            uploadNotification.upload { result in
                switch result {
                case .success(_):
                    completion(.success(true))
                case .failure(_):
                    completion(.failure(.failedToSendNotification))
                }
            }
        }
    }
    
    
}
