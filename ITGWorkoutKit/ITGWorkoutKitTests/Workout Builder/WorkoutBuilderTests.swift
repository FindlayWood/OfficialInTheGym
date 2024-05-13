//
//  WorkoutBuilderTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 13/05/2024.
//

import XCTest

class WorkoutBuilder {
    var title: String = ""
    
}

final class WorkoutBuilderTests: XCTestCase {

    func test_init_titleIsEmpty() {
        let sut = WorkoutBuilder()
        
        XCTAssertEqual(sut.title, "")
    }

}
