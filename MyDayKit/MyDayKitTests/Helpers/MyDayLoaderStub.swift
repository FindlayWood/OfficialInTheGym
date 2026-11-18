//
//  MyDayLoaderStub.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation
@testable import MyDayKit

/// Delivers one day, whatever date is asked for, or throws `error` when one is set.
final class MyDayLoaderStub: MyDayLoader {

    private let day: MyDayFullDayModel?
    private let error: Error?

    init(day: MyDayFullDayModel?, error: Error? = nil) {
        self.day = day
        self.error = error
    }

    func load<T: Codable>(for date: Date) async throws -> T? {
        if let error { throw error }
        return day as? T
    }
}
