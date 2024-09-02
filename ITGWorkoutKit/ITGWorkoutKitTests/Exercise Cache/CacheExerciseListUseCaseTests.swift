//
//  CacheExerciseListUseCaseTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 25/05/2024.
//

import XCTest
import ITGWorkoutKit

final class CacheExerciseListUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        
        let(_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestsCacheDeletion() {

        let (sut, store) = makeSUT()
        
        sut.save(uniqueItems().models) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        sut.save(uniqueItems().models) { _ in }
        
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = uniqueItems()
        let (sut, store) = makeSUT(currentDate: { timestamp })

        sut.save(items.models) { _ in }
        
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items.local, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {

        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_failsOnInsertionError() {
        
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()

        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = ExerciseStoreSpy()
        var sut: LocalExerciseLoader? = LocalExerciseLoader(store: store, currentDate: Date.init)

        var receivedResults = [LocalExerciseLoader.SaveResult]()
        sut?.save(uniqueItems().models) { receivedResults.append($0) }

        sut = nil
        store.completeDeletion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = ExerciseStoreSpy()
        var sut: LocalExerciseLoader? = LocalExerciseLoader(store: store, currentDate: Date.init)

        var receivedResults = [LocalExerciseLoader.SaveResult]()
        sut?.save(uniqueItems().models) { receivedResults.append($0) }

        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalExerciseLoader, store: ExerciseStoreSpy) {
        let store = ExerciseStoreSpy()
        let sut = LocalExerciseLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalExerciseLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")

        var receivedError: Error?
        sut.save(uniqueItems().models) { result in
            if case let Result.failure(error) = result { receivedError = error }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func uniqueItem() -> ExerciseItem {
        return ExerciseItem(id: UUID(), name: "any", bodyArea: "any")
    }
    
    private func uniqueItems() -> (models: [ExerciseItem], local: [LocalExerciseItem]) {
        let models = [uniqueItem(), uniqueItem()]
        let local = models.map { LocalExerciseItem(id: $0.id, name: $0.name, bodyArea: $0.bodyArea) }
        return (models, local)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
