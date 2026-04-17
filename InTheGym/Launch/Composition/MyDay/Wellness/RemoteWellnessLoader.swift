//
//  RemoteWellnessLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/04/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import MyDayKit

class FirestoreWellnessLoader: WellnessLoader {
    
    func load<T: Codable>(for date: Date) async throws -> T? {
        let userID = UserDefaults.currentUser.uid
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let documentID = formatter.string(from: date)
        let path = "Users/\(userID)/Wellness/\(documentID)"
        let ref = Firestore.firestore().document(path)
        
        
        do {
            let model = try await ref.getDocument(as: T.self)
            return model
        } catch let error as NSError where error.domain == FirestoreErrorDomain &&
                                            error.code == FirestoreErrorCode.notFound.rawValue {
            return nil
        } catch {
            print("❌ Firestore load error: \(error)")
            throw error
        }
        
    }
}
