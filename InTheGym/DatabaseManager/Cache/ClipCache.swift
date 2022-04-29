//
//  ClipCache.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import AVFoundation

class ClipCache {
    
    // MARK: - Shared Instance
    static let shared = ClipCache()
    
    // MARK: - Private Initializer
    private init() {
        cache.setLimit(to: 10)
    }
    
    // MARK: - Firebase API Service
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Cache
    private let cache = Cache<String,AVAsset>()
    
    typealias handler = ((Result<AVAsset,Error>) -> Void)
    
    func load(from searchModel: KeyClipModel, completion: @escaping handler) {
        if let cached = cache[searchModel.clipKey] {
            completion(.success(cached))
        } else {
            guard let url = URL(string: searchModel.storageURL) else {
                completion(.failure(NSError(domain: "Failed URL", code: 0, userInfo: nil)))
                return
            }
            DispatchQueue.global(qos: .background).async {
                let player = AVPlayer(url: url)
                guard let asset = player.currentItem?.asset else {return}
                self.cache[searchModel.clipKey] = asset
                completion(.success(asset))
            }
        }
    }
    func upload(_ asset: AVAsset, key: String) {
        cache[key] = asset
    }
    func removeAll() {
        cache.removeAll()
    }
}
