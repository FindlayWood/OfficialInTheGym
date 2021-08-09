//
//  ClipTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 07/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import XCTest
@testable import InTheGym

class ClipTests: XCTestCase {
    
    var clipData: [clipDataModel]!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        clipData = TestData.clipsArray
    }
    
    func testToObjectMethod() {
        for item in clipData {
            print(item.toObject())
        }
    }

}
