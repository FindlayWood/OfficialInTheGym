//
//  DisplayEMOMTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 26/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import XCTest
@testable import InTheGym

class DisplayEMOMTests: XCTestCase {

    var sut: DisplayEMOMViewModel!
    var mockService: MockFirebaseEMOMService!
    
    override func setUp() {
        mockService = .init()
        sut = .init(apiService: mockService)
        sut.position = 0
        sut.workout = .init(object: [:])
    }
    
    func testStartingEmom() {
        sut.startEMOM()
        
        XCTAssertTrue(sut.successfullyStartedEMOM)
        XCTAssertNil(sut.errorStarting)
    }
    
    func testCompletingEMOM() {
        sut.emomCompleted()
        
        XCTAssertTrue(sut.successfullyCompletedEMOM)
        XCTAssertNil(sut.errorCompleting)
    }
    
    func testUploadingRPE() {
        sut.rpeScoreGiven(0)
        
        XCTAssertTrue(sut.successfullyUploadedRPEScore)
        XCTAssertNil(sut.errorUploadingScore)
    }
}
