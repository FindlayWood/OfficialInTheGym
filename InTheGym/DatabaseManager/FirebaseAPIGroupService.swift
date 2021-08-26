//
//  FirebaseAPIGroupService.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

protocol FirebaseAPIGroupServiceProtocol {
    func createGroup(with data: NewGroupModel, completion: @escaping (Bool) -> Void)
    func loadMembers(from group: MoreGroupInfoModel, completion: @escaping (Result<[Users], Error>) -> Void)
    func loadLeader(from group: MoreGroupInfoModel, completion: @escaping (Result<Users, Error>) -> Void)
    func saveNewGroupInfo(from group: MoreGroupInfoModel, completion: @escaping (Bool) -> Void)
    func fetchGroupWorkouts(from groupID: String, completion: @escaping (Result<[GroupWorkoutModel], Error>) -> Void)
}

class FirebaseAPIGroupService: FirebaseAPIGroupServiceProtocol {
    static let shared = FirebaseAPIGroupService()
    private init() {}
    private var baseRef: DatabaseReference = Database.database().reference()
    
    
    // MARK: - Create Group
    func createGroup(with data: NewGroupModel, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {return}

        let groupRef = baseRef.child("Groups").childByAutoId()
        let groupID = groupRef.key!
        
        let newGroupData = ["username": data.title,
                            "description": data.description,
                            "leader": userID,
                            "uid": groupID] as [String: Any]
        
        var updatedGroupData: [String: Any] = [:]

        
        var membersData: [String: Bool] = [:]
        membersData[userID] = true
        updatedGroupData["GroupsReferences/\(userID)/\(groupID)"] = true
        
        for player in data.players {
            let playerID = player.uid
            membersData[playerID] = true
            updatedGroupData["GroupsReferences/\(playerID)/\(groupID)"] = true
        }
        
        updatedGroupData["Groups/\(groupID)"] = newGroupData
        updatedGroupData["GroupMembers/\(groupID)"] = membersData
        updatedGroupData["GroupsLeaderReferences/\(userID)/\(groupID)"] = true
        
        baseRef.updateChildValues(updatedGroupData) { error, ref in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // MARK: - Load Posts
    func loadPosts(from groupID: String, completion: @escaping (Result<[PostProtocol], Error>) -> Void) {
        let path = "GroupPosts/\(groupID)"
        //var handle: DatabaseHandle!
        let groupPostRef = baseRef.child(path)
        var tempPosts: [PostProtocol] = []
        groupPostRef.observe(.childAdded, with: { snapshot in
            guard let snap = snapshot.value as? [String: AnyObject] else {return}
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
            
        }, withCancel: { error in
            completion(.failure(error))
        })
        
        groupPostRef.observeSingleEvent(of: .value) { (_) in
            completion(.success(tempPosts))
        }
    }
    
    // MARK: - Trying the updated version of posts
    func loadPostsUpdated(from groupID: String, completion: @escaping (Result<[post], Error>) -> Void) {
        let path = "GroupPosts/\(groupID)"
        let groupPostRef  = baseRef.child(path)
        var tempPosts = [post]()
        groupPostRef.observe(.childAdded) { snapshot in
            guard let snap = snapshot.value as? [String:AnyObject] else {return}
            do {
                let post = try FirebaseDecoder().decode(post.self, from: snap)
                tempPosts.append(post)
            }
            catch {
                print(error.localizedDescription)
            }
        } withCancel: { error in
            completion(.failure(error))
        }
        
        groupPostRef.observeSingleEvent(of: .value) { _ in
            completion(.success(tempPosts))
        }

    }
    
    func loadGroupMemberCount(from groupID: String, completion: @escaping (Result<Int, Error>) -> Void) {
        let path = "GroupMembers/\(groupID)"
        let groupMembersRef = baseRef.child(path)
        
        groupMembersRef.observeSingleEvent(of: .value) { snapshot in
            completion(.success(Int(snapshot.childrenCount)))
        } withCancel: { error in
            completion(.failure(error))
        }
    }
    
    func loadMembers(from group: MoreGroupInfoModel, completion: @escaping (Result<[Users], Error>) -> Void) {
        guard let groupID = group.groupID,
              let leaderID = group.leaderID
        else {
            completion(.failure(NSError.init(domain: "GroupInfoError", code: 0, userInfo: nil)))
            return
        }
        
        let path = "GroupMembers/\(groupID)"
        let groupMembersRef = baseRef.child(path)
        
        var members = [Users]()
        let myGroup = DispatchGroup()
        groupMembersRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                myGroup.enter()
                UserIDToUser.transform(userID: (child as AnyObject).key) { (member) in
                    defer {myGroup.leave()}
                    if member.uid != leaderID {
                        members.append(member)
                    }
                }
            }
            myGroup.notify(queue: .main) {
                completion(.success(members))
            }
        }
    }
    
