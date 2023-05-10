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

class ViewClipViewModel: NSObject {
    
    // MARK: - Publishers
    var errorPublisher = PassthroughSubject<Error,Never>()
    var playerPublisher = CurrentValueSubject<AVPlayer?,Never>(nil)
    var assetPublisher = PassthroughSubject<AVAsset,Never>()
    var premiumAccountPublisher = PassthroughSubject<Void,Never>()
    
    var failedToPreparePublihser = PassthroughSubject<Void,Never>()
    
    @Published var isLoading: Bool = true
    @Published var clipModel: ClipModel?
    @Published var error: Error?
    
    // MARK: - Properties
    var keyClipModel: KeyClipModel!
    
    // Key - value observing context
    private var playerItemContext = 0
    
    let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]
    
    var player: AVPlayer!
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    private var subscriptions = Set<AnyCancellable>()
    
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
                self?.prepareToPlay(asset)
            case .failure(let error):
                self?.errorPublisher.send(error)
                self?.isLoading = false
            }
        }
    }
    // MARK: - Fetch Clip Model
    @MainActor
    func fetchClipModel() {
        let clipSearchModel = ClipModelDownloadModel(clipKey: keyClipModel.clipKey)
        Task {
            do {
                let model: ClipModel = try await apiService.fetchSingleInstanceAsync(of: clipSearchModel)
                clipModel = model
            } catch {
                self.error = error
            }
        }
    }
    // MARK: - Prepare To Play
    func prepareToPlay(_ asset: AVAsset) {
        
        // Create player item with asset and array of asset keys to be automatically loaded
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: requiredAssetKeys)
        
        // Associate the player item with the player
        player = AVPlayer(playerItem: playerItem)
        
        // Send player to publisher
        playerPublisher.send(player)
    
        // Observe timeControlStatus
        // When playing remove loading screen
        player.publisher(for: \.timeControlStatus, options: [.new])
            .sink { [weak self] newTimeControlStatus in
                switch newTimeControlStatus {
                case .playing:
                    print("playing")
                    self?.isLoading = false
                case .paused:
                    print("paused")
                case .waitingToPlayAtSpecifiedRate:
                    print("waiting")
                @unknown default:
                    break
                }
            }
            .store(in: &subscriptions)
    }
}
