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
    
    
    func createGroup(with data: NewGroupModel, completion: @escaping (Bool) -> Void) {
            completion(true)
    }
}
