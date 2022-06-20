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
}
