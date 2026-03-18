//
//  XCTestCase+FailableInsertExerciseStoreSpecs.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 26/05/2024.
//

import XCTest
import ITGWorkoutKit

extension FailableInsertExerciseStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueItemList().local, Date()), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueItemList().local, Date()), to: sut)

        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
