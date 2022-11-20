//
//  PlayerDetailViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import Foundation
import UIKit

class PlayerDetailViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var profileImageData: Data?
    @Published var image: UIImage?
    @Published var followerCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var error: Error?
    @Published var lastWorkouts: [WorkoutModel] = []
    var action = PassthroughSubject<ScreenActions,Never>()
    // MARK: - Properties
    enum ScreenActions {
        case profile
        case performance
        case workouts
        case addWorkout
        case workout(WorkoutModel)
    }
    var navigationTitle = "Player Detail"
    
    var user: Users!
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func getImage() {
        let downloadModel = ProfileImageDownloadModel(id: user.uid)
        ImageCache.shared.load(from: downloadModel) { [weak self] result in
            guard let image = try? result.get() else {return}
            self?.image = image
        }
    }
    
    // MARK: - Methods
    func getFollowerCount() {
        let model = FollowersModel(id: user.uid)
        apiService.childCount(of: model) { [weak self] result in
            switch result {
            case .success(let count):
                self?.followerCount = count
            case .failure(let error):
                self?.error = error
            }
        }
    }
    func getFollowingCount() {
        let model = FollowingModel(id: user.uid)
        apiService.childCount(of: model) { [weak self] result in
            switch result {
            case .success(let count):
                self?.followingCount = count
            case .failure(let error):
                self?.error = error
            }
        }
    }
    @MainActor
    func getLastWorkouts() async {
        let searchModel = WorkoutSearchModel(id: user.uid)
        do {
            let workouts: [WorkoutModel] = try await apiService.fetchLimitedInstanceAsync(of: searchModel, limit: 3)
            lastWorkouts = workouts.sorted(by: { $0.startTime ?? 0 > $1.startTime ?? 0 })
        } catch {
            print(String(describing: error))
        }
    }
}
