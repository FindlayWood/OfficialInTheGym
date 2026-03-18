//
//  UploadError.swift
//  MyDayKit
//
//  Created by Findlay Wood on 28/01/2026.
//

import Foundation

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
