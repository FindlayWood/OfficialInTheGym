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
        try await ref.setData(from: model)
    }
    
    func upload(dataPoints: [String: Codable]) async throws {
        let batch = Firestore.firestore().batch()
        for dataPoint in dataPoints {
            let ref = Firestore.firestore().document(dataPoint.key)
            try batch.setData(from: dataPoint.value, forDocument: ref, merge: true)
        }
        try await batch.commit()
//        let ref = Firestore.firestore().document(path)
//        try ref.setData(from: data)
    }
    
    func read<T: Codable>(at path: String) async throws -> T {
        let ref = Firestore.firestore().document(path)
        return try await ref.getDocument(as: T.self)
    }
    
    func readAll<T: Codable>(at path: String) async throws -> [T] {
        let ref = Firestore.firestore().collection(path)
        return try await ref.getDocuments().documents.map { try $0.data(as: T.self) }
    }
}

extension FirebaseFirestore.DocumentReference {
    func setData<T: Encodable>(from: T, merge: Bool = false) async throws {
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(from)
        try await setData(data, merge: merge)
    }
}


protocol FirestoreService {
    func upload(dataPoints: [String: Codable]) async throws
    func read<T: Codable>(at path: String) async throws -> T
    func readAll<T: Codable>(at path: String) async throws -> [T]
}
