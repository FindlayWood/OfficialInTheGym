//
//  WorkoutBuilderTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 13/05/2024.
//

import XCTest

struct ExerciseModel {
    
}

struct TagModel {
    
}

class WorkoutBuilder {
    var title: String = ""
    let exercises: [ExerciseModel] = []
    let tags: [TagModel] = []
    let isSaving: Bool = true
    let isPublic: Bool = true
}

final class WorkoutBuilderTests: XCTestCase {

    func test_init_titleIsEmpty() {
        let sut = WorkoutBuilder()
        
        XCTAssertEqual(sut.title, "")
    }
    
    func test_init_exerciseListIsEmpty() {
        let sut = WorkoutBuilder()
        
        XCTAssertEqual(sut.exercises.count, 0)
    }
    
    func test_init_savingSelectedByDefault() {
        let sut = WorkoutBuilder()
        
        XCTAssertTrue(sut.isSaving)
    }
    
    func test_init_privacySetToPublicByDefault() {
        let sut = WorkoutBuilder()
        
        XCTAssertTrue(sut.isPublic)
    }
    
    func test_init_tagListIsEmpty() {
        let sut = WorkoutBuilder()
        
        XCTAssertEqual(sut.tags.count, 0)
    }

}
