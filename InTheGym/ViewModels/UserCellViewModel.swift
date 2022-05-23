//
//  UserCellViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class UserCellViewModel {
    // MARK: - Publishers
    @Published var profileImageData: Data?
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func loadProfileImage(for user: Users) {
        DispatchQueue.global(qos: .background).async {
            let profileImageModel = ProfileImageDownloadModel(id: user.uid)
            ImageCache.shared.load(from: profileImageModel) { [weak self] result in
                let imageData = try? result.get().pngData()
                self?.profileImageData = imageData
            }
        }
    }
    
    // MARK: - Functions
}
