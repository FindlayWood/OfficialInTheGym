//
//  FirebaseFunctionsManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import FirebaseFunctions
import Foundation

class FirebaseFunctionsManager: FunctionsManager {
    
    lazy var functions = Functions.functions()
    
    func callable(named: String, data: Any) async throws {
        let result = try await functions.httpsCallable(named).call(data)
        print(result)
    }
}

protocol FunctionsManager {
    func callable(named: String, data: Any) async throws
}
