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
    
    static let shared = FirebaseAPI()
    
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
        var initialLoad = true
        var references = [String]()
        let ref = Database.database().reference().child("Timeline").child(userID)
        ref.observe(.childAdded) { (snapshot) in
            references.insert(snapshot.key, at: 0)
            if initialLoad == false {
                
            }
        }
        ref.observeSingleEvent(of: .value) { (_) in
            initialLoad = false
            self.loadPosts(with: references, completion: completion)
        }
        
    }
    
    func loadPosts( with references:[String], completion: @escaping (Result<[PostProtocol], Error>) -> Void) {
        let myGroup = DispatchGroup()
        let ref = Database.database().reference().child("Posts")
        var tempPosts = [PostProtocol]()
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
            
            myGroup.notify(queue: .main){
                completion(.success(tempPosts))
            }
            
        }
    }
    
    
    
    
}
