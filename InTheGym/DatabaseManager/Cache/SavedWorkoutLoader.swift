//
//  SavedWorkoutLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

class SavedWorkoutLoader {
    
    // MARK: - Shared Instance
    static let shared = SavedWorkoutLoader()
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Firebase API Service
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Cache
    private let cache = Cache<String,SavedWorkoutModel>()
    
    typealias handler = ((Result<SavedWorkoutModel,Error>) -> Void)
    
    func load(from searchModel: SavedWorkoutKeyModel, completion: @escaping handler) {
        if let cached = cache[searchModel.id] {
            completion(.success(cached))
        } else {
            apiService.fetchSingleInstance(of: searchModel, returning: SavedWorkoutModel.self) { [weak self] result in
                let user = try? result.get()
                user.map { self?.cache[searchModel.id] = $0 }
                completion(result)
            }
        }
    }
}
