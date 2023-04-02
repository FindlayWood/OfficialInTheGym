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
        @MainActor
        func getFollowerCount(_ user: Users) {
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
        func getFollowingCount(_ user: Users) {
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
}
