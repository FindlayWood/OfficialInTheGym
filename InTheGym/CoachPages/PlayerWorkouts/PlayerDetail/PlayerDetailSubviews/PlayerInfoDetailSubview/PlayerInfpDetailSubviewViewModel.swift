//
//  PlayerInfpDetailSubviewViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class PlayerInfoDetailSubviewViewModel {
    // MARK: - Publishers
    @Published var followerCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var error: Error?
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var user: Users!
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Functions
    @MainActor
    func getFollowerCount() {
        let model = FollowersModel(id: user.uid)
        Task {
            do {
                let count = try await apiService.childCountAsync(of: model)
                followerCount = count
            } catch {
                self.error = error
            }
        }
    }
    @MainActor
    func getFollowingCount() {
        let model = FollowingModel(id: user.uid)
        Task {
            do {
                let count = try await apiService.childCountAsync(of: model)
                followingCount = count
            } catch {
                self.error = error
            }
        }
    }
}
