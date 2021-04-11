//
//  MyProfileViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase


class MyProfileViewModel {
    
    // MARK: - Closures
        
    // Through these closures, our view model will execute code while some events will occure
    // They will be set up by the view controller
    
    var reloadTableViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    var showTopViewClosure: (() -> ())?
    
    // MARK: - Properties
    
    // We defined the FakeAPIServiceProtocol in the FakeAPIService.swift file.
    // We also defined a class and make it conform to that protocol.
    let userID = Auth.auth().currentUser!.uid

    
    
    // The collection that will contain our fetched data
    private var posts: [PostProtocol] = [] {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    
    // A property containing the number ot items, it will be used by the view controller to render items on the screen using a
    var numberOfItems: Int {
        return posts.count
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    
    var isTopViewLoading: Bool = false {
        didSet{
            self.showTopViewClosure?()
        }
    }
    
    weak var delegate : MyProfileProtocol?
    
    let collectionData = [
                ["title":"MyGroups",
                "image":UIImage(named: "New Group")!,
                "description":"This will show all of the groups you are a part of."],
                ["title": "Workout Scores",
                 "image": UIImage(named: "scores_icon")!,
                 "description": "View your workout scores. See the scores from all of the workouts you have completed / created."],
                ["title": "Saved Workouts",
                 "image": UIImage(named: "benchpress_icon")!,
                 "description": "View your saved workouts. See all of the workouts you have saved and view all the data including average rpe and average time."],
                ["title": "Created Workouts",
                 "image": UIImage(named: "hammer_icon")!,
                 "description": "View all of the workouts you have created. All the workouts you created are stored in here."],
                ["title": "Notifications",
                 "image": UIImage(named: "bell_icon")!,
                 "description":"View your notifications. Notifications include when another user likes or replies to one of your posts or when another user follows you."],
                ["title": "Edit",
                "image": UIImage(named: "edit_icon")!,
                "description":"View your notifications. Notifications include when another user likes or replies to one of your posts or when another user follows you."],
                ["title": "More",
                 "image": UIImage(named: "more_icon")!,
                 "description":"View your notifications. Notifications include when another user likes or replies to one of your posts or when another user follows you."]
                ] as [[String:AnyObject]]
    
    
    // MARK: - Fetching functions
    func fetchData(){
        self.isLoading = true
        var references:[String] = []
        var initialLoad = true
        let ref = Database.database().reference().child("PostSelfReferences").child(self.userID)
        ref.observe(.childAdded) { (snapshot) in
            references.insert(snapshot.key, at: 0)
            if initialLoad == false{
                // something else
            }
        }
        ref.observeSingleEvent(of: .value) { (_) in
            initialLoad = false
            self.fetchPosts(with: references)
        }
    }
    
    func fetchPosts(with references:[String]){
        
        var tempPosts = [PostProtocol]()
        let postRef = Database.database().reference().child("Posts")
        let myGroup = DispatchGroup()

        
        for ref in references {
            myGroup.enter()
            postRef.child(ref).observeSingleEvent(of: .value) { (snapshot) in
                
                defer{myGroup.leave()}
                guard let snap = snapshot.value as? [String:AnyObject] else{
                    return
                }
                
                switch snap["type"] as! String{
                case "post":
                    tempPosts.append(TimelinePostModel(snapshot: snapshot)!)
                case "createdNewWorkout":
                    tempPosts.append(TimelineCreatedWorkoutModel(snapshot: snapshot)!)
                case "workout":
                    tempPosts.append(TimelineCompletedWorkoutModel(snapshot: snapshot)!)
                default:
                    tempPosts.append(TimelineActivityModel(snapshot: snapshot)!)
                }
            }
            myGroup.notify(queue: .main) {
                self.posts = tempPosts
                self.isLoading = false
            }
        }
        
    }
    
    func followerCount(){
        self.isTopViewLoading = true
        var followers:Int!
        var following:Int!
        let myGroup = DispatchGroup()
        myGroup.enter()
        myGroup.enter()
        
        let followerRef = Database.database().reference().child("Followers").child(userID)
        followerRef.observe(.value) { (snapshot) in
            if snapshot.exists(){
                followers = Int(snapshot.childrenCount)
                myGroup.leave()
            }else{
                followers = 0
                myGroup.leave()
            }
        }
        
        let followingRef = Database.database().reference().child("Following").child(userID)
        followingRef.observe(.value) { (snapshot) in
            if snapshot.exists(){
                following = Int(snapshot.childrenCount)
                myGroup.leave()
            }else{
                following = 0
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main){
            self.delegate?.returnFollowerCounts(followerCount: followers, FollowingCount: following)
            self.isTopViewLoading = false
        }
        
    }
    
    func returnUser(completion: @escaping (Users) -> ()) {
        UserIDToUser.transform(userID: userID) { (user) in
            completion(user)
        }
    }
    
    // MARK: - Actions
    
    func likePost(on post:PostProtocol, with index:IndexPath){
        let postID = post.postID!
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
        self.posts[index.row].likeCount = (post.likeCount ?? 0) + 1
        
        let postLikesRef = Database.database().reference().child("PostLikes").child(postID).child(self.userID)
        postLikesRef.setValue(true)
        let likesRef = Database.database().reference().child("Likes").child(self.userID).child(postID)
        likesRef.setValue(true)
        

    }
    
    // MARK: - Retieve Data
    
    func getData( at indexPath: IndexPath ) -> PostProtocol {
        return posts[indexPath.row]
    }
    
    
}
