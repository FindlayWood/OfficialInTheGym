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
            apiService.fetchSingleInstance(of: searchModel, returning: Users.self) { [weak self] result in
                let user = try? result.get()
                user.map { self?.cache[searchModel.uid] = $0 }
                completion(result)
            }
        }
    }
}
