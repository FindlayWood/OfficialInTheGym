//
//  SharedTestHelpers.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// An arbitrary error, for a test that only needs something to throw. One shared value rather
/// than one per file — `ScheduleManagerTests` and `MyDaySportManagerTests` still carry their own
/// `private` copies, which shadow this.
func anyNSError() -> NSError {
    NSError(domain: "test", code: 0)
}
