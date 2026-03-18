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
    func dataUpload<T: FirebaseStorageData>(model: T, completion: @escaping ((Result<Void,Error>) -> Void)) {
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
    
    func dataUploadAsync(data: Data, at path: String) async throws {
        let ref = Storage.storage().reference().child(path)
        let _ = try await ref.putDataAsync(data)
    }
    
    func dataDownload(from path: String, maxSize: Int64, completion: @escaping (Result<Data,Error>) -> Void) {
        let ref = Storage.storage().reference().child(path)
        ref.getData(maxSize: maxSize, completion: completion)
    }
    
    func downloadImage(from model: FirebaseStoragePath, completion: @escaping ((Result<UIImage,Error>) -> Void)) {
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
    
    func fileUpload<T: FirebaseStorageFile>(model: T, completion: @escaping ((Result<String,Error>) -> Void)) {
        let storageRef = Storage.storage().reference().child(model.storagePath)
        let uploadTask = storageRef.putFile(from: model.file, metadata: model.metaData)
        
        uploadTask.observe(.success) { snapshot in
            storageRef.downloadURL { downloadedURL, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = downloadedURL {
                    completion(.success(url.absoluteString))
                }
            }
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                completion(.failure(error))
            }
        }
    }
    // MARK: - Delete Function
    func deleteFile<T: FirebaseStorageFile>(model: T, completion: @escaping ((Result<Void,Error>) -> Void)) {
        let storageRef = Storage.storage().reference().child(model.storagePath)
        storageRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
