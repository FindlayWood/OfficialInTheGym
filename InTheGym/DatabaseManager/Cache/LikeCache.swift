//
//  LikeCache.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

class LikeCache {
    
    // MARK: - Shared Instance
    static let shared = LikeCache()
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Firebase API Service
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Cache
    private let cache = Cache<String,Bool>()
    
    typealias handler = ((Result<Bool,Error>) -> Void)
    
    func load(from searchModel: LikeSearchModel, completion: @escaping handler) {
        if let cached = cache[searchModel.postID] {
            completion(.success(cached))
        } else {
            apiService.checkExistence(of: searchModel) { [weak self] result in
                do {
                    let exists = try result.get()
                    self?.cache[searchModel.postID] = exists
                    completion(result)
                } catch {
                    completion(result)
                }
            }
        }
    }
    func upload(postID: String) {
        cache[postID] = true
    }
    
    func removeAll() {
        cache.removeAll()
    }
}
