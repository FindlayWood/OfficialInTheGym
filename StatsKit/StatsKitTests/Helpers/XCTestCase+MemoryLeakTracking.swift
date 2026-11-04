//
//  XCTestCase+MemoryLeakTracking.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 02/11/2026.
//

import XCTest

extension XCTestCase {

    /// Fails the test if `instance` is still alive once the test has torn down.
    ///
    /// **Call it in `makeSUT` on the subject and on every collaborator it holds**, forwarding
    /// `file:` / `line:` so a leak is reported at the test that built it. A view model that
    /// captures `self` strongly in a closure or a stored `Task` outlives its screen, keeps
    /// listening and keeps writing; nothing on screen ever shows it, and this is the only check
    /// that does. Copied from ITGWorkoutKit's suite (now on `archive/itgworkoutkit`), which set the
    /// pattern; each framework's suite is its own module, so each carries its own copy.
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
