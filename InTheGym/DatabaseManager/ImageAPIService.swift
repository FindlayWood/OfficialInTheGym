//
//  ImageAPIService.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

class ImageAPIService {
    
    // MARK: - Shared Instance
    static var shared = ImageAPIService()
    
    // MARK: Private Initializer
    private init(){}
    
    // MARK: - Cache Properties
    let profileImageCache = NSCache<NSString,UIImage>()
 
}

// MARK: - Public Functions
extension ImageAPIService {
    public func getProfileImage(for userID: String, completion: @escaping (UIImage?) -> ()) {
        if let image = profileImageCache.object(forKey: userID as NSString) {
            completion(image)
        } else {
            downloadFirebaseImage(for: userID, completion: completion)
        }
    }
}

// MARK: - Private Functions
private extension ImageAPIService {
    private func downloadFirebaseImage(for userID: String, completion: @escaping (UIImage?) -> ()) {
        let storage = Storage.storage().reference().child("ProfilePhotos/\(userID)")
        storage.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if error != nil {
                completion(nil)
                return
            }
            if let data = data{
                let image = UIImage(data: data)
                completion(image)
                self.profileImageCache.setObject(image!, forKey: userID as NSString)
            }
        }
    }
}
