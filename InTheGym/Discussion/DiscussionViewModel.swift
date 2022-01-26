//
//  DiscussionViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class DiscussionViewModel{
    
    var reloadTableViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    var replyAddedClosure: (() -> ())?
    
    let userID = Auth.auth().currentUser!.uid
    let postReplyRef : DatabaseReference!
    var handle : DatabaseHandle!
    
    var originalPost : PostProtocol!
    
    var replies: [PostProtocol] = [] {
        didSet{
            self.reloadTableViewClosure?()
        }
    }
    
    var numberOfItems: Int {
        return replies.count
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    
    init(originalPost:PostProtocol){
        self.originalPost = originalPost
        self.postReplyRef = Database.database().reference().child("PostReplies").child(originalPost.postID!)
    }
    
    func fetchData(){
        self.isLoading = true
        var initialLoad = true
        var tempReplies = [PostProtocol]()
        
        
        handle = postReplyRef.observe(.childAdded) { (snapshot) in
            if let snap = snapshot.value as? [String: AnyObject] {
                if (snap["attachedWorkoutSavedID"] as? String) != nil {
                    tempReplies.append(DiscussionReplyPlusWorkout(snapshot: snapshot)!)
                } else {
                    tempReplies.append(DiscussionReply(snapshot: snapshot)!)
                }
            }
            //tempReplies.append(DiscussionReply(snapshot: snapshot)!)
            if initialLoad == false {
                self.replies = tempReplies
            }
        }
        postReplyRef.observeSingleEvent(of: .value) { (_) in
            self.replies = tempReplies
            self.isLoading = false
            initialLoad = false
        }
        
    }
    
    // MARK: - Remove observer
    func removeObserver(){
        self.postReplyRef.removeObserver(withHandle: handle)
    }
    
    // MARK: - Retieve Data
    
    func getData( at indexPath: IndexPath ) -> PostProtocol {
        return replies[indexPath.row]
    }
    
    
    // MARK: - Actions
    func likePost(){
        let postID = originalPost.postID!
        let posterID = originalPost.posterID!
        let postRef = Database.database().reference().child("Posts").child(postID)
        postRef.runTransactionBlock { (currentData) -> TransactionResult in
            if var post = currentData.value as? [String:AnyObject]{
                var likeCount = post["likeCount"] as? Int ?? 0
                likeCount += 1
                post["likeCount"] = likeCount as AnyObject
                currentData.value = post
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { (error, committed, snapshot) in
            if let error = error{
                print(error.localizedDescription)
            }
        }
        if let likes = originalPost.likeCount {
            originalPost.likeCount = likes + 1
        } else {
            originalPost.likeCount = 1
        }
        
        let postLikesRef = Database.database().reference().child("PostLikes").child(postID).child(self.userID)
        postLikesRef.setValue(true)
        let likesRef = Database.database().reference().child("Likes").child(self.userID).child(postID)
        likesRef.setValue(true)
        LikesAPIService.shared.LikedPostsCache[postID] = true
        
        // notification
        if self.userID != posterID{
            let notification = NotificationLikedPost(from: self.userID, to: posterID, postID: postID)
            let uploadNotification = NotificationManager(delegate: notification)
            uploadNotification.upload { _ in
                
            }
        }

    }
    
    func isLiked(completion: @escaping (Result<Bool, Error>) -> ()){
        let postID = originalPost.postID!
        let ref = Database.database().reference().child("PostLikes").child(postID).child(self.userID)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                completion(.success(true))
            } else {
                completion(.success(false))
            }
        }
    }
}

//MARK: - Adding Comments
extension DiscussionViewModel {
    
    func addReply(_ reply: String, attachment: savedWorkoutDelegate?) {
        
        FirebasePostAPI.shared.postReply(to: self.originalPost, with: reply, and: attachment) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(_):
                self.replyAddedClosure?()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func addGroupReply(_ reply: String, attachment: savedWorkoutDelegate?, groupID: String) {
        
        FirebasePostAPI.shared.postGroupReply(to: self.originalPost, with: reply, and: attachment, group: groupID) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(_):
                self.replyAddedClosure?()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
}
