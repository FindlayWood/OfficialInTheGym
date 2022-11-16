//
//  UserFollowing+ViewModel.swift
//  InTheGym
//
//  Created by Findlay-Personal on 07/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

extension UserFollowingSwiftUI {
    final class ViewModel: ObservableObject {
        @Published var followerCount: Int = 0
        @Published var followingCount: Int = 0
        @Published var error: Error?
        
        var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
        
        // MARK: - Initializer
        init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
            self.apiService = apiService
        }
        
        // MARK: - Methods
        func getFollowerCount(_ user: Users) {
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
        func getFollowingCount(_ user: Users) {
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
}
