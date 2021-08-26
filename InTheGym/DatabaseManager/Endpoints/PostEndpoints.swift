//
//  PostEndpoints.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

enum PostEndpoints: MultipleDatabaseEndpoint {
    case post(postID: String, post: PostProtocol, userID: String)
    //case postToGroup(id: String)
    
    var paths: [String:Any] {
        switch self {
        case .post(let postID, let post, let userID):
            return ["Posts/\(postID)":post.toObject(), "PostSelfReferences/\(userID)/\(postID)": true]
//        case .postToGroup(let id):
//            return ["GroupPosts/\(id)"]
        }
    }
}
extension PostEndpoints {
    func post() {
        
    }
}

class PractiveFirebase {
    func postToMultiplePaths(from endpoint: MultipleDatabaseEndpoint, completion: @escaping (Result<AnyObject, Error>) -> Void) {
        
    }
}
