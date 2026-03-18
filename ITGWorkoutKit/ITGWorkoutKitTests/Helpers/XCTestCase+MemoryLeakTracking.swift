//
//  XCTestCase+MemoryLeakTracking.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 05/04/2024.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
