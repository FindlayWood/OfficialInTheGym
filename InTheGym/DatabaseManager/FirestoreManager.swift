//
//  FirestoreManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreManager: FirestoreService {
    
    static let shared = FirestoreManager()
    
    private init() {}
    
    func upload<Model: FirestoreResource>(_ model: Model) async throws {
        let ref = Firestore.firestore().collection(model.collectionPath).document(model.documentID)
        try ref.setData(from: model)
    }
    
    func upload(data: Codable, at path: String) async throws {
        let ref = Firestore.firestore().document(path)
        try ref.setData(from: data)
    }
    
    func read<T: Codable>(at path: String) async throws -> T {
        let ref = Firestore.firestore().document(path)
        return try await ref.getDocument(as: T.self)
    }
}


protocol FirestoreService {
    func upload(data: Codable, at path: String) async throws
    func read<T: Codable>(at path: String) async throws -> T
}
