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

protocol WorkoutUploader {
    typealias Result = Swift.Result<UploadWorkoutModel, Error>
    
    func upload(_ model: UploadWorkoutModel, completion: @escaping (Error?) -> Void)
}

struct UploadWorkoutModel {
    let title: String
    let exercises: [ExerciseModel]
    let tags: [TagModel]
    let isPublic: Bool
    let savedID: String
    let createdByID: String
    let id: String
}

final class WorkoutBuilderTests: XCTestCase {

    func test_init_titleIsEmpty() {
        let (_, sut) = makeSUT()
        
        XCTAssertEqual(sut.title, "")
    }
    
    func test_init_exerciseListIsEmpty() {
        let (_, sut) = makeSUT()
        
        XCTAssertEqual(sut.exercises.count, 0)
    }
    
    func test_init_savingSelectedByDefault() {
        let (_, sut) = makeSUT()
        
        XCTAssertTrue(sut.isSaving)
    }
    
    func test_init_privacySetToPublicByDefault() {
        let (_, sut) = makeSUT()
        
        XCTAssertTrue(sut.isPublic)
    }
    
    func test_init_tagListIsEmpty() {
        let (_, sut) = makeSUT()
        
        XCTAssertEqual(sut.tags.count, 0)
    }
    
    func test_updateTitle_updatesTitle() {
        let (_, sut) = makeSUT()
        
        let newTitle = "New Title"
        
        sut.updateTitle(newTitle)
        
        XCTAssertEqual(sut.title, newTitle)
    }
    
    func test_addTag_addsTagToList() {
        let (_, sut) = makeSUT()
        
        let newTag = TagModel()
        
        sut.addTag(newTag)
        
        XCTAssertEqual(sut.tags.count, 1)
    }

    func test_addTag_willNotAddMoreThanMaxLimit() {
        let (_, sut) = makeSUT()
        
        for _ in (0..<sut.maxTagCount + 1) {
            let newTag = TagModel()
            
            sut.addTag(newTag)
        }

        XCTAssertEqual(sut.tags.count, sut.maxTagCount)
    }
    
    func test_addExercise_addsExerciseToExerciseList() {
        let (_, sut) = makeSUT()
        
        sut.addExercise(ExerciseModel())
        
        XCTAssertEqual(sut.exercises.count, 1)
    }
    
    func test_updatePrivacy_willUpdatePrivacyToSelected() {
        let (_, sut) = makeSUT()
        
        sut.updatePrivacy(false)
        
        XCTAssertFalse(sut.isPublic)
        
        sut.updatePrivacy(true)
        
        XCTAssertTrue(sut.isPublic)
    }
    
    func test_updateSaving_willUpdateSavingToSelected() {
        let (_, sut) = makeSUT()
        
        sut.updateSaving(false)
        
        XCTAssertFalse(sut.isSaving)
        
        sut.updateSaving(true)
        
        XCTAssertTrue(sut.isSaving)
    }
    
    func test_createWorkout_returnsErrorofNoExercises() {
        let (_, sut) = makeSUT()
        
        sut.createWorkout()
        
        XCTAssertTrue(sut.creationErrors.contains(.noExercises))
    }
    
    func test_createWorkout_returnsNonoExerciseErrorWhenExerciseListIsNotEmpty() {
        let (_, sut) = makeSUT()
        
        sut.addExercise(ExerciseModel())
        
        sut.createWorkout()
        
        XCTAssertFalse(sut.creationErrors.contains(.noExercises))
    }
    
    func test_createWorkout_returnsErrorWhenTitleIsEmpty() {
        
        let samples = ["a", "  ", "a b", ""]
        
        samples.enumerated().forEach { _, title in
            
            let (_, sut) = makeSUT()
            
            sut.updateTitle(title)
            
            sut.createWorkout()
            
            XCTAssertTrue(sut.creationErrors.contains(.noTitle))
        }
    }
    
    func test_createWorkout_doesNotReturnsNoTitleErrorWhenTitleIsFourCharacters() {
        
        let samples = ["abcd", "    ", "a bc", "title long"]
        
        samples.enumerated().forEach { _, title in
            
            let (_, sut) = makeSUT()
            
            sut.updateTitle(title)
            
            sut.createWorkout()
            
            XCTAssertFalse(sut.creationErrors.contains(.noTitle))
        }
    }
    
    func test_createWorkout_returnsNoErrorsWhenCriteriaMet() {
        let (_, sut) = makeSUT()
        
        sut.addExercise(ExerciseModel())
        
        sut.updateTitle("title")
        
        sut.createWorkout()
        
        XCTAssertTrue(sut.creationErrors.isEmpty)
    }
    
    func test_init_doesNotRequestToCreateWorkout() {
        let (client, _) = makeSUT()
        
        XCTAssertTrue(client.requestedPaths.isEmpty)
    }
    
    func test_upload_requestsToCreateWorkout() {
        let model = makeUploadModel()
        let (client, sut) = makeSUT()
        
        sut.upload(model: model) { _ in }
        
        XCTAssertEqual(client.requestedPaths, [model.id])
    }
    
    func test_uploadTwice_requestsToCreateWorkoutTwice() {
        let model = makeUploadModel()
        let (client, sut) = makeSUT()
        
        sut.upload(model: model) { _ in }
        sut.upload(model: model) { _ in }
        
        XCTAssertEqual(client.requestedPaths, [model.id, model.id])
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (WorkoutUploaderSpy, WorkoutBuilder) {
        let uploader = WorkoutUploaderSpy()
        let workoutBuilder = WorkoutBuilder(uploader: uploader)
        return (uploader, workoutBuilder)
    }
    
    private func makeUploadModel() -> UploadWorkoutModel {
        UploadWorkoutModel(title: "Title", exercises: [], tags: [], isPublic: true, savedID: UUID().uuidString, createdByID: UUID().uuidString, id: UUID().uuidString)
    }
    
    private class WorkoutUploaderSpy: WorkoutUploader {
        
        private var messages = [(model: UploadWorkoutModel, completion: (Error?) -> Void)]()
        
        var requestedPaths: [String] {
            messages.map { $0.model.id }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
        
        func complete(withModel model: UploadWorkoutModel, at index: Int = 0) {
            messages[index].completion(nil)
        }
        
        func upload(_ model: UploadWorkoutModel, completion: @escaping (Error?) -> Void) {
            messages.append((model, completion))
        }
    }
}


private class WorkoutBuilder {
    let uploader: WorkoutUploader
    
    init(uploader: WorkoutUploader) {
        self.uploader = uploader
    }
    
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
    
    func upload(model: UploadWorkoutModel, completion: @escaping (Error?) -> Void) {
        uploader.upload(model, completion: completion)
    }
}
