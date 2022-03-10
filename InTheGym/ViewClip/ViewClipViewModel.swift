//
//  ViewClipViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine
import AVFoundation

class ViewClipViewModel {
    
    // MARK: - Publishers
    var errorPublisher = PassthroughSubject<Error,Never>()
    var playerPublisher = CurrentValueSubject<AVPlayer?,Never>(nil)
    
    @Published var isLoading: Bool = false
    
    // MARK: - Properties
    var keyClipModel: KeyClipModel!
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func fetchClip() {
        isLoading = true
        ClipCache.shared.load(from: keyClipModel) { [weak self] result in
            switch result {
            case .success(let asset):
                let item = AVPlayerItem(asset: asset)
                let player = AVPlayer(playerItem: item)
                self?.playerPublisher.send(player)
                self?.isLoading = false
            case .failure(let error):
                self?.errorPublisher.send(error)
                self?.isLoading = false
            }
        }
    }
}
