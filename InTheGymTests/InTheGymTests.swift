//
//  InTheGymTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 29/05/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import XCTest
@testable import InTheGym

class InTheGymTests: XCTestCase {
    var workoutTransform : TransformPost!
    var transformWorkout : TestData!
    var sut, other : workout!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        transformWorkout = TestData()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testStringToActivity(){
        
        let activity = TransformPost.activityTypeToString(of: postType.CompletedWorkout)
        XCTAssertEqual(activity, "Completed Workout")
        
    }
    
    func testActivityToString(){
        let activty = TransformPost.stringToActivityType(with: "Account Created")
        XCTAssertEqual(activty, postType.AccountCreated)
    }
    
    func testDataToWorkout(){
        let workout = TransformWorkout.toWorkoutType(from: TestData.exampleWorkout)
        let testTitle = workout.title
        let testScore = workout.score
        XCTAssertEqual(testTitle, transformWorkout.answer.title)
        XCTAssertEqual(testScore, transformWorkout.answer.score)
        
    }
    func testWorkoutsMatch(){
        sut = workout.create()
        other = workout.create()
        XCTAssertEqual(sut, other)
        XCTAssertEqual(other, sut)
    }
    
    func testDifferentTitlea(){
        sut = .create(title: "Leg Day")
        other = .create()
        XCTAssertNotEqual(sut, other)
        XCTAssertNotEqual(other, sut)
    }
    
    func testCreateWithDifferences(){
        sut = .create(title: "Upper", createdBy: "Me", liveWorkout: true, score: 9)
        other = .create(title: "Upper", createdBy: "Not me", liveWorkout: false, score: 7)
        XCTAssertNotEqual(sut, other)
        XCTAssertNotEqual(other, sut)
    }
    

}
