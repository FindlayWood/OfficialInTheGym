//
//  ScheduleFetcherStub.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation
@testable import MyDayKit

final class ScheduleFetcherStub: ScheduleFetching {

    private let result: Result<[Schedule], Error>

    init(_ result: Result<[Schedule], Error> = .success([])) {
        self.result = result
    }

    func fetchAll() async throws -> [Schedule] {
        try result.get()
    }
}
