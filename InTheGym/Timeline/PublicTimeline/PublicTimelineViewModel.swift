//
//  PublicTimelineViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class PublicTimelineViewModel {
    
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

    // This will contain info about the picture eventually selectded by the user by tapping an item on the screen
    var selectedPost: PostProtocol?
    
    // The collection that will contain our fetched data
    private var posts: [PostProtocol] = [] {
        didSet {
            if !tableLoaded{
                self.reloadTableViewClosure?()
                tableLoaded = true
            }            
        }
    }
    
    private var tableLoaded : Bool = false
    
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
    
    // the user to view, passed from init
    var user : Users!
    
    var following : Bool? {
        didSet{
            self.fetchData()
        }
    }
    
    weak var delegate : PublicTimelineProtocol?
    
    // MARK: - Constructor
    
    // Note: apiService has a default value in case this constructor is executed without passing parameters
    init(user: Users) {
        self.user = user
    }
    
 
    // MARK: - Fetching functions
    
    func followerCount(){
        self.isTopViewLoading = true
        var followers:Int!
        var following:Int!
        let myGroup = DispatchGroup()
        myGroup.enter()
        myGroup.enter()
        
        let followerRef = Database.database().reference().child("Followers").child(user.uid!)
        followerRef.observe(.value) { (snapshot) in
            if snapshot.exists(){
                followers = Int(snapshot.childrenCount)
                myGroup.leave()
            }else{
                followers = 0
                myGroup.leave()
            }
        }
        
        let followingRef = Database.database().reference().child("Following").child(user.uid!)
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
    
    func isFollowing(){
        self.isLoading = true
        
        let ref = Database.database().reference().child("Following").child(self.userID).child(user.uid!)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                self.following = true
                self.delegate?.returnIsFollowing(following: true)
            }else{
                self.following = false
                self.delegate?.returnIsFollowing(following: false)
            }
        }
    }
    
    
    func fetchData(){

        var references:[String] = []
        var initialLoad = true
        // first get references from timeline - which will be just postID
        let apiService = Database.database().reference().child("PostSelfReferences").child(user.uid!)
        apiService.observe(.childAdded) { (snapshot) in
            references.insert(snapshot.key, at: 0)
            if initialLoad == false{
                
            }
        }
        apiService.observeSingleEvent(of: .value) { (_) in
            //load timeline with references
            self.fetchPosts(with: references)
            initialLoad = true
        }
        
    }
    
    func fetchPosts(with references:[String]){
        
        var tempPosts = [PostProtocol]()
        let postRef = Database.database().reference().child("Posts")
        let myGroup = DispatchGroup()
        var initialLoad = true
        
        for post in references{
            myGroup.enter()
            postRef.child(post).observe(.value) { (snapshot) in
                
                guard let snap = snapshot.value as? [String:AnyObject] else{
                    return
                }
                
                if initialLoad{
                    defer {myGroup.leave()}
                    if self.user.uid! == self.userID{
                        switch snap["type"] as! String{
                        case "post":
                            tempPosts.append(TimelinePostModel(snapshot: snapshot)!)
                        case "createdNewWorkout":
                            tempPosts.append(TimelineCreatedWorkoutModel(snapshot: snapshot)!)
                        case "workout":
                            tempPosts.append(TimelineCompletedWorkoutModel(snapshot: snapshot)!)
                        default:
                            break
                        }
                    }else if self.following == true{
                        switch snap["type"] as! String{
                        case "post":
                            tempPosts.append(TimelinePostModel(snapshot: snapshot)!)
                        case "createdNewWorkout":
                            tempPosts.append(TimelineCreatedWorkoutModel(snapshot: snapshot)!)
                        case "workout":
                            tempPosts.append(TimelineCompletedWorkoutModel(snapshot: snapshot)!)
                        default:
                            break
                        }
                    }else if snap["isPrivate"] as? Bool == false{
                        switch snap["type"] as! String{
                        case "post":
                            tempPosts.append(TimelinePostModel(snapshot: snapshot)!)
                        case "createdNewWorkout":
                            tempPosts.append(TimelineCreatedWorkoutModel(snapshot: snapshot)!)
                        case "workout":
                            tempPosts.append(TimelineCompletedWorkoutModel(snapshot: snapshot)!)
                        default:
                            break
                        }
                    }
                } else {
                    var post : PostProtocol!
                    switch snap["type"] as! String {
                    case "post":
                        post = TimelinePostModel(snapshot: snapshot)
                    case "createdNewWorkout":
                        post = TimelineCreatedWorkoutModel(snapshot: snapshot)
                    case "workout":
                        post = TimelineCompletedWorkoutModel(snapshot: snapshot)
                    default:
                        break
                    }
                    let index = self.posts.firstIndex(where: { $0.postID == post.postID})
                    self.posts[index!] = post
                    self.delegate?.reloadTableviewRow(at: IndexPath(row: index!, section: 0))
                    
                }
            }
        }
        myGroup.notify(queue: .main){
            self.posts = tempPosts
            self.isLoading = false
            initialLoad = false
        }
        
    }
    
    func insertPost(with postID:String){
        let postRef = Database.database().reference().child("Posts").child(postID)
        postRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let snap = snapshot.value as? [String:AnyObject] else{
                return
            }
            var post:PostProtocol!
            switch snap["type"] as! String{
            case "post":
                post = TimelinePostModel(snapshot: snapshot)
            case "createdNewWorkout":
                post = TimelineCreatedWorkoutModel(snapshot: snapshot)
            case "workout":
                post = TimelineCompletedWorkoutModel(snapshot: snapshot)
            default:
                break
            }
            self.posts.insert(post, at: 0)
            self.delegate?.newPosts()
            
        }
    }
    
    // MARK: - Retieve Data
    
    func getData( at indexPath: IndexPath ) -> PostProtocol {
        return posts[indexPath.row]
    }
    
    
    // MARK: - Actions
    func follow(){
        let ref = Database.database().reference().child("Following").child(self.userID).child(user.uid!)
        ref.setValue(true)
        let otherRef = Database.database().reference().child("Followers").child(user.uid!).child(self.userID)
        otherRef.setValue(true)
    }
    
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
