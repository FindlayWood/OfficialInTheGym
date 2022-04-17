//
//  ProfileInfoCellViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class ProfileInfoCellViewModel {
    
    // MARK: - Publishers
    @Published var followerCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var isFollowing: Bool?
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    var user: Users!
         
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func checkUserModel() {
        if user != UserDefaults.currentUser {
            checkFollowing()
        }
    }
    
    // MARK: - Functions
    func getFollowerCount() {
        let followerModel = FollowersModel(id: user.uid)
        apiService.childCount(of: followerModel) { [weak self] result in
            switch result {
            case .success(let count):
                self?.followerCount = count
            case .failure(_):
                break
            }
        }
        let followingModel = FollowingModel(id: user.uid)
        apiService.childCount(of: followingModel) { [weak self] result in
            switch result {
            case .success(let count):
                self?.followingCount = count
            case .failure(_):
                break
            }
        }
    }
    
    // MARK: - Check Following
    func checkFollowing() {
        let followingModel = CheckFollowingModel(id: user.uid)
        apiService.checkExistence(of: followingModel) { [weak self] result in
            switch result {
            case .success(let exists):
                self?.isFollowing = exists
            case .failure(_):
                break
            }
        }
    }
}
