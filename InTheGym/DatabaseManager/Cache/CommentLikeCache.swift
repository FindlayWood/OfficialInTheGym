//
//  CommentLikeCache.swift
//  InTheGym
//
//  Created by Findlay-Personal on 18/03/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

class CommentLikeCache {
    
    // MARK: - Shared Instance
    static let shared = CommentLikeCache()
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Firebase API Service
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Cache
    private let cache = Cache<String,Bool>()
    
    typealias handler = ((Result<Bool,Error>) -> Void)
    
    func load(from searchModel: LikedCommentSearchModel, completion: @escaping handler) {
        if let cached = cache[searchModel.commentID] {
            completion(.success(cached))
        } else {
            apiService.checkExistence(of: searchModel) { [weak self] result in
                do {
                    let exists = try result.get()
                    self?.cache[searchModel.commentID] = exists
                    completion(result)
                } catch {
                    completion(result)
                }
            }
        }
    }
    func upload(commentID: String) {
        cache[commentID] = true
    }
    
    func removeAll() {
        cache.removeAll()
    }
}
