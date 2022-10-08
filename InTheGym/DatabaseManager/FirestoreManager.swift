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

class FirestoreManager {
    
    static let shared = FirestoreManager()
    
    private init() {}
    
    func upload<Model: FirestoreResource>(_ model: Model) async throws {
        let ref = Firestore.firestore().collection(model.collectionPath).document(model.documentID)
        try ref.setData(from: model)
    }
}
