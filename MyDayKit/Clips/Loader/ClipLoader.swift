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
    /// Optional because it is not always written. `ThumbnailUploadDecorator` only uploads a
    /// thumbnail when one could be generated, and otherwise the document stores `null` — which a
    /// non-optional `String` cannot decode, so that clip failed to load at all.
    let thumbnailURL: String?
    let uploadedAt: Date
    let exerciseID: String
    let isPrivate: Bool
//    let videoMetaData: ClipUploadData.VideoMetadata
    let userID: String
}
