//
//  WorkoutLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import Foundation

class WorkoutLoader {
    
    // MARK: - Shared Instance
    static let shared = WorkoutLoader()
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Firebase API Service
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Cache
    private let cache = Cache<String,WorkoutModel>()
    
    typealias handler = ((Result<WorkoutModel,Error>) -> Void)
    
    func load(from searchModel: WorkoutKeyModel, completion: @escaping handler) {
        if let cached = cache[searchModel.id] {
            completion(.success(cached))
        } else {
            Task {
                do {
                    let model: WorkoutModel = try await apiService.fetchSingleInstanceAsync(of: searchModel)
                    cache[searchModel.id] = model
                    completion(.success(model))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
