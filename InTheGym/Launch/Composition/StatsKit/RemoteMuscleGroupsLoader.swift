//
//  RemoteMuscleGroupsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/04/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import StatsKit

class RemoteMuscleGroupsLoader: MuscleGroupsLoader {
    private let db = Firestore.firestore()
    
    func loadAll() async throws -> [MuscleGroup] {
        let path = "MuscleGroups"
        
        let snapshot = try await db.collection(path).getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: MuscleGroup.self)
        }
    }
}
