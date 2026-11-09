//
//  ScheduleFetcherSpy.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation
@testable import MyDayKit

final class ScheduleFetcherSpy: ScheduleFetching {

    private(set) var fetchCount = 0
    private let result: Result<[Schedule], Error>

    init(_ result: Result<[Schedule], Error>) {
        self.result = result
    }

    func fetchAll() async throws -> [Schedule] {
        fetchCount += 1
        return try result.get()
    }
}
