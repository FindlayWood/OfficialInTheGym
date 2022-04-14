//
//  MyClipsChildViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class MyClipsChildViewModel {
    
    // MARK: - Publishers
    var clipPublisher = CurrentValueSubject<[ClipModel],Never>([])
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func fetchClipKeys() {
        let searchModel = UserClipsModel(id: UserDefaults.currentUser.uid)
        apiService.fetchInstance(of: searchModel, returning: KeyClipModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.loadClips(from: models)
            case .failure(_):
                break
            }
        }
    }
    func loadClips(from keys: [KeyClipModel]) {
        apiService.fetchRange(from: keys, returning: ClipModel.self) { [weak self] result in
            switch result {
            case .success(var models):
                models.sort { $0.time < $1.time }
                self?.clipPublisher.send(models)
            case .failure(_):
                break
            }
        }
    }
}
