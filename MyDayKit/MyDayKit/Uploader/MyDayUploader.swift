//
//  MyDayUploader.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/09/2025.
//

import Foundation

public protocol MyDayRemoteUploader {
    func upload<T:Codable>(data: T, at path: String) async throws
}

