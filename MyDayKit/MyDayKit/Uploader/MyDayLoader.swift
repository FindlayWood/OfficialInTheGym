//
//  MyDayLoader.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/09/2025.
//

import Foundation

public protocol MyDayLoader {
    func load<T:Codable>(for date: Date) async throws -> T?
}

struct PreviewLoader: MyDayLoader {
    func load<T: Codable>(for date: Date) async throws -> T? {
        return nil
    }
}
