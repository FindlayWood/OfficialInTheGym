//
//  WellnessSaver.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/04/2026.
//

import Foundation

public protocol WellnessSaver {
    func save<T:Codable>(data: T) async throws
}

struct PreviewWellnessSaver: WellnessSaver {
    func save<T:Codable>(data: T) async throws {
        print("Saving: \(data)")
    }
}
