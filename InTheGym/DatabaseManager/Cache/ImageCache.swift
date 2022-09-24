//
//  ImageCache.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ImageCache {
    
    // MARK: - Properties
    static let shared = ImageCache()
    
    private init(){}
    
    private let cache = Cache<String,UIImage>()
    
    var apiService = FirebaseStorageManager.shared
    
    typealias completionHandler = ((Result<UIImage,Error>) -> Void)
    
    func load(from model: ProfileImageDownloadModel, completion: @escaping completionHandler) {
        if let cached = cache[model.id] {
            completion(.success(cached))
        } else {
            apiService.downloadImage(from: model) { [weak self] result in
                do {
                    let image = try result.get()
                    self?.cache[model.id] = image
                    completion(result)
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    func loadThumbnail(from model: ClipThumbnailDownloadModel, completion: @escaping completionHandler) {
        if let cached = cache[model.id] {
            completion(.success(cached))
        } else {
            apiService.downloadImage(from: model) { [weak self] result in
                do {
                    let image = try result.get()
                    self?.cache[model.id] = image
                    completion(result)
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    func replace(_ id: String, with image: UIImage) {
        cache[id] = image
    }
}
