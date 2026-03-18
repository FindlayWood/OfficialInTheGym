//
//  File.swift
//  
//
//  Created by Findlay-Personal on 11/05/2023.
//

import UIKit

protocol ImageLoader {
    func loadImage(at path: String) async throws -> UIImage
}

class RemoteImageLoader: ImageLoader {
    
    var storageService: StorageService
    
    init(storageService: StorageService) {
        self.storageService = storageService
    }
    
    func loadImage(at path: String) async throws -> UIImage {
        return UIImage()
    }
}
