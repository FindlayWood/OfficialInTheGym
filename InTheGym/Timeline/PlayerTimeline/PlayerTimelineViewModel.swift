//
//  PlayerTimelineViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import Combine

class PlayerTimelineViewModel {
    
    // MARK: - Publishers
    var thinkingTimeActivePublisher = PassthroughSubject<Bool,Never>()
    
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
    var postPublisher = CurrentValueSubject<[post],Never>([])
    var subscriptions = Set<AnyCancellable>()
    func fetchPosts() {
        FirebaseDatabaseManager.shared.fetch(post.self) { [weak self] result in
            guard let self = self else {return}
            do {
                let posts = try result.get()
                self.filterPosts(posts)
            } catch {
                print(String(describing: error))
            }
        }
    }
    func filterPosts(_ posts: [post]) {
        var postsToShow = [post]()
        let dispatchGroup = DispatchGroup()
        for post in posts {
            dispatchGroup.enter()
            if post.posterID == FirebaseAuthManager.currentlyLoggedInUser.uid {
                postsToShow.append(post)
                dispatchGroup.leave()
            } else {
                timeLineAlgorithm(post) { show in
                    defer { dispatchGroup.leave() }
                    if show { postsToShow.append(post)}
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            postsToShow.sort(by: {$0.time > $1.time})
            self.postPublisher.send(postsToShow)
            self.addPostsToCache(postsToShow)
        }
    }
    func addPostsToCache(_ posts: [post]) {
        let _ = posts.map { PostLoader.shared.add($0) }
    }
    
    struct FollowingCheckModel: FirebaseInstance {
        var id: String
        var internalPath: String {
            return "Following/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(id)"
        }
    }
    
    
    func timeLineAlgorithm(_ post: post, completion: @escaping (Bool) -> Void) {
        let followingModel = FollowingCheckModel(id: post.posterID)
        FirebaseDatabaseManager.shared.checkExistence(of: followingModel) { result in
            do {
                let following = try result.get()
                if following {
                    completion(true)
                } else if !post.isPrivate && post.likeCount > 10 {
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                print(String(describing: error))
                completion(false)
            }

        }
    }
    func setupSubscribers() {
        

            
    }
    
    func check(_ post: post) {
 
    }
 
    // MARK: - Fetching functions


    
    
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
        LikesAPIService.shared.LikedPostsCache[postID] = true
        
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
    
    // MARK: - Thinking Time Check
    func checkForThinkingTime() {
        FirebaseDatabaseManager.shared.fetchSingleModel(ThinkingTimeCheckModel.self) { [weak self] result in
            guard let model = try? result.get() else {return}
            self?.thinkingTimeActivePublisher.send(model.isActive)
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
