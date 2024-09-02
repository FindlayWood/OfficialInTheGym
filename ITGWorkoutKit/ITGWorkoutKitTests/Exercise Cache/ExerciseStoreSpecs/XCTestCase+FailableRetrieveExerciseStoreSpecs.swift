//
//  XCTestCase+FailableRetrieveExerciseStoreSpecs.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 26/05/2024.
//

import XCTest
import ITGWorkoutKit

extension FailableRetrieveExerciseStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: ExerciseStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
    }
}
