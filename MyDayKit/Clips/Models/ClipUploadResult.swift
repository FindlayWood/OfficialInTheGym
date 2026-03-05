//
//  ClipUploadResult.swift
//  MyDayKit
//
//  Created by Findlay Wood on 28/01/2026.
//

import Foundation

/// Result of a successful clip upload
public struct ClipUploadResult: Hashable {
    public let clipID: String
    public let exerciseID: String
    public let videoURL: URL
    public var thumbnailURL: URL?
    public let uploadedAt: Date
    
    public init(clipID: String, exerciseID: String, videoURL: URL, thumbnailURL: URL?, uploadedAt: Date) {
        self.clipID = clipID
        self.exerciseID = exerciseID
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.uploadedAt = uploadedAt
    }
}
