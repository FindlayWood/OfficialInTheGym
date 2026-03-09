//
//  MyDayKitComposition.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/08/2025.
//  Copyright © 2025 FindlayWood. All rights reserved.
//

import UIKit
import MyDayKit
import SwiftUI

class MyDayKitComposition {
    
    func compose() -> UIHostingController<MyDayKitRootview> {
        let loader: ExerciseLoader = FirebaseExerciseLoader()
        let mainThreadLoader: ExerciseLoader = MainThreadExerciseLoaderDecorator(decoratee: loader)
        let exerciseManager = ExerciseManager(loader: mainThreadLoader)
        let localSaver = MyDayFileManagerSaver()
        let remoteSaver = MyDayFirestoreSaver()
        let localAndRemoteMyDaySaver: MyDaySaver = LocalAndRemoteMyDaySaver(local: localSaver, remote: remoteSaver)
        
        // Stats
        let rawLogRemoteStatsSaver: ExerciseStatsSaver = FirestoreExerciseStatsLogSaver()
        let localAndRemoteMyDayAndExerciseStatsSaver = LocalAndRemoteMyDayAndRemoteStatSaver(myDaySaver: localAndRemoteMyDaySaver, statSaver: rawLogRemoteStatsSaver)
        
        // Loader
        let weekPolicy = MyDayOneWeekPolicy()
        let localLoader: MyDayLoader = MyDayFileManagerLoader(policy: weekPolicy)
        let remoteLoader = MyDayFirestoreLoader()
        let localWithRemoteFallbackLoader = LocalWithRemoteFallBackMyDayLoader(localLoader: localLoader, remoteLoader: remoteLoader)
        let policyLoader = MyDayPolicyDayLoader(localLoader: localWithRemoteFallbackLoader, remoteLoader: remoteLoader, policy: weekPolicy)
        
        // Deleter
        let deleter = FirestoreRawLogDeleter()
        
        let dayManager = MyDayManager(
            saver: localAndRemoteMyDayAndExerciseStatsSaver,
            clipSaver: localAndRemoteMyDaySaver,
            deleteSaver: localAndRemoteMyDaySaver,
            loader: policyLoader,
            deleter: deleter
        )
        
        
        
        // Clip
        let thumbnailGenerator = VideoThumbnailGenerator()
        let converter = VideoConverter(
            userID: UserDefaults.currentUser.uid,
            thumbnailGenerator: thumbnailGenerator
        )
        let storageClipUploader = FirebaseStorageClipUploader()
        let thumnbailUploader = ThumbnailUploadDecorator(wrapping: storageClipUploader)
        let wrappedClipUploader = FirestoreMetadataDecorator(wrapped: thumnbailUploader)
        let uploadManager = UploadManager(clipUploader: wrappedClipUploader)
        
        let router = MyDayKitRouter(
            exerciseManager: exerciseManager,
            dayManager: dayManager,
            videoConverter: converter,
            uploadManager: uploadManager
        )
        
        let view = MyDayKitRootview(router: router)
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
    
    func composeCombination(_ navigationController: UINavigationController) {
        let loader: ExerciseLoader = FirebaseExerciseLoader()
        let mainThreadLoader: ExerciseLoader = MainThreadExerciseLoaderDecorator(decoratee: loader)
        let exerciseManager = ExerciseManager(loader: mainThreadLoader)
        let localSaver = MyDayFileManagerSaver()
        let remoteSaver = MyDayFirestoreSaver()
        let localAndRemoteMyDaySaver: MyDaySaver = LocalAndRemoteMyDaySaver(local: localSaver, remote: remoteSaver)
        
        // Stats
        let rawLogRemoteStatsSaver: ExerciseStatsSaver = FirestoreExerciseStatsLogSaver()
        let localAndRemoteMyDayAndExerciseStatsSaver = LocalAndRemoteMyDayAndRemoteStatSaver(myDaySaver: localAndRemoteMyDaySaver, statSaver: rawLogRemoteStatsSaver)
        
        // Loader
        let weekPolicy = MyDayOneWeekPolicy()
        let localLoader: MyDayLoader = MyDayFileManagerLoader(policy: weekPolicy)
        let remoteLoader = MyDayFirestoreLoader()
        let localWithRemoteFallbackLoader = LocalWithRemoteFallBackMyDayLoader(localLoader: localLoader, remoteLoader: remoteLoader)
        let policyLoader = MyDayPolicyDayLoader(localLoader: localWithRemoteFallbackLoader, remoteLoader: remoteLoader, policy: weekPolicy)
        
        // Deleter
        let deleter = FirestoreRawLogDeleter()
        
        let dayManager = MyDayManager(
            saver: localAndRemoteMyDayAndExerciseStatsSaver,
            clipSaver: localAndRemoteMyDaySaver,
            deleteSaver: localAndRemoteMyDaySaver,
            loader: policyLoader,
            deleter: deleter
        )
        
        // Clip
        let thumbnailGenerator = VideoThumbnailGenerator()
        let converter = VideoConverter(
            userID: UserDefaults.currentUser.uid,
            thumbnailGenerator: thumbnailGenerator
        )
        let storageClipUploader = FirebaseStorageClipUploader()
        let thumnbailUploader = ThumbnailUploadDecorator(wrapping: storageClipUploader)
        let wrappedClipUploader = FirestoreMetadataDecorator(wrapped: thumnbailUploader)
        let uploadManager = UploadManager(clipUploader: wrappedClipUploader)
        let clipLoader = FirestoreClipLoader()
        let viewClipRecorder = FirebaseFunctionsViewClipRecorder()
        
        let coordinator = MyDayCoordinator(
            navigationController: navigationController,
            exerciseManager: exerciseManager,
            dayManager: dayManager,
            videoConverter: converter,
            uploadManager: uploadManager,
            clipLoader: clipLoader,
            clipViewRecorder: viewClipRecorder
        )
        coordinator.start()
    }
    
    func composeUIKit() -> UIViewController {
        let loader: ExerciseLoader = FirebaseExerciseLoader()
        let mainThreadLoader: ExerciseLoader = MainThreadExerciseLoaderDecorator(decoratee: loader)
        let exerciseManager = ExerciseManager(loader: mainThreadLoader)
        let localSaver = MyDayFileManagerSaver()
        let remoteSaver = MyDayFirestoreSaver()
        let localAndRemoteMyDaySaver: MyDaySaver = LocalAndRemoteMyDaySaver(local: localSaver, remote: remoteSaver)
        
        // Stats
        let rawLogRemoteStatsSaver: ExerciseStatsSaver = FirestoreExerciseStatsLogSaver()
        let localAndRemoteMyDayAndExerciseStatsSaver = LocalAndRemoteMyDayAndRemoteStatSaver(myDaySaver: localAndRemoteMyDaySaver, statSaver: rawLogRemoteStatsSaver)
        
        // Loader
        let weekPolicy = MyDayOneWeekPolicy()
        let localLoader: MyDayLoader = MyDayFileManagerLoader(policy: weekPolicy)
        let remoteLoader = MyDayFirestoreLoader()
        let policyLoader = MyDayPolicyDayLoader(localLoader: localLoader, remoteLoader: remoteLoader, policy: weekPolicy)
        
        // Deleter
        let deleter = FirestoreRawLogDeleter()
        
        let dayManager = MyDayManager(
            saver: localAndRemoteMyDayAndExerciseStatsSaver,
            clipSaver: localAndRemoteMyDaySaver,
            deleteSaver: localAndRemoteMyDaySaver,
            loader: policyLoader,
            deleter: deleter
        )
        
        let vc = MyDayHomeViewController(dayManager: dayManager)
        return vc
    }
}

class MainThreadExerciseLoaderDecorator: ExerciseLoader {
    let decoratee: ExerciseLoader
    
