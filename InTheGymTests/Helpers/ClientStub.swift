//
//  ClientStub.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 09/06/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import Foundation
import ITGWorkoutKit

class ClientStub: Client {
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    private let stub: (URL) -> Client.Result
    
    init(stub: @escaping (URL) -> Client.Result) {
        self.stub = stub
    }
    
    func get(from path: String, completion: @escaping (Client.Result) -> Void) -> HTTPClientTask {
        completion(stub(URL(string: path)!))
        return Task()
    }
}

extension ClientStub {
    static var offline: ClientStub {
        ClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
    }

    static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> ClientStub {
        ClientStub { url in .success(stub(url)) }
    }
}
