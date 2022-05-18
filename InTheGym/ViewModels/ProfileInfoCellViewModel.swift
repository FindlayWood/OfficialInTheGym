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
    func followButtonAction() {
        let followActionModel = FollowModel(id: user.uid)
        let uploadPoints = followActionModel.getUploadPoints()
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            switch result {
            case .success(()):
                self?.isFollowing = true
                self?.getFollowerCount()
            case .failure(let error):
                print(String(describing: error))
                self?.isFollowing = false
            }
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
                self?.isFollowing = false
            }
        }
    }
}
