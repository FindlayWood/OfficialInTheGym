//
//  PostLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import Foundation

class PostLoader {
    
    // MARK: - Shared Instance
    static let shared = PostLoader()
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Firebase API Service
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Cache
    private let cache = Cache<String,post>()
    
    typealias handler = ((Result<post,Error>) -> Void)
    
    // MARK: - Single Load
    func load(from searchModel: PostKeyModel, completion: @escaping handler) {
        if let cached = cache[searchModel.id] {
            completion(.success(cached))
        } else {
            apiService.fetchSingleInstance(of: searchModel, returning: post.self) { [weak self] result in
                let user = try? result.get()
                user.map { self?.cache[searchModel.id] = $0 }
                completion(result)
            }
        }
    }
    
    // MARK: - Range Load
    func loadRange(from searchModels: [PostKeyModel], completion: @escaping (Result<[post],Never>) -> Void) {
        var rangeOfPosts = [post]()
        let dispatchGroup = DispatchGroup()
        for model in searchModels {
            dispatchGroup.enter()
            load(from: model) { result in
                do {
                    let post = try result.get()
                    rangeOfPosts.append(post)
                    dispatchGroup.leave()
                } catch {
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(.success(rangeOfPosts))
        }
    }
}
