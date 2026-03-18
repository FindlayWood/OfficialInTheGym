//
//  ClipManagerError.swift
//  MyDayKit
//
//  Created by Findlay Wood on 28/01/2026.
//

import Foundation

// MARK: - Clip Manager Error
enum ClipManagerError: LocalizedError {
    case invalidUserId
    case invalidClipId
    case videoUploadFailed(Error)
    case uploadCancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidUserId:
            return "User ID cannot be empty"
        case .invalidClipId:
            return "Clip ID cannot be empty"
        case .videoUploadFailed(let error):
            return "Video upload failed: \(error.localizedDescription)"
        case .uploadCancelled:
            return "Upload was cancelled"
        }
    }
}
