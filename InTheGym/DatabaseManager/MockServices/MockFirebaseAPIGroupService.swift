//
//  MockFirebaseAPIGroupService.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class MockFirebaseAPIGroupService: FirebaseAPIGroupServiceProtocol {
    
    func createGroup(with title: String, players: [Users], completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}
