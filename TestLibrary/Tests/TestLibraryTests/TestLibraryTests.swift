import XCTest
@testable import TestLibrary

final class TestLibraryTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TestLibrary().text, "Hello, World!")
    }
}