    init(decoratee: ExerciseLoader) {
        self.decoratee = decoratee
    }
    
    func loadAll() async throws -> [Exercise] {
        let exercises = try await decoratee.loadAll()
        return await MainActor.run { exercises }
    }
}

class FirebaseExerciseLoader: ExerciseLoader {
    
    let firestoreService: FirestoreService
    
    init(firestoreService: FirestoreService = FirestoreManager.shared) {
        self.firestoreService = firestoreService
    }
    
    func loadAll() async throws -> [Exercise] {
        return try await firestoreService.readAll(at: "Exercises")
    }
}



import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFunctions

class MyDayFirestoreSaver: MyDaySaver {
    
    func save<T:Codable>(data: T) async throws {
        let userID = UserDefaults.currentUser.uid
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let documentID = formatter.string(from: Date.now)
        let path = "Users/\(userID)/MyDay/\(documentID)"
        let ref = Firestore.firestore().document(path)
        try await ref.setData(from: data, merge: true)
    }
}


class LocalAndRemoteMyDaySaver: MyDaySaver {
    let local: MyDaySaver
    let remote: MyDaySaver
    
    init(local: MyDaySaver, remote: MyDaySaver) {
        self.local = local
        self.remote = remote
    }
    
    func save<T: Codable>(data: T) async throws {
        try await local.save(data: data)
        try await remote.save(data: data)
    }
}

class LocalAndRemoteMyDayAndRemoteStatSaver: MyDayAndStatSaver {
    let myDaySaver: MyDaySaver
    let statSaver: ExerciseStatsSaver
    
