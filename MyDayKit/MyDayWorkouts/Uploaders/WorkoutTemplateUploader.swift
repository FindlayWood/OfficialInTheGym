//
//  WorkoutTemplateUploader.swift
//  MyDayKit
//
//  Created by Findlay Wood on 03/06/2026.
//

import Foundation

// MARK: - Protocol

public protocol WorkoutTemplateUploading {
    /// Persist a single workout template. Throws on failure.
    func upload(_ template: WorkoutTemplateModel) async throws
}

// MARK: - Errors

public enum WorkoutTemplateUploadError: LocalizedError {
    case encodingFailed(Error)
    case storageFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .encodingFailed(let e):  return "Failed to encode workout: \(e.localizedDescription)"
        case .storageFailed(let e):   return "Upload failed: \(e.localizedDescription)"
        }
    }
}

struct PreviewWorkoutTemplateUploading: WorkoutTemplateUploading {
    
    func upload(_ template: WorkoutTemplateModel) async throws {
        
    }
}
