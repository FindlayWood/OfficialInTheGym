//
//  ImageCache.swift
//
//
//  Created by Findlay Wood on 05/02/2024.
//

import UIKit

protocol ImageCache {
    func getImage(for path: String, completion: @escaping (UIImage?) -> Void)
}


struct FirebaseImageCache: ImageCache {
    
    var storageService: StorageService
    
    private let cache = Cache<String,UIImage>()
    
    
    func getImage(for path: String, completion: @escaping (UIImage?) -> Void) {
        if let cached = cache[path] {
            completion(cached)
        } else {
            storageService.getData(at: path, maxSize: 1 * 720 * 720) { result in
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        cache.insert(image, forKey: path)
                        completion(image)
                    } else {
                        completion(nil)
                    }
                case .failure(let error):
                    print(String(describing: error))
                    completion(nil)
                }
            }
        }
    }
}


struct PreviewImageCache: ImageCache {
    
    func getImage(for path: String, completion: @escaping (UIImage?) -> Void) {
        completion(nil)
    }
}
