//
//  ScheduleDay+TestHelpers.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 08/11/2026.
//

import XCTest
@testable import MyDayKit

extension ScheduleDay {

    /// A day from a key the test knows is good. A typo fails the test that wrote it.
    static func fixture(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> ScheduleDay {
        guard let day = ScheduleDay(key: key) else {
            XCTFail("\(key) is not a day", file: file, line: line)
            return ScheduleDay(Date(timeIntervalSince1970: 0))
        }
        return day
    }
}
