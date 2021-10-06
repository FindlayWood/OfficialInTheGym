//
//  PostEndpoints.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

enum PostEndpoints: PostEndpoint {
    case post(postModel: CreateNewPostModel?)
    case postToGroup(groupID: String?, postModel: CreateNewPostModel?)
    case getGroupPosts(groupID: String?)
    
    var path: String? {
        switch self {
        case .post(_):
            return "Posts"
        case .postToGroup(let groupID, _), .getGroupPosts(let groupID):
            guard let groupID = groupID else {return nil}
            return "GroupPosts/\(groupID)"
        }
    }
    
    var post: CreateNewPostModel? {
        switch self {
        case .post(let post), .postToGroup(_, let post):
            guard let post = post else {return nil}
            return post
        case .getGroupPosts(_):
            return nil
        }
    }

    
}
//extension PostEndpoints {
//    func upload(completion: @escaping (Result<Void, Error>) -> Void) {
//        service.upload(from: self, completion: completion)
//    }
//    func retreive(completion: @escaping (Result<[post], Error>) -> Void) {
//        service.retreivePosts(from: self, completion: completion)
//    }
//}

class PractiveFirebase {
    func postToMultiplePaths(from endpoint: MultipleDatabaseEndpoint, completion: @escaping (Result<AnyObject, Error>) -> Void) {
        
    }
}
