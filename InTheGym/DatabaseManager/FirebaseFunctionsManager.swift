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
    
    lazy var functions: Functions = Functions.functions()
    
    func callable(named: String, data: Any) async throws {
#if EMULATOR
        print("using emulator")
        functions.useEmulator(withHost: "127.0.0.1", port: 5001)
#endif
        let result = try await functions.httpsCallable(named).call(data)
        print(result)
    }
}

class EmulatorFirebaseFunctionsManager: FunctionsManager {
    
    lazy var functions: Functions = Functions.functions()
    
    func callable(named: String, data: Any) async throws {
        functions.useEmulator(withHost: "127.0.0.1", port: 5001)
        let result = try await functions.httpsCallable(named).call(data)
    }
}

protocol FunctionsManager {
    func callable(named: String, data: Any) async throws
}
