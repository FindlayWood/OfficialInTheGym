//
//  RemoteMovementTypesLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/04/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import StatsKit

class RemoteMovementTypesLoader: MovementTypesLoader {
    private let db = Firestore.firestore()
    
    func loadAll() async throws -> [MovementPattern] {
        let path = "MovementTypes"
        
        let snapshot = try await db.collection(path).getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: MovementPattern.self)
        }
    }
}
