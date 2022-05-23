//
//  FirebaseTimelineService.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseTimelineServiceProtocol {
    func loadPosts(from endpoint: PostEndpoint, completion: @escaping (Result<[PostModel], Error>) -> Void)
    var baseRef: DatabaseReference { get set }
}
extension FirebaseTimelineServiceProtocol {
    func likePost(from endpoint: LikePostEndpoint, completion: @escaping (Result<Void,Error>) -> Void) {
        baseRef.updateChildValues(endpoint.paths) { error, ref in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

class FirebaseTimelineService: FirebaseTimelineServiceProtocol {
    
    static let shared = FirebaseTimelineService()
    
    internal var baseRef: DatabaseReference = Database.database().reference()
    
    private init(){}
    
    func loadPosts(from endpoint: PostEndpoint, completion: @escaping (Result<[PostModel], Error>) -> Void){}
    
//    func likePost(from endpoint: LikePostEndpoint, completion: @escaping (Result<Void,Error>) -> Void){
//        baseRef.updateChildValues(endpoint.paths) { error, ref in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
//    }
    
}
