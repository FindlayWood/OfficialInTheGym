//
//  WellnessLoader.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/04/2026.
//

import Foundation

public protocol WellnessLoader {
    func load<T:Codable>(for date: Date) async throws -> T?
}

struct PreviewWellnessLoader: WellnessLoader {
    func load<T: Codable>(for date: Date) async throws -> T? {
        return nil
    }
}
