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
    private let cache = Cache<String,PostModel>()
    
    typealias handler = ((Result<PostModel,Error>) -> Void)
    
    // MARK: - Single Load
    func load(from searchModel: PostKeyModel, completion: @escaping handler) {
        if let cached = cache[searchModel.id] {
            completion(.success(cached))
        } else {
            Task {
                do {
                    let model: PostModel = try await apiService.fetchSingleInstanceAsync(of: searchModel)
                    cache[searchModel.id] = model
                    completion(.success(model))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Range Load
    func loadRange(from searchModels: [PostKeyModel], completion: @escaping (Result<[PostModel],Error>) -> Void) {
        var rangeOfPosts = [PostModel]()
        let dispatchGroup = DispatchGroup()
        for model in searchModels {
            dispatchGroup.enter()
            load(from: model) { result in
                switch result {
                case .success(let post):
                    rangeOfPosts.append(post)
                    dispatchGroup.leave()
                case .failure(_):
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(.success(rangeOfPosts))
        }
    }
    
    // MARK: - Add
    func add(_ post: PostModel) {
        cache[post.id] = post
    }
}
