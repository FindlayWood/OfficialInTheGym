//
//  WorkoutTemplateUploaders.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/06/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MyDayKit

// MARK: - Firestore Uploader

public final class FirestoreWorkoutTemplateUploader: WorkoutTemplateUploading {

    public init() {}

    public func upload(_ template: WorkoutTemplateModel) async throws {
        let db = Firestore.firestore()
        let docRef = db
            .collection("Users/\(template.createdBy)/WorkoutTemplates")
            .document(template.id)
        try await docRef.setData(from: template)
    }
}

// MARK: - FileManager Uploader

/// Saves the template as a JSON file in the app's Documents directory.
/// Path: Documents/WorkoutTemplates/{userId}/{id}.json
///
/// `userId` is the signed-in user rather than `template.createdBy`, so a
/// template written on someone else's behalf still lands in the library of
/// whoever is using the device. See `WorkoutTemplateStoreLocation` for why the
/// directory is scoped at all.
public final class FileManagerWorkoutTemplateUploader: WorkoutTemplateUploading {

    private let encoder: JSONEncoder
    private let directory: URL

    public init(userId: String) {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        directory = WorkoutTemplateStoreLocation.directory(for: userId)
    }

    public func upload(_ template: WorkoutTemplateModel) async throws {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try encoder.encode(template)
            let fileURL = directory.appendingPathComponent("\(template.id).json")
            try data.write(to: fileURL, options: .atomicWrite)
        } catch let error as EncodingError {
            throw WorkoutTemplateUploadError.encodingFailed(error)
        } catch {
            throw WorkoutTemplateUploadError.storageFailed(error)
        }
    }
}

// MARK: - UserDefaults Uploader

/// Saves the template to UserDefaults under the key `workoutTemplates`.
/// Stores a dictionary keyed by template ID so individual entries can be overwritten.
public final class UserDefaultsWorkoutTemplateUploader: WorkoutTemplateUploading {

    private let defaults: UserDefaults
    private let storageKey = "workoutTemplates"
    private let encoder: JSONEncoder

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    public func upload(_ template: WorkoutTemplateModel) async throws {
        do {
            let encoded = try encoder.encode(template)
            var store = defaults.dictionary(forKey: storageKey) ?? [:]
            store[template.id] = encoded
            defaults.set(store, forKey: storageKey)
        } catch let error as EncodingError {
            throw WorkoutTemplateUploadError.encodingFailed(error)
        } catch {
            throw WorkoutTemplateUploadError.storageFailed(error)
        }
    }
}
