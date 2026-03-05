//
//  ClipUploader.swift
//  MyDayKit
//
//  Created by Findlay Wood on 19/01/2026.
//

import Foundation

public protocol ClipUploader {
    func uploadClip(_ uploadData: ClipUploadData, onProgress: @escaping @Sendable (Double) async -> Void) async throws -> ClipUploadResult
}

actor MockClipUploader: ClipUploader {
    func uploadClip(_ uploadData: ClipUploadData, onProgress: @escaping @Sendable (Double) async -> Void) async throws -> ClipUploadResult {
        return ClipUploadResult(
            clipID: UUID().uuidString,
            exerciseID: UUID().uuidString,
            videoURL: URL(string: "")!,
            thumbnailURL: nil,
            uploadedAt: .now
        )
    }
}
