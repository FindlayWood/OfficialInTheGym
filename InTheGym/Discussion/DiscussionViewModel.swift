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
    
    let userID = Auth.auth().currentUser!.uid
    
    var originalPost : PostProtocol!
    
    var replies: [PostProtocol] = [] {
        didSet{
            self.reloadTableViewClosure?()
        }
    }
    
    var numberOfItems: Int {
        return replies.count + 1
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    
    init(originalPost:PostProtocol){
        self.originalPost = originalPost
    }
    
    func fetchData(){
        self.isLoading = true
        var tempReplies = [PostProtocol]()
        
        let ref = Database.database().reference().child("PostReplies").child(originalPost.postID!)
        ref.observe(.childAdded) { (snapshot) in
            tempReplies.append(DiscussionReply(snapshot: snapshot)!)
        }
        ref.observeSingleEvent(of: .value) { (_) in
            self.replies = tempReplies
            self.isLoading = false
        }
        
    }
    
    // MARK: - Retieve Data
    
    func getData( at indexPath: IndexPath ) -> PostProtocol {
        return replies[indexPath.row - 1]
    }
    
    
    // MARK: - Actions
    func likePost(on post:PostProtocol){
        let postID = post.postID!
        let posterID = post.posterID!
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
        
        let postLikesRef = Database.database().reference().child("PostLikes").child(postID).child(self.userID)
        postLikesRef.setValue(true)
        let likesRef = Database.database().reference().child("Likes").child(self.userID).child(postID)
        likesRef.setValue(true)
        
        // notification
        if self.userID != posterID{
            let notification = NotificationLikedPost(from: self.userID, to: posterID, postID: postID)
            let uploadNotification = NotificationManager(delegate: notification)
            uploadNotification.upload()
        }

    }
    
}
