//
//  DataUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/01/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import MyDayKit

// MARK: - Upload Error
enum UploadError: LocalizedError {
    case invalidData
    case uploadCancelled
    case noDownloadURL
    case storageError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid file data"
        case .uploadCancelled:
            return "Upload was cancelled"
        case .noDownloadURL:
            return "Failed to get download URL"
        case .storageError(let error):
            return "Storage error: \(error.localizedDescription)"
        }
    }
}


public final class FirestoreMetadataDecorator: ClipUploader {
    
    private let wrapped: ClipUploader

    public init(wrapped: ClipUploader) {
        self.wrapped = wrapped
    }

    public func uploadClip(_ uploadData: ClipUploadData, onProgress: @escaping @Sendable (Double) async -> Void) async throws -> ClipUploadResult {

        let result = try await wrapped.uploadClip(uploadData, onProgress: onProgress)

        let db = Firestore.firestore()
        try await db
            .collection("TestClips")
            .document(result.clipID)
            .setData([
                "clipID": result.clipID,
                "videoURL": result.videoURL.absoluteString,
                "thumbnailURL": result.thumbnailURL?.absoluteString as Any,
                "uploadedAt": result.uploadedAt,
                "exerciseID": uploadData.exerciseID,
                "isPrivate": uploadData.isPrivate,
                "videoMetaData": uploadData.videoMetadata.customMetadata,
                "userID": uploadData.userID
            ])

        return result
    }
}

public struct FirebaseStorageClipUploader: ClipUploader {

    public func uploadClip(_ uploadData: ClipUploadData, onProgress: @escaping @Sendable (Double) async -> Void) async throws -> ClipUploadResult {

        let storage = Storage.storage()
        
        let path = "TestClips/\(uploadData.userID)/\(uploadData.clipID)"
        
        let ref = storage.reference().child(path)
        
        let metadata = StorageMetadata()
        metadata.contentType = uploadData.videoMetadata.contentType
        
        return try await withCheckedThrowingContinuation { continuation in
            
            let task = ref.putData(uploadData.videoData, metadata: metadata)
            
            // Observe progress
            task.observe(.progress) { snapshot in
                if let progress = snapshot.progress {
                    let percent = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                    Task { await onProgress(percent) }
                }
            }
            
            // Observe success
            task.observe(.success) { _ in
                ref.downloadURL {
                    url,
                    error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let url = url else {
                        continuation.resume(throwing: UploadError.noDownloadURL)
                        return
                    }
                    
                    let result = ClipUploadResult(
                        clipID: uploadData.clipID,
                        exerciseID: uploadData.exerciseID,
                        videoURL: url,
                        thumbnailURL: nil,
                        uploadedAt: Date()
                    )
                    continuation.resume(returning: result)
                }
            }
            
            // Observe failure
            task.observe(.failure) { snapshot in
                if let error = snapshot.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: UploadError.uploadCancelled)
                }
            }
        }
    }
}

// 2. Thumbnail uploader decorator
public struct ThumbnailUploadDecorator: ClipUploader {
    private let baseUploader: ClipUploader
    
    public init(wrapping uploader: ClipUploader) {
        self.baseUploader = uploader
    }
    
    public func uploadClip(
        _ uploadData: ClipUploadData,
        onProgress: @escaping @Sendable (Double) async -> Void
    ) async throws -> ClipUploadResult {
        
        // First, upload the video using the base uploader
        let videoResult = try await baseUploader.uploadClip(uploadData, onProgress: onProgress)
        
        // Then upload thumbnail if it exists
        if let thumbnailData = uploadData.thumbnailData {
            let storage = Storage.storage()
            let thumbnailPath = "TestClipThumbnails/\(uploadData.userID)/\(uploadData.clipID)"
            let thumbnailRef = storage.reference().child(thumbnailPath)
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            _ = try await thumbnailRef.putDataAsync(thumbnailData, metadata: metadata)
            
            // Optionally get the thumbnail URL
            let thumbnailURL = try await thumbnailRef.downloadURL()
            
            // Return updated result with thumbnail URL
            return ClipUploadResult(
                clipID: videoResult.clipID,
                exerciseID: videoResult.exerciseID,
                videoURL: videoResult.videoURL,
                thumbnailURL: thumbnailURL,
                uploadedAt: videoResult.uploadedAt
            )
        }
        
        // No thumbnail, return original result
        return videoResult
    }
}
