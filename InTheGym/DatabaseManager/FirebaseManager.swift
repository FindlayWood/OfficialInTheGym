//
//  FirebaseManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

protocol FirebaseManagerService {
    func upload(from endpoint: PostEndpoint, completion: @escaping (Result<Void, Error>) -> Void)
    func retreivePosts(from endpoint: PostEndpoint, completion: @escaping (Result<[post], Error>) -> Void)
    func updateMultiLocation(from endPoint: MultipleDatabaseEndpoint, completion: @escaping (Result<[String:Any], Error>) -> Void)
}

class FirebaseManager: FirebaseManagerService {
    
    static let shared = FirebaseManager()
    
    private var databaseReference: DatabaseReference!
    
    
    private init() {
        databaseReference = Database.database().reference()
    }
    
    ///upload a post from an endpoint
    func upload(from endpoint: PostEndpoint, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let path = endpoint.path,
              var data  = endpoint.post
        else {
            completion(.failure(NSError(domain: "Nil Info", code: 0, userInfo: nil)))
            return
        }
        databaseReference = Database.database().reference().child(path).childByAutoId()
        guard let postID = databaseReference.key else {return}
        data.id = postID //set the post id to childbyautoid
        data.username = FirebaseAuthManager.currentlyLoggedInUser.username //set the username to currently logged in username
        data.posterID = FirebaseAuthManager.currentlyLoggedInUser.uid //set the userID to currently logged in userID
        data.time = Date().timeIntervalSince1970 //set the time to current time
        
        do {
            let uploadObject = try FirebaseEncoder().encode(data)
            databaseReference.setValue(uploadObject) { error, ref in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func retreivePosts(from endpoint: PostEndpoint, completion: @escaping (Result<[post], Error>) -> Void) {
        guard let path = endpoint.path
        else {
            completion(.failure(NSError(domain: "Nil Info", code: 0, userInfo: nil)))
            return
        }
        var tempPosts: [post] = []
        let myGroup = DispatchGroup()
        databaseReference = Database.database().reference().child(path)
        databaseReference.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                myGroup.enter()
                guard let postObject = child.value as? [String: AnyObject] else {return}
                do {
                    let postData = try FirebaseDecoder().decode(post.self, from: postObject)
                    tempPosts.append(postData)
                    myGroup.leave()
                }
                catch {
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: .main) {
                completion(.success(tempPosts))
            }
        }
    }
    
    
//    func post<T:Codable>(to path: String, object: T, completion: @escaping (Result<T, Error>) -> Void) {
//        do {
//            let data = try FirebaseEncoder().encode(object)
//        }
//        catch {
//            print(error.localizedDescription)
//            completion(.failure(error))
//        }
//    }
    
    func updateMultiLocation(from endPoint: MultipleDatabaseEndpoint, completion: @escaping (Result<[String:Any], Error>) -> Void) {
        databaseReference = Database.database().reference()
        databaseReference.updateChildValues(endPoint.paths) { error, ref in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            } else {
                completion(.success(endPoint.paths))
            }
        }
    }
    
    func transactionUpdate() {
        
    }
    
    func get<T:Codable>(from path: String, completion: @escaping (Result<T, Error>) -> Void) {
        
    }
    
}
