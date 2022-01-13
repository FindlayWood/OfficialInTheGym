//
//  MockFirebaseDatabaseManager.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 13/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
@testable import InTheGym

class MockFirebaseDatabaseManager: FirebaseDatabaseManagerService {
    
    var completionResult: Result<Void,Error> = .success(())
    
    func fetch<Model>(_ model: Model.Type, completion: @escaping (Result<[Model], Error>) -> Void) where Model : FirebaseModel {
            
    }
    
    func fetchInstance<M, T>(of model: M, returning returnType: T.Type, completion: @escaping (Result<[T], Error>) -> Void) where M : FirebaseInstance, T : Decodable {
            
    }
    
    func upload<Model>(data: Model, autoID: Bool, completion: @escaping (Result<Void, Error>) -> Void) where Model : FirebaseInstance {
            
    }
    
    func multiLocationUpload(data: [FirebaseMultiUploadDataPoint], completion: @escaping (Result<Void, Error>) -> Void) {
        completion(completionResult)
    }
    
    func incrementingValue(by increment: Int, at path: String, completion: @escaping (Result<Void, Error>) -> Void) {
            
    }
    
    func removingValue(at path: String, completion: @escaping (Result<Void, Error>) -> Void) {
            
    }
    
    
}
