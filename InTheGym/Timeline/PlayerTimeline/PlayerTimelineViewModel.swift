//
//  PlayerTimelineViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class PlayerTimelineViewModel {
    
    // MARK: - Closures
        
    // Through these closures, our view model will execute code while some events will occure
    // They will be set up by the view controller
    
    var reloadTableViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    var newPostsLoadedClosure: (() -> ())?
    var tableViewReloadedClosure: (() -> ())?
    var notificationAlert: (() -> ())?
    
    
    
    // MARK: - Properties
    
    // We defined the FakeAPIServiceProtocol in the FakeAPIService.swift file.
    // We also defined a class and make it conform to that protocol.
    static var apiService: DatabaseReference!
    static var handle : DatabaseHandle!
    let userID = Auth.auth().currentUser!.uid

    // This will contain info about the picture eventually selectded by the user by tapping an item on the screen
    var selectedNotifications: PostProtocol?
    
    // The collection that will contain our fetched data
    var posts: [PostProtocol] = [] {
        didSet {
            if !tableLoaded{
                self.reloadTableViewClosure?()
            }
        }
    }
    
    private var tableLoaded : Bool = false
    
    // The collection that contains new posts that need to be loaded in to the timeline
    var newPosts : [PostProtocol] = [] {
        didSet {
            self.newPostsLoadedClosure?()
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
    
    var isRefreshing : Bool = false {
        didSet {
            posts.sort(by: { $0.time! > $1.time! })
            self.tableViewReloadedClosure?()
        }
    }
    
    weak var delegate : PlayerTimelineProtocol?
    
    //MARK: - Initialiser
    init(){
        PlayerTimelineViewModel.apiService = Database.database().reference().child("Timeline").child(userID)
    }
 
    // MARK: - Fetching functions
    func fetchData(){
        if !tableLoaded{
            self.isLoading = true
        } else {
            self.isRefreshing = true
        }
        let myGroup = DispatchGroup()
        var tempPosts = [PostProtocol]()
        let ref = Database.database().reference().child("Posts").queryLimited(toLast: 1000)
        ref.observeSingleEvent(of: .value) { snapshot in
            print(snapshot.childrenCount)
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                myGroup.enter()
                guard let post = child.value as? [String: AnyObject] else {return}
                if let posterID = post["posterID"] as? String {
                    if posterID != FirebaseAuthManager.currentlyLoggedInUser.uid {
                        FirebaseCheckFollowing.shared.check(posterID) { following in
                            if following {
                                switch post["type"] as! String{
                                case "post":
                                    tempPosts.append(TimelinePostModel(snapshot: child)!)
                                case "createdNewWorkout":
                                    tempPosts.append(TimelineCreatedWorkoutModel(snapshot: child)!)
                                case "workout":
                                    tempPosts.append(TimelineCompletedWorkoutModel(snapshot: child)!)
                                default:
                                    tempPosts.append(TimelineActivityModel(snapshot: child)!)
                                }
                                myGroup.leave()
                            } else {
                                myGroup.leave()
                            }
                        }
                    } else {
                        switch post["type"] as! String{
                        case "post":
                            tempPosts.append(TimelinePostModel(snapshot: child)!)
                        case "createdNewWorkout":
                            tempPosts.append(TimelineCreatedWorkoutModel(snapshot: child)!)
                        case "workout":
                            tempPosts.append(TimelineCompletedWorkoutModel(snapshot: child)!)
                        default:
                            tempPosts.append(TimelineActivityModel(snapshot: child)!)
                        }
                        myGroup.leave()
                    }
                } else {
                    myGroup.leave()
                    continue
                }
            }
            myGroup.notify(queue: .main) {
                self.posts = tempPosts.sorted(by: { $0.time! > $1.time! })
                if !self.tableLoaded{
                    self.isLoading = false
                    self.tableLoaded = true
                } else {
                    self.isRefreshing = false
                }

            }
        }

        
//        if !tableLoaded{
//            self.isLoading = true
//        } else {
//            self.isRefreshing = true
//        }
//
//        var initialLoad = true
//
//        var references:[String] = []
//        // first get references from timeline - which will be just postID
//        PlayerTimelineViewModel.handle = PlayerTimelineViewModel.apiService.queryLimited(toLast: 200).observe(.childAdded) { (snapshot) in
//            if initialLoad == false{
//                //add new posts
//                self.loadNewPost(with: snapshot.key)
//                //self.newPostsLoadedClosure?()
//            } else {
//                references.insert(snapshot.key, at: 0)
//            }
//        }
//        PlayerTimelineViewModel.apiService.observeSingleEvent(of: .value) { (_) in
//            //load timeline with references
//            self.fetchPosts(with: references)
//            initialLoad = false
//        }
        
        
    }
    
    func fetchPosts(with references:[String]){
        
        var tempPosts = [PostProtocol]()
        let postRef = Database.database().reference().child("Posts")
        let myGroup = DispatchGroup()

        
        
        for post in references{
            myGroup.enter()
            postRef.child(post).observeSingleEvent(of: .value) { (snapshot) in
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
        }
        myGroup.notify(queue: .main){
            self.posts = tempPosts
            if !self.tableLoaded{
                self.isLoading = false
                self.tableLoaded = true
            } else {
                self.isRefreshing = false
            }
            
        }
        
    }
    
    
    // MARK: - Observing Functions
    func loadNewPost(with postID:String){
        let newRef = Database.database().reference().child("Posts").child(postID)
        newRef.observeSingleEvent(of: .value) { (snapshot) in
            
            guard let snap = snapshot.value as? [String:AnyObject] else{
                return
            }

            let posterID = snap["posterID"] as? String
            
            if posterID != self.userID {
                self.newPostsLoadedClosure?()
            } 
        }
    }
    
    // MARK: - Actions
    func addNewPosts() -> [IndexPath]{
        
        let newIndexPaths = (0..<newPosts.count).map { i in
            return IndexPath(row: i, section: 0)
        }
        self.posts.insert(contentsOf: self.newPosts, at: 0)
        self.newPosts.removeAll()
        return newIndexPaths
    }
    
    func likePost(on post:PostProtocol, with index:IndexPath){
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
        self.posts[index.row].likeCount = (post.likeCount ?? 0) + 1
        
        let postLikesRef = Database.database().reference().child("PostLikes").child(postID).child(self.userID)
        postLikesRef.setValue(true)
        let likesRef = Database.database().reference().child("Likes").child(self.userID).child(postID)
        likesRef.setValue(true)
        LikesAPIService.shared.LikedPostsCache.removeObject(forKey: postID as NSString)
        LikesAPIService.shared.LikedPostsCache.setObject(1, forKey: postID as NSString)
        
        // notification
        if self.userID != posterID{
            let notification = NotificationLikedPost(from: self.userID, to: posterID, postID: postID)
            let uploadNotification = NotificationManager(delegate: notification)
            uploadNotification.upload { _ in
                
            }
        }

    }
    
    // MARK: - Retieve Data
    
    func getData( at indexPath: IndexPath ) -> PostProtocol {
        return posts[indexPath.row]
    }
    
    func isLiked(on post:String, completion: @escaping (Result<Bool, Error>) -> ()){
        let ref = Database.database().reference().child("Likes").child(self.userID).child(post)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                completion(.success(true))
            } else {
                completion(.success(false))
            }
        }
    }
    
    
    
    
    // MARK: - Check for Notifications
    func checkForNotifications(){
        let ref = Database.database().reference().child("Notifications").child(self.userID).queryLimited(toLast: 1)
        ref.observe(.childAdded) { (snapshot) in
            guard let snap = snapshot.value as? [String:AnyObject] else {
                return
            }
            if snap["seen"] as? Bool ?? true == false {
                //call notificationcenter to add badge icon
                NotificationCenter.default.post(name: .unseenNotification, object: nil)
            }
            
        }
    }
    
    
    
}

extension Notification.Name {
    static let unseenNotification = Notification.Name("unseenNotification")
    static let seenAllNotifications = Notification.Name("seenAllNotifications")
}