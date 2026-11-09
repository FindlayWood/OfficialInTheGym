//
//  MyDayLoaderStub.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation
@testable import MyDayKit

/// Delivers one day, whatever date is asked for.
final class MyDayLoaderStub: MyDayLoader {

    private let day: MyDayFullDayModel?

    init(day: MyDayFullDayModel?) {
        self.day = day
    }

    func load<T: Codable>(for date: Date) async throws -> T? {
        day as? T
    }
}