    init(myDaySaver: MyDaySaver, statSaver: ExerciseStatsSaver) {
        self.myDaySaver = myDaySaver
        self.statSaver = statSaver
    }
    
    func save<T: Codable>(data: T, stats: ExerciseStatsSaveModel) async throws {
        try await myDaySaver.save(data: data)
        try await statSaver.save(stats)
    }
}

final class MyDayFileManagerSaver: MyDaySaver {
    private let baseURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("MyDays", isDirectory: true)

        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        self.baseURL = dir
    }
    
    private func fileURL() -> URL {
        let userID = UserDefaults.currentUser.uid

        // Per-user directory
        let userDir = baseURL.appendingPathComponent(userID, isDirectory: true)
        if !FileManager.default.fileExists(atPath: userDir.path) {
            try? FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = formatter.string(from: Date.now) + ".json"
        
        return userDir.appendingPathComponent(filename)
    }

    func save<T: Codable>(data: T) async throws {
        let url = fileURL()
        let encoded = try JSONEncoder().encode(data)
        try encoded.write(to: url, options: [.atomic])
    }
}

struct MyDayFileManagerLoader: MyDayLoader {
    
    private let policy: MyDayLoaderPolicy
    
    init(policy: MyDayLoaderPolicy) {
        self.policy = policy
    }
    
    private var baseURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("MyDays", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    private func fileURL(for date: Date) -> URL {
        let userID = UserDefaults.currentUser.uid

        // Per-user directory
        let userDir = baseURL.appendingPathComponent(userID, isDirectory: true)
        if !FileManager.default.fileExists(atPath: userDir.path) {
            try? FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = formatter.string(from: date) + ".json"
        
        return userDir.appendingPathComponent(filename)
    }
    
    func load<T: Codable>(for date: Date) async throws -> T? {
        deleteOldDays()
        do {
            let url = fileURL(for: date)
            guard FileManager.default.fileExists(atPath: url.path) else {
                return nil
            }
            let data = try Data(contentsOf: url)
            let day = try JSONDecoder().decode(T.self, from: data)
            return day
        } catch {
            print("❌ Error loading day: \(error)")
            return nil
        }
    }
}

extension MyDayFileManagerLoader {
    
    /// Returns the folder for the current user
    private var userFolder: URL {
        let userID = UserDefaults.currentUser.uid
        let folder = baseURL.appendingPathComponent(userID, isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }
    
    /// Loads all file URLs for the current user
    private func allDayFiles() -> [URL] {
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: userFolder, includingPropertiesForKeys: nil)
            return urls.filter { $0.pathExtension == "json" }
        } catch {
            print("❌ Error listing files: \(error)")
            return []
        }
    }
    
    /// Deletes files older than 7 days
    func deleteOldDays() {
        let calendar = Calendar.current
        let now = Date()
        let timescale = policy.dayLimit + 1 // this is so the same day is not deleted
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -timescale, to: now) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for file in allDayFiles() {
            let filename = file.deletingPathExtension().lastPathComponent
            if let fileDate = formatter.date(from: filename), fileDate < sevenDaysAgo {
                try? FileManager.default.removeItem(at: file)
                print("🗑 Deleted old day file: \(filename)")
            }
        }
    }
}

struct LocalWithRemoteFallBackMyDayLoader: MyDayLoader {
    let localLoader: MyDayLoader
    let remoteLoader: MyDayLoader
    
