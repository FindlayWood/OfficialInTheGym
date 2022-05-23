//
//  MockFirebaseManager.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 07/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
@testable import InTheGym

class MockFirebaseManager: FirebaseManagerService {
    
    var uploadResult: Result<Void,Error> = .success(())
    
    func upload(from endpoint: PostEndpoint, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(uploadResult)
    }
    
    func retreivePosts(from endpoint: PostEndpoint, completion: @escaping (Result<[PostModel], Error>) -> Void) {
        completion(.success([]))
    }
    
    func updateMultiLocation(from endPoint: MultipleDatabaseEndpoint, completion: @escaping (Result<[String : Any], Error>) -> Void) {
        completion(.success([:]))
    }
    
    
}
