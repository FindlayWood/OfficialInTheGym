//
//  FirebaseStorageManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseStorage
import UIKit

class FirebaseStorageManager {
    
    // MARK: - Shared Instance
    static let shared = FirebaseStorageManager()
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Functions
    func upload<T: FirebaseStorage>(model: T, completion: @escaping ((Result<Void,Error>) -> Void)) {
        guard let data = model.data else {
            completion(.failure(NSError(domain: "nil data", code: 0, userInfo: nil)))
            return
        }
        let storageRef = Storage.storage().reference().child(model.storagePath)
        storageRef.putData(data, metadata: model.metaData) { storageMetaData, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func downloadImage(from model: ProfileImageDownloadModel, completion: @escaping ((Result<UIImage,Error>) -> Void)) {
        let storageRef = Storage.storage().reference().child(model.storagePath)
        storageRef.getData(maxSize: 1 * 720 * 720) { (data, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(NSError(domain: "Nil Image Data", code: 0, userInfo: nil)))
                }
            }
        }
    }
}
