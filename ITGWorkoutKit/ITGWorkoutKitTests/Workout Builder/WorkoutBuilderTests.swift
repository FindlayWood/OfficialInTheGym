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
    var tags: [TagModel] = []
    let isSaving: Bool = true
    var isPublic: Bool = true
    
    func updateTitle(_ newTitle: String) {
        title = newTitle
    }
        
    var maxTagCount: Int {
        10
    }
    
    func addTag(_ newTag: TagModel) {
        if tags.count < maxTagCount {
            tags.append(newTag)
        }
    }
    
    func updatePrivacy(_ newIsPublic: Bool) {
        isPublic = newIsPublic
    }

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
    
    func test_updateTitle_updatesTitle() {
        let sut = WorkoutBuilder()
        
        let newTitle = "New Title"
        
        sut.updateTitle(newTitle)
        
        XCTAssertEqual(sut.title, newTitle)
    }
    
    func test_addTag_addsTagToList() {
        let sut = WorkoutBuilder()
        
        let newTag = TagModel()
        
        sut.addTag(newTag)
        
        XCTAssertEqual(sut.tags.count, 1)
    }

    func test_addTag_willNotAddMoreThanMaxLimit() {
        let sut = WorkoutBuilder()
        
        for _ in (0..<sut.maxTagCount + 1) {
            let newTag = TagModel()
            
            sut.addTag(newTag)
        }

        XCTAssertEqual(sut.tags.count, sut.maxTagCount)
    }
    
    func test_updatePrivacy_willUpdatePrivacyToSelected() {
        let sut = WorkoutBuilder()
        
        sut.updatePrivacy(false)
        
        XCTAssertFalse(sut.isPublic)
        
        sut.updatePrivacy(true)
        
        XCTAssertTrue(sut.isPublic)
    }
}
