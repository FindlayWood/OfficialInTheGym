//
//  WorkloadTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
@testable import InTheGym
import XCTest
import Combine

class WorkloadTests: XCTestCase {
    
    var sut: WorkloadChildViewModel!
    var mockService: MockFirebaseDatabaseManager!
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
        mockService = .init()
        sut = .init(apiService: mockService)
    }
    
    func testLoadWorkloads() {
  
    }
    
    
}
