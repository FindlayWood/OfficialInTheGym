////
////  DatabaseManager.swift
////  InTheGym
////
////  Created by Findlay Wood on 29/03/2021.
////  Copyright © 2021 FindlayWood. All rights reserved.
////
//
//import Foundation
//import Firebase
//import CodableFirebase
//
//class FirebaseAPI {
//    
//    private static var privateShared: FirebaseAPI?
//    private let userID = Auth.auth().currentUser?.uid
//    static var currentUserID = String()
//    private var ref: DatabaseReference = Database.database().reference()
//    
//    
//    private init(){}
//    
//    static func shared() -> FirebaseAPI {
//        guard let privateShared = FirebaseAPI.privateShared else {
//            FirebaseAPI.privateShared = FirebaseAPI()
//            return FirebaseAPI.privateShared!
//        }
//        return privateShared
//    }
//
//    func dispose(){
//        FirebaseAPI.privateShared = nil
//    }
//    deinit {
//        // remove observers on timeline
//        // remove observers on players
//        
//    }
//    
//    // MARK: - MyProfile Timeline
//    func loadProfileTimelineReferences(from path:String, completion: @escaping (Result<[PostProtocol], Error>) -> Void) {
//        var postReferences = [String]()
//        ref.child("\(path)/\(self.userID!)").observeSingleEvent(of: .value) { snapshot in
//            for child in snapshot.children{
//                postReferences.insert((child as AnyObject).key, at: 0)
//            }
//            self.loadProfileTimelinePosts(from: postReferences, completion: completion)
//        }
//    }
//    private func loadProfileTimelinePosts(from references: [String], completion: @escaping (Result<[PostProtocol], Error>) -> Void) {
//        var tempPosts = [PostProtocol]()
//        let myGroup = DispatchGroup()
//        for reference in references {
//            myGroup.enter()
//            ref.child("Posts").child(reference).observeSingleEvent(of: .value) { (snapshot) in
//                defer{myGroup.leave()}
//                if let post = self.configurePost(from: snapshot) {
//                    tempPosts.append(post)
//                }
//            }
//        }
//        myGroup.notify(queue: .main) {
//            completion(.success(tempPosts))
//        }
//    }
//    
//    /// configures a snapshot to the right type of post
//    /// - Parameters:
//    ///   - snapshot: the snapshot from firebase
//    ///   - following: is the current user following the given user
//    /// - Returns: returns a model that conforms to PostProtocol or nil
//    private func configurePost(from snapshot:DataSnapshot) -> PostProtocol? {
//        guard let snap = snapshot.value as? [String:AnyObject] else {
//            return nil
//        }
//        switch snap["type"] as! String{
//        case "post":
//            return TimelinePostModel(snapshot: snapshot)!
//        case "createdNewWorkout":
//            return TimelineCreatedWorkoutModel(snapshot: snapshot)!
//        case "workout":
//            return TimelineCompletedWorkoutModel(snapshot: snapshot)!
//        default:
//            return TimelineActivityModel(snapshot: snapshot)!
//        }
//    }
//    
//    // MARK: - Public Timeline
//    
//    
//    /// load public timeline references for given userID
//    /// - Parameters:
//    ///   - user: the userID of the user timeline
//    ///   - following: is current user follwing given user
//    ///   - completion: returning array of posts or error
//    func loadPublicTimelineReferences(for user:String, isFollowing following: Bool, completion: @escaping (Result<[PostProtocol], Error>) -> Void ) {
//        var tempReferences = [String]()
//        ref.child("PostSelfReferences").child(user).observeSingleEvent(of: .value) { (snapshot) in
//            for child in snapshot.children {
//                tempReferences.insert((child as AnyObject).key, at: 0)
//            }
//            self.loadPublicTimelinePosts(with: tempReferences, isFollowing: following, completion: completion)
//        }
//    }
//    
//    
//    /// loads posts from given references for a public timeline
//    /// - Parameters:
//    ///   - references: array of post IDs to load
//    ///   - following: is current user following given user
//    ///   - completion: returning array of posts or error
//    private func loadPublicTimelinePosts(with references:[String], isFollowing following:Bool, completion: @escaping (Result<[PostProtocol], Error>) -> Void ) {
//        var tempPosts = [PostProtocol]()
//        let myGroup = DispatchGroup()
//        for reference in references {
//            myGroup.enter()
//            ref.child("Posts").child(reference).observeSingleEvent(of: .value) { (snapshot) in
//                defer{myGroup.leave()}
//                if let post = self.configurePublicPost(from: snapshot, isFollowing: following) {
//                    tempPosts.append(post)
//                }
//            }
//        }
//        myGroup.notify(queue: .main) {
//            completion(.success(tempPosts))
//        }
//    }
//    
//    
//    /// configures a snapshot to the right type of post
//    /// - Parameters:
//    ///   - snapshot: the snapshot from firebase
//    ///   - following: is the current user following the given user
//    /// - Returns: returns a model that conforms to PstProtocol or nil
//    private func configurePublicPost(from snapshot:DataSnapshot, isFollowing following:Bool) -> PostProtocol? {
//        guard let snap = snapshot.value as? [String:AnyObject] else {
//            return nil
//        }
//        
//        if following || snap["isPrivate"] as? Bool ?? true == false {
//            switch snap["type"] as! String{
//            case "post":
//                return TimelinePostModel(snapshot: snapshot)!
//            case "createdNewWorkout":
//                return TimelineCreatedWorkoutModel(snapshot: snapshot)!
//            case "workout":
//                return TimelineCompletedWorkoutModel(snapshot: snapshot)!
//            default:
//                return TimelineActivityModel(snapshot: snapshot)!
//            }
//        } else {
//            return nil
//        }
//    }
//    
//    // MARK: - Returning Generic Codable Type
//    
//    
//    /// generic function for returning a model from the database - the model must be codable and this is called through the database endpoint enum
//    /// - Parameters:
//    ///   - path: the path in the database of where to load the data
//    ///   - expectingReturnType: the type of model that the function will return - this is set when the method is called whereever it is needed
//    ///   - completion: escaping with an array of the correct model type or an error
//    func retreive<T:Codable>(from path:String, expectingReturnType: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
//        var userIDs = [String]()
//        ref.child(path).observeSingleEvent(of: .value) { (snapshot) in
//            for child in snapshot.children{
//                userIDs.append((child as AnyObject).key)
//            }
//            self.loadRetreive(from: userIDs, expectingReturnType: expectingReturnType, completion: completion)
//        }
//    }
//    
//    
//    /// transforming referecnes into model type
//    /// - Parameters:
//    ///   - references: array of references of the data to b loaded
//    ///   - expectingReturnType: the type of model that the function will return - this must be codable
//    ///   - completion: escaping with an array of the correct model type or an error
//    func loadRetreive<T:Codable>(from references: [String], expectingReturnType: T.Type, completion: @escaping (Result<[T],Error>) -> Void) {
//        let myGroup = DispatchGroup()
//        var tempModel = [T]()
//        for userID in references{
//            myGroup.enter()
//            ref.child("users/\(userID)").observeSingleEvent(of: .value) { snapshot in
//                defer { myGroup.leave() }
//                guard let snap = snapshot.value as? [String:AnyObject] else {
//                    return
//                }
//                do {
//                    let decodedResult = try FirebaseDecoder().decode(T.self, from: snap)
//                    tempModel.append(decodedResult)
//                }
//                catch let error {
//                    completion(.failure(error))
//                }
//            }
//        }
//        myGroup.notify(queue: .main) {
//            completion(.success(tempModel))
//        }
//    }
//    
//    func timeline(completion: @escaping ([PostProtocol]) -> Void) {
//        var posts = [PostProtocol]()
//        ref.child("Posts").queryLimited(toLast: 10).observe(.childAdded) { snapshot in
//            
//            guard let post: PostProtocol = self.configurePost(from: snapshot) else {return}
//            self.timelineAlgorithm(post: post) { add in
//                if add {
//                    posts.insert(post, at: 0)
//                }
//            }
//        }
//        ref.child("Posts").observeSingleEvent(of: .value) { _ in
//            completion(posts)
//        }
//    }
//    
//    private func timelineAlgorithm(post: PostProtocol, completion: @escaping (Bool) -> Void) {
//        let likes = post.likeCount ?? 0, replies = post.replyCount ?? 0
//        let id = post.posterID!
//        if id == self.userID{
//            completion(true)
//        }else if (likes > 10 || replies > 5) && post.isPrivate == false {
//            completion(true)
//        } else {
//            isFollowing(post: post) { following in
//                if following {
//                    completion(true)
//                } else {
//                    completion(false)
//                }
//            }
//        }
//    }
//    
//    private func isFollowing(post: PostProtocol, completion: @escaping (Bool) -> Void) {
//        guard let followerID = post.posterID else {return}
//        FollowingAPIService.shared.get(followerID: followerID) { following in
//            if following{
//                completion(true)
//            } else {
//                completion(false)
//            }
//        }
//    }
//    
//    
//    
//    
//
//    
//    
//    func uploadActivity(with type:ActivityType){
//        let activityRef = Database.database().reference().child("Activities").child(self.userID!).childByAutoId()
//        var activityData = ["time":ServerValue.timestamp(),
//                            "isPrivate":true] as [String:AnyObject]
//        switch type {
//        case .AccountCreated:
//            activityData["type"] = "Account Created" as AnyObject
//            activityData["message"] = "You created your account." as AnyObject
//        case .RequestSent(let player):
//            activityData["type"] = "Request Sent" as AnyObject
//            activityData["message"] = "You sent a request to \(player)." as AnyObject
//        case .RequestAccepted(let player, let coachID):
//            activityData["type"] = "Request Accepted" as AnyObject
//            activityData["message"] = "\(player) accepted your request." as AnyObject
//            let ref = Database.database().reference().child("Activities").child(coachID).childByAutoId()
//            ref.setValue(activityData)
//            return
//        case .NewCoach(let coach):
//            activityData["type"] = "New Coach" as AnyObject
//            activityData["message"] = "You accepted a request from \(coach)." as AnyObject
//        case .CreatedWorkout(let workoutTitle):
//            activityData["type"] = "Created Workout" as AnyObject
//            activityData["message"] = "You created a new workout \(workoutTitle)." as AnyObject
//        case .CompletedWorkout(let workoutTitle):
//            activityData["type"] = "Workout Completed" as AnyObject
//            activityData["message"] = "You completed the workout \(workoutTitle)." as AnyObject
//        case .UpdatePBs:
//            activityData["type"] = "Update PBs" as AnyObject
//            activityData["message"] = "You updated your PBs." as AnyObject
//        case .SetWorkout(let player):
//            activityData["type"] = "Set Workout" as AnyObject
//            activityData["message"] = "You set a workout for \(player)." as AnyObject
//        case .StartedFollowing(let following):
//            activityData["type"] = "Started Following" as AnyObject
//            activityData["message"] = "You started following \(following)." as AnyObject
//        }
//        
//        activityRef.setValue(activityData)
//        
//    }
//}
//
//enum ActivityType {
//    case AccountCreated
//    case RequestSent(String)
//    case RequestAccepted(String, String)
//    case NewCoach(String)
//    case CreatedWorkout(String)
//    case CompletedWorkout(String)
//    case UpdatePBs
//    case SetWorkout(String)
//    case StartedFollowing(String)
//}
//
//enum PostType {
//    case post(String)
//    case createdNewWorkout(workout)
//    case completedWorkout(workout)
//}
