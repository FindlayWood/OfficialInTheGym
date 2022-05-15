//
//  DiscoverMoreClipsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class DiscoverMoreClipsViewModel {
    // MARK: - Publishers
    @Published var clips: [ClipModel] = []
    
    // MARK: - Properties
    var navigationTitle: String = "More Clips"
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func loadClips() {
        apiService.fetch(ClipModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.clips = models
            case .failure(let error):
                print(String(describing: error))
                break
            }
        }
    }
}