    func load<T: Codable>(for date: Date) async throws -> T? {
        if let data: T = try? await localLoader.load(for: date) {
            return data
        } else {
            return try await remoteLoader.load(for: date)
        }
    }
}


struct MyDayOneWeekPolicy: MyDayLoaderPolicy {
    var dayLimit: Int = 7
}


struct MyDayPolicyDayLoader: MyDayLoader {
    let localLoader: MyDayLoader
    let remoteLoader: MyDayLoader
    let policy: MyDayLoaderPolicy
    
    init(localLoader: MyDayLoader, remoteLoader: MyDayLoader, policy: MyDayLoaderPolicy) {
        self.localLoader = localLoader
        self.remoteLoader = remoteLoader
        self.policy = policy
    }
    
    func load<T: Codable>(for date: Date) async throws -> T? {
        if isWithinPolicyLimit(date) {
            try await localLoader.load(for: date)
        } else {
            try await remoteLoader.load(for: date)
        }
    }
    
    func isWithinPolicyLimit(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        // Start of today
        let startOfToday = calendar.startOfDay(for: now)
        
        // Start of the day 7 days ago
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -policy.dayLimit, to: startOfToday) else { return false }
        
        return date >= sevenDaysAgo && date <= now
    }
}

protocol MyDayLoaderPolicy {
    var dayLimit: Int { get }
}

class MyDayFirestoreLoader: MyDayLoader {
    
    func load<T: Codable>(for date: Date) async throws -> T? {
        let userID = UserDefaults.currentUser.uid
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let documentID = formatter.string(from: date)
        let path = "Users/\(userID)/MyDay/\(documentID)"
        let ref = Firestore.firestore().document(path)
        
        
        do {
            let model = try await ref.getDocument(as: T.self)
            return model
        } catch let error as NSError where error.domain == FirestoreErrorDomain &&
                                            error.code == FirestoreErrorCode.notFound.rawValue {
            return nil
        } catch {
            print("❌ Firestore load error: \(error)")
            throw error
        }
        
    }
}

struct FirestoreExerciseStatsLogSaver: ExerciseStatsSaver {
    
    func save(_ model: ExerciseStatsSaveModel) async throws {
        let db = Firestore.firestore()
        let userID = UserDefaults.currentUser.uid
        let exerciseID = model.exerciseID
        let exerciseDocRef = db.collection("Users/\(userID)/ExerciseStats/\(exerciseID)/RawLogs").document(model.id)
        try await exerciseDocRef.setData(from: model)
    }
}

struct FirestoreRawLogDeleter: MyDayDeleter {
    
    func delete(at path: String) async throws {
        let db = Firestore.firestore()
        let userID = UserDefaults.currentUser.uid
        let logRef = db.collection("Users/\(userID)/ExerciseStats").document(path)
        try await logRef.delete()
    }
}

struct FirestoreClipLoader: ClipLoader {
    
    func loadClip(with id: String) async throws -> Clip {
        let path = "TestClips/\(id)"
        let ref = Firestore.firestore().document(path)
        return try await ref.getDocument(as: Clip.self)
    }
}

struct FirebaseFunctionsViewClipRecorder: ViewClipRecorder {
    
    func recordClipWatch(
        clipID: String,
        watchedMoreThanThreeSeconds: Bool,
        watchedFullVideo: Bool,
        closePosition: Double,
        loopCount: Int
    ) {
        let data: [String: Any] = [
            "clipID": clipID,
            "watchedMoreThanThreeSeconds": watchedMoreThanThreeSeconds,
            "watchedFullVideo": watchedFullVideo,
            "closePosition": closePosition,
            "loopCount": loopCount
        ]
        
        let functions = Functions.functions()
#if EMULATOR
        print("using emulator")
        functions.useEmulator(withHost: "127.0.0.1", port: 5001)
#endif
        Task {
            try? await functions.httpsCallable("recordClipWatch").call(data)
        }
    }
}
