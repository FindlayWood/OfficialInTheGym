//
//  WorkoutCreationTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 13/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
@testable import InTheGym
import XCTest
import Combine

class WorkoutCreationTests: XCTestCase {
    
    var sut: WorkoutCreationViewModel!
    var mockService: MockFirebaseDatabaseManager!
    
    var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
        mockService = .init()
        sut = .init(apiService: mockService)
    }
    
    func testUpdatingToValidTitle() {
        let exception = XCTestExpectation(description: "Waiting for publisher to emit values.")
        let testTitleString = "valid_test_title"
        
        sut.$workoutTitle
            .dropFirst()
            .sink { result in
                XCTAssertEqual(result, testTitleString)
                exception.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.updateTitle(with: testTitleString)
        
        wait(for: [exception], timeout: 5)
    }
    
    func testAddingExercise() {
        let exception = XCTestExpectation(description: "Waiting for publisher to emit values.")
        let exampleExercise = ExerciseModel(exercise: "test", type: .CU)
        
        sut.exercises
            .dropFirst()
            .sink { result in
                XCTAssertEqual(result.count, 1)
                exception.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.addExercise(exampleExercise)
        
        wait(for: [exception], timeout: 5)
        
    }
    
    func testAddingCircuit() {
        let exception = XCTestExpectation(description: "Waiting for publisher to emit values.")
        let exampleCircuit = CircuitModel(circuitPosition: 0, workoutPosition: 0, exercises: [], completed: false, circuitName: "", createdBy: "", creatorID: "", integrated: true)
        
        sut.exercises
            .dropFirst()
            .sink { result in
                XCTAssertEqual(result.count, 1)
                exception.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.addCircuit(exampleCircuit)
        
        wait(for: [exception], timeout: 5)
        
    }
    
    func testAddingAMRAP() {
        let exception = XCTestExpectation(description: "Waiting for publisher to emit values.")
        let exampleAmrap = AMRAPModel(amrapPosition: 0, workoutPosition: 0, timeLimit: 0, exercises: [], completed: false, roundsCompleted: 0, exercisesCompleted: 0, started: false)
        
        sut.exercises
            .dropFirst()
            .sink { result in
                XCTAssertEqual(result.count, 1)
                exception.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.addAMRAP(exampleAmrap)
        
        wait(for: [exception], timeout: 5)
        
    }
}
