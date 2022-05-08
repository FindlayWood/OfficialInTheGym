//
//  PlayerProfileMoreViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine
import UIKit

class PlayerProfileMoreViewModel: ObservableObject {
    
    // MARK: - Publishers
    @Published var profileImage: UIImage?
    var actionPublisher = PassthroughSubject<PlayerProfileMoreAction,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func action(_ action: PlayerProfileMoreAction) {
        actionPublisher.send(action)
    }
    
    // MARK: - Functions
    func getProfileImage() {
        let profileImageDownloadModel = ProfileImageDownloadModel(id: UserDefaults.currentUser.uid)
        ImageCache.shared.load(from: profileImageDownloadModel) { [weak self] result in
            guard let image = try? result.get() else {return}
            self?.profileImage = image
        }
    }
    func getAccountCreated() -> String {
        if let timeCreated = UserDefaults.currentUser.accountCreated {
            return Date(timeIntervalSince1970: timeCreated).getYear()
        } else {
            return Constants.defaultAccountCreatedDate
        }
    }
}

enum PlayerProfileMoreAction {
    case editProfile
    case myCoaches
    case requests
    case exerciseStats
    case measureJump
    case breathWork
    case settings
}
