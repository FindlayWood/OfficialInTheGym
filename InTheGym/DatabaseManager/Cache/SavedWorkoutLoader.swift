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
            Task {
                do {
                    let model: SavedWorkoutModel = try await apiService.fetchSingleInstanceAsync(of: searchModel)
                    cache[searchModel.id] = model
                    completion(.success(model))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
