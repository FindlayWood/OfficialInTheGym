//
//  DatabaseManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class FirebaseAPI {
    
    private static var privateShared : FirebaseAPI?
    private let userID = Auth.auth().currentUser?.uid
    static var currentUserID = String()
    private var ref : DatabaseReference = Database.database().reference()
    
    
    private init(){}
    
    static func shared() -> FirebaseAPI {
        guard let privateShared = FirebaseAPI.privateShared else {
            FirebaseAPI.privateShared = FirebaseAPI()
            return FirebaseAPI.privateShared!
        }
        return privateShared
    }

    func dispose(){
        FirebaseAPI.privateShared = nil
    }
    deinit {
        // remove observers on timeline
        // remove observers on players
        
    }
    
    // MARK: - Public Timeline
    
    
    /// load public timeline references for given userID
    /// - Parameters:
    ///   - user: the userID of the user timeline
    ///   - following: is current user follwing given user
    ///   - completion: returning array of posts or error
    func loadPublicTimelineReferences(for user:String, isFollowing following: Bool, completion: @escaping (Result<[PostProtocol], Error>) -> Void ) {
        var tempReferences = [String]()
        ref.child("PostSelfReferences").child(user).observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                tempReferences.insert((child as AnyObject).key, at: 0)
            }
            self.loadPublicTimelinePosts(with: tempReferences, isFollowing: following, completion: completion)
        }
    }
    
    
    /// loads posts from given references for a public timeline
    /// - Parameters:
    ///   - references: array of post IDs to load
    ///   - following: is current user following given user
    ///   - completion: returning array of posts or error
    private func loadPublicTimelinePosts(with references:[String], isFollowing following:Bool, completion: @escaping (Result<[PostProtocol], Error>) -> Void ) {
        var tempPosts = [PostProtocol]()
        let myGroup = DispatchGroup()
        for reference in references {
            myGroup.enter()
            ref.child("Posts").child(reference).observeSingleEvent(of: .value) { (snapshot) in
                defer{myGroup.leave()}
                if let post = self.configurePublicPost(from: snapshot, isFollowing: following) {
                    tempPosts.append(post)
                }
            }
        }
        myGroup.notify(queue: .main) {
            completion(.success(tempPosts))
        }
    }
    
    
    /// configures a snapshot to the right type of post
    /// - Parameters:
    ///   - snapshot: the snapshot from firebase
    ///   - following: is the current user following the given user
    /// - Returns: returns a model that conforms to PstProtocol or nil
    private func configurePublicPost(from snapshot:DataSnapshot, isFollowing following:Bool) -> PostProtocol? {
        guard let snap = snapshot.value as? [String:AnyObject] else {
            return nil
        }
        
        if following || snap["isPrivate"] as? Bool ?? true == false {
            switch snap["type"] as! String{
            case "post":
                return TimelinePostModel(snapshot: snapshot)!
            case "createdNewWorkout":
                return TimelineCreatedWorkoutModel(snapshot: snapshot)!
            case "workout":
                return TimelineCompletedWorkoutModel(snapshot: snapshot)!
            default:
                return TimelineActivityModel(snapshot: snapshot)!
            }
        } else {
            return nil
        }
    }
    
    // MARK: - Created Workouts
    func getCreatedWorkouts(for user:String, completion: @escaping (Result<[CreatedWorkoutDelegate], Error>) -> () ) {
        
        ref.child("SavedWorkoutCreators").child(user).observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children{
                
            }
        }
    }
    
    private func loadCreatedWorkouts(){
        
    }
    
    
    
    
    func get(from : String, completion: @escaping (Result<[PostProtocol],Error>) -> () ) {
        var tempReferences:[String] = []
        ref.child(from).observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                tempReferences.insert((child as AnyObject).key, at: 0)
            }
            self.loadPosts(from: tempReferences, completion: completion)
        }
    }
    
    func loadPosts(from references:[String], completion: @escaping (Result<[PostProtocol],Error>) -> () ) {
        let myGroup = DispatchGroup()
        var tempPosts = [PostProtocol]()
        for reference in references{
            myGroup.enter()
            ref.child("Posts/\(reference)").observeSingleEvent(of: .value) { (snapshot) in
                defer {myGroup.leave()}
                guard let _ = snapshot.value as? [String:AnyObject] else {
                    return
                }
                tempPosts.append(self.configurePost(from: snapshot))
            }
        }
        myGroup.notify(queue: .main) {
            completion(.success(tempPosts))
        }
    }
    
    private func configurePost(from snapshot:DataSnapshot) -> PostProtocol{
        let snap = snapshot.value as! [String:AnyObject]
        switch snap["type"] as! String{
        case "post":
            return TimelinePostModel(snapshot: snapshot)!
        case "createdNewWorkout":
            return TimelineCreatedWorkoutModel(snapshot: snapshot)!
        case "workout":
            return TimelineCompletedWorkoutModel(snapshot: snapshot)!
        default:
            return TimelineActivityModel(snapshot: snapshot)!
        }
    }
    
    
    
    func loadProfileTimeline(for user:String, completion: @escaping (Result<[PostProtocol], Error>) -> Void) {
        let myGroup = DispatchGroup()
        var tempPosts = [PostProtocol]()
        var initialLoad = true
        let ref = Database.database().reference().child("Posts")
        loadReferences(for: user) { (result) in
            switch result{
            case .success(let references):
                for reference in references{
                    myGroup.enter()
                    ref.child(reference).observe(.value) { (snapshot) in
                        
                        guard let snap = snapshot.value as? [String:AnyObject] else {
                            return
                        }
                        
                        if initialLoad{
                            defer { myGroup.leave() }
                            
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
                        } else {
                            
                            // return the single post that has been updated 
                            
                            
                        }
                        
                        
                        
                        
                    }
                    
                    myGroup.notify(queue: .main){
                        completion(.success(tempPosts))
                        initialLoad = false
                    }
                }
            
            case .failure(let error):
                completion(.failure(error))
                    
            }
        }
    }
    
    func loadReferences(for user:String, completion: @escaping (Result<[String], Error>) -> Void) {
        var references = [String]()
        let ref = Database.database().reference().child("PostSelfReferences").child(user)
        ref.observe(.childAdded) { (snapshot) in
            references.append(snapshot.key)
        }
        ref.observeSingleEvent(of: .value) { (_) in
            completion(.success(references))
        }
    }
    
    func loadTimeline(for userID:String, completion: @escaping (Result<[PostProtocol], Error>) -> Void){
        var references = [String]()
        let ref = Database.database().reference().child("Timeline").child(userID)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                references.insert((child as AnyObject).key, at: 0)
            }
            self.loadPosts(with: references, completion: completion)
        }
    }
    
    func loadPosts( with references:[String], completion: @escaping (Result<[PostProtocol], Error>) -> Void) {
        let myGroup = DispatchGroup()
        let ref = Database.database().reference().child("Posts")
        var tempPosts = [PostProtocol]()
        
        if references.isEmpty{
            completion(.success(tempPosts))
        }
        
        for post in references {
            myGroup.enter()
            ref.child(post).observeSingleEvent(of: .value) { (snapshot) in
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
            completion(.success(tempPosts))
        }
    }
    
    
    func uploadActivity(with type:ActivityType){
        let activityRef = Database.database().reference().child("Activities").child(self.userID!).childByAutoId()
        var activityData = ["time":ServerValue.timestamp(),
                            "isPrivate":true] as [String:AnyObject]
        switch type {
        case .AccountCreated:
            activityData["type"] = "Account Created" as AnyObject
            activityData["message"] = "You created your account." as AnyObject
        case .RequestSent(let player):
            activityData["type"] = "Request Sent" as AnyObject
            activityData["message"] = "You sent a request to \(player)." as AnyObject
        case .RequestAccepted(let player, let coachID):
            activityData["type"] = "Request Accepted" as AnyObject
            activityData["message"] = "\(player) accepted your request." as AnyObject
            let ref = Database.database().reference().child("Activities").child(coachID).childByAutoId()
            ref.setValue(activityData)
            return
        case .NewCoach(let coach):
            activityData["type"] = "New Coach" as AnyObject
            activityData["message"] = "You accepted a request from \(coach)." as AnyObject
        case .CreatedWorkout(let workoutTitle):
            activityData["type"] = "Created Workout" as AnyObject
            activityData["message"] = "You created a new workout \(workoutTitle)." as AnyObject
        case .CompletedWorkout(let workoutTitle):
            activityData["type"] = "Workout Completed" as AnyObject
            activityData["message"] = "You completed the workout \(workoutTitle)." as AnyObject
        case .UpdatePBs:
            activityData["type"] = "Update PBs" as AnyObject
            activityData["message"] = "You updated your PBs." as AnyObject
        case .SetWorkout(let player):
            activityData["type"] = "Set Workout" as AnyObject
            activityData["message"] = "You set a workout for \(player)." as AnyObject
        case .StartedFollowing(let following):
            activityData["type"] = "Started Following" as AnyObject
            activityData["message"] = "You started following \(following)." as AnyObject
        }
        
        activityRef.setValue(activityData)
        
    }
}

enum ActivityType {
    case AccountCreated
    case RequestSent(String)
    case RequestAccepted(String, String)
    case NewCoach(String)
    case CreatedWorkout(String)
    case CompletedWorkout(String)
    case UpdatePBs
    case SetWorkout(String)
    case StartedFollowing(String)
}

enum PostType {
    case post(String)
    case createdNewWorkout(workout)
    case completedWorkout(workout)
}
