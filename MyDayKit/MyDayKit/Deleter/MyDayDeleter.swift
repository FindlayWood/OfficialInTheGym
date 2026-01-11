//
//  MyDayDeleter.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/01/2026.
//

import Foundation

public protocol MyDayDeleter {
    func delete(at path: String) async throws
}

struct PreviewMyDayDeleter: MyDayDeleter {
    func delete(at path: String) async throws {
        print("Deleting")
    }
}
