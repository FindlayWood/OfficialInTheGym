//
//  GroupPageViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class GroupPageViewModel {
    
    // MARK: - Closures to alert vc when appropriate
    var postsLoadedClosure:(()->())?
    var loadingStatusClosure:(()->())?
    var membersLoadedClosure:(()->())?
    var groupDetailsLoadedClosure:(()->())?
    
    let userID = Auth.auth().currentUser!.uid
    
    var groupPosts : [PostProtocol] = [] {
        didSet{
            self.postsLoadedClosure?()
        }
    }
    
    var groupMembers : [Users] = [] {
        didSet{
            self.membersLoadedClosure?()
        }
    }
    
    var numberOfPosts: Int {
        return groupPosts.count
    }
    
    var numberOfMembers : Int {
        return groupMembers.count
    }
    
    var isLoading: Bool = false {
        didSet{
            self.loadingStatusClosure?()
        }
    }
    
    var groupID:String!
    var groupLeader:String!
    
    init(groupID:String, groupLeader:String){
        self.groupID = groupID
        self.groupLeader = groupLeader
    }
    
    
    //MARK: - Fetching Functions
    
    
    /// this functions fetchs the group's posts and calls the closure when completed
    func fetchGroupPosts(){
        self.isLoading = true
        var tempPosts = [PostProtocol]()
        let ref = Database.database().reference().child("GroupPosts").child(groupID)
        ref.observe(.childAdded) { (snapshot) in
            guard let snap = snapshot.value as? [String:AnyObject] else{
                return
            }
            switch snap["type"] as! String{
            case "post":
                tempPosts.insert(TimelinePostModel(snapshot: snapshot)!, at: 0)
            case "createdNewWorkout":
                tempPosts.insert(TimelineCreatedWorkoutModel(snapshot: snapshot)!, at: 0)
            case "workout":
                tempPosts.insert(TimelineCompletedWorkoutModel(snapshot: snapshot)!, at: 0)
            default:
                break
            }
            
        }
        
        ref.observeSingleEvent(of: .value) { (_) in
            self.groupPosts = tempPosts
            self.isLoading = false
        }
    }
    
    
    /// this functions fetchs the group's members and calls the closure when completed
    func fetchMembers(){
        var members = [Users]()
        let myGroup = DispatchGroup()
        let ref = Database.database().reference().child("GroupMembers").child(groupID)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                myGroup.enter()
                UserIDToUser.transform(userID: (child as AnyObject).key) { (member) in
                    defer {myGroup.leave()}
                    if member.uid! == self.groupLeader{
                        members.insert(member, at: 0)
                    } else {
                        members.append(member)
                    }
                }
            }
            myGroup.notify(queue: .main) {
                self.groupMembers = members
                self.membersLoadedClosure?()
            }
        }
    }
    
    // MARK: - Actions
    func likePost(on post:PostProtocol, with index:IndexPath){
        let postID = post.postID!
        let posterID = post.posterID!
        let postRef = Database.database().reference().child("GroupPosts").child(groupID).child(postID)
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
        self.groupPosts[index.row].likeCount = (post.likeCount ?? 0) + 1
        
        let postLikesRef = Database.database().reference().child("PostLikes").child(postID).child(self.userID)
        postLikesRef.setValue(true)
        let likesRef = Database.database().reference().child("Likes").child(self.userID).child(postID)
        likesRef.setValue(true)
        
        // notification
        if self.userID != posterID{
            let notification = NotificationGroupLikedPost(from: self.userID, to: posterID, postID: postID, groupID: groupID)
            let uploadNotification = NotificationManager(delegate: notification)
            uploadNotification.upload()
        }

    }
    
    // MARK: - VC retreive methods
    
    func getPostData(at indexPath:IndexPath) -> PostProtocol{
        return self.groupPosts[indexPath.row]
    }
    
    func getMemberData(at indexPath:IndexPath) -> Users{
        return self.groupMembers[indexPath.item]
    }
}
