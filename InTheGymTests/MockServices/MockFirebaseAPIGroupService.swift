//
//  MockFirebaseAPIGroupService.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 11/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

@testable import InTheGym

final class MockFirebaseAPIGroupService: FirebaseAPIGroupServiceProtocol {
    func loadMembers(from group: MoreGroupInfoModel, completion: @escaping (Result<[Users], Error>) -> Void) {
        
    }
    
    func loadLeader(from group: MoreGroupInfoModel, completion: @escaping (Result<Users, Error>) -> Void) {
        
    }
    
    func saveNewGroupInfo(from group: MoreGroupInfoModel, completion: @escaping (Bool) -> Void) {
        
    }
    
    func fetchGroupWorkouts(from groupID: String, completion: @escaping (Result<[GroupWorkoutModel], Error>) -> Void) {
        
    }
    
    func createGroup(with data: NewGroupModel, completion: @escaping (Bool) -> Void) {
            completion(true)
    }
}
