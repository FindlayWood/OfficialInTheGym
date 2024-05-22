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

final class WorkoutBuilderTests: XCTestCase {

    func test_init_titleIsEmpty() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.title, "")
    }
    
    func test_init_exerciseListIsEmpty() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.exercises.count, 0)
    }
    
    func test_init_savingSelectedByDefault() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isSaving)
    }
    
    func test_init_privacySetToPublicByDefault() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isPublic)
    }
    
    func test_init_tagListIsEmpty() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.tags.count, 0)
    }
    
    func test_updateTitle_updatesTitle() {
        let sut = makeSUT()
        
        let newTitle = "New Title"
        
        sut.updateTitle(newTitle)
        
        XCTAssertEqual(sut.title, newTitle)
    }
    
    func test_addTag_addsTagToList() {
        let sut = makeSUT()
        
        let newTag = TagModel()
        
        sut.addTag(newTag)
        
        XCTAssertEqual(sut.tags.count, 1)
    }

    func test_addTag_willNotAddMoreThanMaxLimit() {
        let sut = makeSUT()
        
        for _ in (0..<sut.maxTagCount + 1) {
            let newTag = TagModel()
            
            sut.addTag(newTag)
        }

        XCTAssertEqual(sut.tags.count, sut.maxTagCount)
    }
    
    func test_addExercise_addsExerciseToExerciseList() {
        let sut = makeSUT()
        
        sut.addExercise(ExerciseModel())
        
        XCTAssertEqual(sut.exercises.count, 1)
    }
    
    func test_updatePrivacy_willUpdatePrivacyToSelected() {
        let sut = makeSUT()
        
        sut.updatePrivacy(false)
        
        XCTAssertFalse(sut.isPublic)
        
        sut.updatePrivacy(true)
        
        XCTAssertTrue(sut.isPublic)
    }
    
    func test_updateSaving_willUpdateSavingToSelected() {
        let sut = makeSUT()
        
        sut.updateSaving(false)
        
        XCTAssertFalse(sut.isSaving)
        
        sut.updateSaving(true)
        
        XCTAssertTrue(sut.isSaving)
    }
    
    func test_createWorkout_returnsErrorofNoExercises() {
        let sut = makeSUT()
        
        sut.createWorkout()
        
        XCTAssertTrue(sut.creationErrors.contains(.noExercises))
    }
    
    func test_createWorkout_returnsNonoExerciseErrorWhenExerciseListIsNotEmpty() {
        let sut = makeSUT()
        
        sut.addExercise(ExerciseModel())
        
        sut.createWorkout()
        
        XCTAssertFalse(sut.creationErrors.contains(.noExercises))
    }
    
    func test_createWorkout_returnsErrorWhenTitleIsEmpty() {
        
        let samples = ["a", "  ", "a b", ""]
        
        samples.enumerated().forEach { _, title in
            
            let sut = makeSUT()
            
            sut.updateTitle(title)
            
            sut.createWorkout()
            
            XCTAssertTrue(sut.creationErrors.contains(.noTitle))
        }
    }
    
    func test_createWorkout_doesNotReturnsNoTitleErrorWhenTitleIsFourCharacters() {
        
        let samples = ["abcd", "    ", "a bc", "title long"]
        
        samples.enumerated().forEach { _, title in
            
            let sut = makeSUT()
            
            sut.updateTitle(title)
            
            sut.createWorkout()
            
            XCTAssertFalse(sut.creationErrors.contains(.noTitle))
        }
    }
    
    func test_createWorkout_returnsNoErrorsWhenCriteriaMet() {
        let sut = makeSUT()
        
        sut.addExercise(ExerciseModel())
        
        sut.updateTitle("title")
        
        sut.createWorkout()
        
        XCTAssertTrue(sut.creationErrors.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> WorkoutBuilder {
        return WorkoutBuilder()
    }
    
    private class WorkoutBuilder {
        var title: String = ""
        var exercises: [ExerciseModel] = []
        var tags: [TagModel] = []
        var isSaving: Bool = true
        var isPublic: Bool = true
        
        var creationErrors: [CreateWorkoutError] = []
        
        enum CreateWorkoutError {
            case noExercises
            case noTitle
        }
        
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

        func updateSaving(_ newIsSaving: Bool) {
            isSaving = newIsSaving
        }
        
        func addExercise(_ model: ExerciseModel) {
            exercises.append(model)
        }
        
        func createWorkout() {
            if exercises.isEmpty {
                creationErrors.append(.noExercises)
            }
            if title.count < 4 {
                creationErrors.append(.noTitle)
            }
        }
    }
}