    func loadLeader(from group: MoreGroupInfoModel, completion: @escaping (Result<Users, Error>) -> Void) {
        guard let leaderID = group.leaderID
        else {
            completion(.failure(NSError(domain: "NoLeaderID", code: 0, userInfo: nil)))
            return
        }
        UserIDToUser.transform(userID: leaderID) { leader in
            completion(.success(leader))
        }
    }
    
    func saveNewGroupInfo(from group: MoreGroupInfoModel, completion: @escaping (Bool) -> Void) {
        guard let name = group.groupName,
              let description = group.description,
              let groupID = group.groupID
        else {
            completion(false)
            return
        }
        let basePath = "Groups/\(groupID)"
        let groupUpdateRef = baseRef.child(basePath)
        let titlePath = "title"
        let descriptionPath = "description"
        let updatedData = [titlePath: name,
                           descriptionPath: description]
        groupUpdateRef.updateChildValues(updatedData) { error, ref in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                if group.headerImage != nil {
                    self.updateGroupImage(from: group, completion: completion)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func updateGroupImage(from group: MoreGroupInfoModel, completion: @escaping (Bool) -> Void) {
        guard let newImage = group.headerImage,
              let groupID = group.groupID
        else {
            completion(false)
            return
        }
        
        guard let imageData = newImage.jpegData(compressionQuality: 0.4) else {
            completion(false)
            return
        }
        
        let storageRef = Storage.storage().reference()
        let storageProfileRef = storageRef.child("ProfilePhotos").child(groupID)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageProfileRef.putData(imageData, metadata: metaData) { (storage, error) in
            if let error = error{
                print(error.localizedDescription as Any)
                completion(false)
                return
            } else {
                ImageAPIService.shared.profileImageCache.removeObject(forKey: groupID as NSString)
                ImageAPIService.shared.profileImageCache.setObject(newImage, forKey: groupID as NSString)
                completion(true)
            }
        }
    }
    
    // MARK: Like Group Posts
    func likeGroupPost(from groupID: String, post: PostProtocol, completion: @escaping (Bool) -> Void) {
        /// transaction block to update likecount
        guard let postID = post.postID else {
            completion(false)
            return
        }
        let transactionPath = "GroupPosts/\(groupID)/\(postID)"
        let postRef = baseRef.child(transactionPath)
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
                completion(false)
            } else {
                self.updateLikes(from: postID, completion: completion)
                self.sendNotification(from: post, on: groupID)
            }
        }
        
    }
    func updateLikes(from postID: String, completion: @escaping (Bool) -> Void) {
        /// multi path update - post likes / likes
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let postLikePath = "PostLikes/\(postID)/\(userID)"
        let likesPath = "Likes/\(userID)/\(postID)"
        
        let updatedPaths = [postLikePath: true,
                            likesPath: true]
        baseRef.updateChildValues(updatedPaths) { error, ref in
            if error != nil {
                completion(false)
            } else {
                LikesAPIService.shared.LikedPostsCache.removeObject(forKey: postID as NSString)
                LikesAPIService.shared.LikedPostsCache.setObject(1, forKey: postID as NSString)
                completion(true)
            }
        }
    }
    func sendNotification(from post: PostProtocol, on groupID: String) {
        guard let userID = Auth.auth().currentUser?.uid,
              let postID = post.postID,
              let posterID = post.posterID
        else {
            return
        }
        if userID != posterID{
            let notification = NotificationGroupLikedPost(from: userID, to: posterID, postID: postID, groupID: groupID)
            let uploadNotification = NotificationManager(delegate: notification)
            uploadNotification.upload { _ in
                
            }
        }
    }
    func isLiked(from groupID: String, postID: String, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let path = "PostLikes/\(postID)/\(userID)"
        let likedRef = baseRef.child(path)
        likedRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: Group Workouts
    func fetchGroupWorkouts(from groupID: String, completion: @escaping (Result<[GroupWorkoutModel], Error>) -> Void) {
        let path = "GroupWorkouts/\(groupID)"
        let ref = baseRef.child(path)
        var workouts: [GroupWorkoutModel] = []
        
        ref.observe(.childAdded) { snapshot in
            workouts.append(GroupWorkoutModel(snapshot: snapshot)!)
        } withCancel: { error in
            completion(.failure(error))
        }

        ref.observeSingleEvent(of: .value) { _ in
            completion(.success(workouts))
        } withCancel: { error in
            completion(.failure(error))
        }
    }
}


