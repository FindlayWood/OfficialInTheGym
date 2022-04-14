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
    
    @Published var isLoading: Bool = false
    
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
//        if UserDefaults.currentUser.premiumAccount ?? true {
        if true {
            ClipCache.shared.load(from: keyClipModel) { [weak self] result in
                switch result {
                case .success(let asset):
                    self?.prepareToPlay(asset)
//                    self?.assetPublisher.send(asset)
//                    let item = AVPlayerItem(asset: asset)
//                    let player = AVPlayer(playerItem: item)
//                    self?.playerPublisher.send(player)
//                    self?.isLoading = false
                case .failure(let error):
                    self?.errorPublisher.send(error)
                    self?.isLoading = false
                }
            }
        } else {
            isLoading = false
            premiumAccountPublisher.send(())
        }
    }
    
    // MARK: - Prepare To Play
    func prepareToPlay(_ asset: AVAsset) {
        
        // Create player item with asset and array of asset keys to be automatically loaded
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: requiredAssetKeys)
        
        // Use Combine to create publisher on player item status
        playerItem.publisher(for: \.status, options: [.new, .old])
            .sink { [weak self] newStatus in
                switch newStatus {
                case .readyToPlay:
                    print("ready to play")
                    self?.playerPublisher.send(self?.player)
                    self?.isLoading = false
                case .unknown:
                    print("unknown")
                case .failed:
                    print("failed")
                @unknown default:
                    break
                }
            }
            .store(in: &subscriptions)
        
        // Associate the player item with the player
        player = AVPlayer(playerItem: playerItem)
        
    }
}
