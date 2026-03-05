//
//  ClipLoader.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/02/2026.
//

import Foundation

public protocol ClipLoader {
    func loadClip(with id: String) async throws -> Clip
}

public struct Clip: Codable {
    let clipID: String
    let videoURL: String
    let thumbnailURL: String
    let uploadedAt: Date
    let exerciseID: String
    let isPrivate: Bool
//    let videoMetaData: ClipUploadData.VideoMetadata
    let userID: String
}
