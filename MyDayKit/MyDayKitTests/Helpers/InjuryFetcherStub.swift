//
//  InjuryFetcherStub.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation
@testable import MyDayKit

final class InjuryFetcherStub: InjuryFetching {

    private let result: Result<[Injury], Error>

    init(_ result: Result<[Injury], Error> = .success([])) {
        self.result = result
    }

    func fetchAll() async throws -> [Injury] {
        try result.get()
    }
}
