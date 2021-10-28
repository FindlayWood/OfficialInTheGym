//
//  MockFirebaseEMOMService.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 27/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
@testable import InTheGym

class MockFirebaseEMOMService: EMOMFirebaseServiceProtocol {
    
    var completionResult: Result<Void,Error> = .success(())
    
    func completedEMOM(on workout: workout, at position: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(completionResult)
    }
    
    func uploadRPEScore(on workout: workout, at position: Int, with score: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(completionResult)
    }
}
