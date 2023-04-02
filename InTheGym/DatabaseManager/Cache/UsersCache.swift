//
//  UsersCache.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

class UsersLoader {
    
    // MARK: - Properties
    static let shared = UsersLoader()
    
    private init(){}
    
    private let cache = Cache<String,Users>()
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    typealias completionHandler = ((Result<Users,Error>) -> Void)
    
    func load(from searchModel: UserSearchModel, completion: @escaping completionHandler) {
        if let cached = cache[searchModel.uid] {
            completion(.success(cached))
        } else {
            Task {
                do {
                    let model: Users = try await apiService.fetchSingleInstanceAsync(of: searchModel)
                    cache[searchModel.uid] = model
                    completion(.success(model))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    // MARK: - Range Load
    func loadRange(from searchModels: [UserSearchModel], completion: @escaping (Result<[Users],Error>) -> Void) {
        var rangeOfUsers = [Users]()
        let dispatchGroup = DispatchGroup()
        for model in searchModels {
            dispatchGroup.enter()
            load(from: model) { result in
                switch result {
                case .success(let post):
                    rangeOfUsers.append(post)
                    dispatchGroup.leave()
                case .failure(_):
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(.success(rangeOfUsers))
        }
    }
}

class UsersLoaderAsync {
    
    // MARK: - Properties
    static let shared = UsersLoaderAsync()
    
    private init(){}
    
    private let cache = Cache<String,Users>()
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    typealias completionHandler = ((Result<Users,Error>) -> Void)
    
    func load(from searchModel: UserSearchModel) async throws -> Users {
        if let cached = cache[searchModel.uid] {
            return cached
        } else {
            let userModel: Users = try await apiService.fetchSingleInstanceAsync(of: searchModel)
            return userModel
        }
    }
    // MARK: - Range Load
    func loadRange(from searchModels: [UserSearchModel]) async -> [Users] {
        var rangeOfUsers = [Users]()
        for model in searchModels {
            if let userModel = try? await load(from: model) {
                rangeOfUsers.append(userModel)
            }
        }
        return rangeOfUsers
    }
}
