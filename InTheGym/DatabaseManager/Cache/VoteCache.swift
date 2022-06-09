//
//  VoteCache.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

class VoteCache {
    
    // MARK: - Shared Instance
    static let shared = VoteCache()
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Firebase API Service
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Cache
    private let cache = Cache<String,Bool>()
    
    typealias handler = ((Result<Bool,Error>) -> Void)
    
    func load(from searchModel: CommentLikeSearchModel, completion: @escaping handler) {
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
    func upload(descriptionID: String) {
        cache[descriptionID] = true
    }
    
    func removeAll() {
        cache.removeAll()
    }
}
