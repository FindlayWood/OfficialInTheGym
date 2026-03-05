//
//  ClipUploadData.swift
//  MyDayKit
//
//  Created by Findlay Wood on 28/01/2026.
//

import Foundation

/// Data required to upload a clip to storage
public struct ClipUploadData: Codable {
    public let videoData: Data
    public let thumbnailData: Data?
    public let userID: String
    public let clipID: String  // Pre-generated ID for consistent paths
    public let exerciseID: String
    public let isPrivate: Bool
    
    // Metadata for the storage upload
    public let videoMetadata: VideoMetadata
    
    public struct VideoMetadata: Codable {
        public let contentType: String  // e.g., "video/mp4", "video/quicktime"
        let duration: TimeInterval
        let width: Int?
        let height: Int?
        let fileSize: Int64
        let codec: String?  // e.g., "h264", "hevc"
        
        // Custom metadata that might be useful
        public var customMetadata: [String: String] {
            var metadata: [String: String] = [
                "contentType": contentType,
                "duration": String(duration),
                "fileSize": String(fileSize)
            ]
            
            if let width = width, let height = height {
                metadata["resolution"] = "\(width)x\(height)"
            }
            
            if let codec = codec {
                metadata["codec"] = codec
            }
            
            return metadata
        }
    }
}
