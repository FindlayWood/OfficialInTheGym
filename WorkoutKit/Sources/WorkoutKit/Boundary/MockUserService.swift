//
//  File.swift
//  
//
//  Created by Findlay-Personal on 02/05/2023.
//

import Foundation

class MockUserService: CurrentUserServiceWorkoutKit {
    
    static let shared = MockUserService()
    
    private init() {}
    
    var currentUserUID: String {
        return "mock"
    }
}
