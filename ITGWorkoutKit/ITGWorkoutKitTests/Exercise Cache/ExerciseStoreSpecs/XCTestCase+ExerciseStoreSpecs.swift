//
//  XCTestCase+ExerciseStoreSpecs.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 26/05/2024.
//

import XCTest
import ITGWorkoutKit

extension ExerciseStoreSpecs where Self: XCTestCase {

    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        let list = uniqueItemList().local
        let timestamp = Date()

        insert((list, timestamp), to: sut)

        expect(sut, toRetrieve: .success(CachedExerciseList(list: list, timestamp: timestamp)), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        let list = uniqueItemList().local
        let timestamp = Date()

        insert((list, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .success(CachedExerciseList(list: list, timestamp: timestamp)), file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueItemList().local, Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueItemList().local, Date()), to: sut)

        let insertionError = insert((uniqueItemList().local, Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
    }

    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueItemList().local, Date()), to: sut)

        let latestList = uniqueItemList().local
        let latestTimestamp = Date()
        insert((latestList, latestTimestamp), to: sut)

        expect(sut, toRetrieve: .success(CachedExerciseList(list: latestList, timestamp: latestTimestamp)), file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueItemList().local, Date()), to: sut)

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
    }

    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueItemList().local, Date()), to: sut)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatSideEffectsRunSerially(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        var completedOperationsInOrder = [XCTestExpectation]()

        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueItemList().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedList { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueItemList().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
    }

}

extension ExerciseStoreSpecs where Self: XCTestCase {
    
    @discardableResult
    func insert(_ cache: (list: [LocalExerciseItem], timestamp: Date), to sut: ExerciseStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.list, timestamp: cache.timestamp) { result in
            if case let Result.failure(error) = result { insertionError = error }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: ExerciseStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedList { result in
            if case let Result.failure(error) = result { deletionError = error }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    func expect(_ sut: ExerciseStore, toRetrieveTwice expectedResult: ExerciseStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: ExerciseStore, toRetrieve expectedResult: ExerciseStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.success(.none), .success(.none)),
                (.failure, .failure):
                break

            case let (.success(.some(expected)), .success(.some(retrieved))):
                XCTAssertEqual(retrieved.list, expected.list, file: file, line: line)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)

            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
