//
//  FirebaseAPILoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class FirebaseAPILoader {
    
    typealias escapingSavedWorkout = Result<discoverWorkout,LoaderErrors>
    
    static let shared = FirebaseAPILoader()
    
    private init() {}
    
    private let baseRef = Database.database().reference()
    
    func loadDiscoverWorkout(with savedID: String, completion: @escaping (escapingSavedWorkout) -> Void) {
        let path = "SavedWorkouts/\(savedID)"
        let ref = baseRef.child(path)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let discoverWorkout = discoverWorkout(snapshot: snapshot) else {
                completion(.failure(.noSavedWorkout))
                return
            }
            completion(.success(discoverWorkout))
        }
    }
}

enum LoaderErrors: Error {
    case noUserID
    case noSavedWorkout
    case unKnown
}
