//
//  MyDaySaver.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/09/2025.
//

import Foundation

public protocol MyDaySaver {
    func save<T:Codable>(data: T) async throws
}

struct PreviewSaver: MyDaySaver {
    func save<T:Codable>(data: T) async throws {
        print("Saving: \(data)")
    }
}
