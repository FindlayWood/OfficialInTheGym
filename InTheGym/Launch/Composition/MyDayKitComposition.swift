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

    /// MyDay's workout library, for DISCOVER's "Save to Library" — the same
    /// saver and manager MyDay itself uses. Set by `composeCombination`.
    private(set) var workoutLibrary: MyDayWorkoutLibrary?
    /// Opens MyDay's Getting Started, for Settings on the PROFILE tab. Holds the
    /// coordinator weakly — the tab's stack owns it. Set by `composeCombination`.
    private(set) var showGettingStarted: (() -> Void)?
    /// **The sync services live here, for the signed-in session.** They used
    /// to be locals in `composeCombination`, and this composition a local in
    /// `PlayerInitialViewController.viewDidLoad`, so nothing held them once
    /// launch finished: each one's flush and network monitor hold it weakly,
    /// found it gone, and a write queued offline was never retried. The tab
    /// bar now holds this composition, this holds the services, and signing
    /// out stops them — `stop()` had no caller before.
    private var templateSyncService: WorkoutTemplateSyncService?
    private var customExerciseSyncService: CustomExerciseSyncService?
    private var signOutObserver: NSObjectProtocol?

    deinit {
        stopSyncServices()
        if let signOutObserver {
            NotificationCenter.default.removeObserver(signOutObserver)
        }
    }
    
    func composeCombination(_ navigationController: UINavigationController, purchaseManager: PurchaseManager) {
        let userId = UserDefaults.currentUser.uid

        let loader: ExerciseLoader = FirebaseExerciseLoader()
        let mainThreadLoader: ExerciseLoader = MainThreadExerciseLoaderDecorator(decoratee: loader)
        // The picker lists the catalogue and the user's custom exercises,
        // local first like the template library — see `ExerciseLibrary`.
        let exerciseManager = ExerciseManager(
            loader: mainThreadLoader,
            customLocal: FileManagerCustomExerciseFetcher(userId: userId),
            customRemote: FirestoreCustomExerciseFetcher(userId: userId)
        )
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
            deleter: deleter,
            wellnessSaver: localAndRemoteMyDaySaver,
            rpeSaver: localAndRemoteMyDaySaver,
            workoutSaver: localAndRemoteMyDaySaver,
            workoutStatsSaver: rawLogRemoteStatsSaver,
            completedSessionSaver: FirestoreCompletedWorkoutSessionSaver(),
            completedSessionDeleter: FirestoreCompletedWorkoutSessionDeleter(),
            rangeLoader: MyDayFirestoreRangeLoader()
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
        
        // Workout
        // The local template store is scoped by user id. Anything still at the
        // old unscoped path is filed under its own author before the library
        // reads — see `LegacyWorkoutTemplateStoreMigrator`.
        LegacyWorkoutTemplateStoreMigrator().migrate()

        let syncQueue = SyncQueueWorkoutTemplateUploader(userId: userId)

        // Each writer owns one path; the decorator writes both. The syncer and
        // the queue flush share it, so a queued template reaches both on retry.
        let remoteTemplateUploader: WorkoutTemplateUploading = UserAndTopLevelWorkoutTemplateUploader(
            user: FirestoreWorkoutTemplateUploader(),
            topLevel: FirestoreTopLevelWorkoutTemplateUploader()
        )

        let syncer = WorkoutTemplateSyncer(
            remote: remoteTemplateUploader,
            queue: syncQueue
        )
        let saver = WorkoutTemplateSaver(
            local: FileManagerWorkoutTemplateUploader(userId: userId),
            remote: syncer
        )
        let workoutManager = WorkoutBuilderManager(
            uploader: saver,
            userId: userId
        )

        let syncService = WorkoutTemplateSyncService(
            remote: remoteTemplateUploader,
            syncQueue: syncQueue
        )
        syncService.start()
        templateSyncService = syncService

        // Custom exercises — the template pipeline again, one writer per path.
        let customExerciseQueue = SyncQueueCustomExerciseUploader(userId: userId)
        let remoteCustomExerciseUploader: CustomExerciseUploading = UserAndTopLevelCustomExerciseUploader(
            user: FirestoreCustomExerciseUploader(),
            topLevel: FirestoreTopLevelCustomExerciseUploader()
        )
        let customExerciseSaver: CustomExerciseUploading = CustomExerciseSaver(
            local: FileManagerCustomExerciseWriter(userId: userId),
            remote: CustomExerciseSyncer(remote: remoteCustomExerciseUploader, queue: customExerciseQueue)
        )
        let customExerciseSyncService = CustomExerciseSyncService(
            remote: remoteCustomExerciseUploader,
            syncQueue: customExerciseQueue
        )
        customExerciseSyncService.start()
        self.customExerciseSyncService = customExerciseSyncService

        // The form's lists, cached on disk so it works offline. The same two
        // readers StatsKit uses — one reader per collection.
        let customExercises = CustomExerciseDependencies(
            saver: customExerciseSaver,
            muscleGroups: CachedExerciseMuscleGroupsLoader(
                remote: RemoteMuscleGroupsLoader(),
                cache: FileExerciseBodyListCache(url: ExerciseBodyListStoreLocation.muscleGroups)
            ),
            movementPatterns: CachedExerciseMovementPatternsLoader(
                remote: RemoteMovementTypesLoader(),
                cache: FileExerciseBodyListCache(url: ExerciseBodyListStoreLocation.movementPatterns)
            ),
            userId: userId
        )

        signOutObserver = NotificationCenter.default.addObserver(
            forName: Notification.signOut,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.stopSyncServices()
        }
        
        // Local-first, mirroring the write path: `WorkoutTemplateSaver` writes
        // FileManager then queues the remote write, so the library has to read
        // FileManager first or a template that has not synced yet is invisible.
        let localTemplates: WorkoutTemplateFetching = FileManagerWorkoutTemplateFetcher(userId: userId)
        let workoutLibraryManager = WorkoutLibraryManager(
            local: localTemplates,
            remote: FirestoreWorkoutTemplateFetcher()
        )

        workoutLibrary = MyDayWorkoutLibrary(saver: saver, manager: workoutLibraryManager, local: localTemplates)
        
        let coordinator = MyDayCoordinator(
            navigationController: navigationController,
            userId: userId,
            exerciseManager: exerciseManager,
            dayManager: dayManager,
            videoConverter: converter,
            uploadManager: uploadManager,
            clipLoader: clipLoader,
            clipViewRecorder: viewClipRecorder,
            workoutManager: workoutManager,
            workoutLibraryManager: workoutLibraryManager,
            // Recording and watching clips are pro; logging is not.
            proAccess: PurchaseManagerProAccess(purchaseManager: purchaseManager),
            // Read off the cached user, like the uid above: the signup day is
            // derived from `createdDate` on every render, never stored.
            welcome: MyDayWelcome(
                name: UserDefaults.currentUser.displayName,
                signupDate: UserDefaults.currentUser.createdDate
            ),
            customExercises: customExercises
        )
        showGettingStarted = { [weak coordinator] in coordinator?.showGettingStarted() }
        coordinator.onShowPaywall = { [weak navigationController] in
            navigationController?.present(ProPaywallViewController.modal(purchaseManager: purchaseManager), animated: true)
        }
        coordinator.start()
    }
}

// MARK: - Sync services
extension MyDayKitComposition {

    /// Stops both monitors. Queued writes stay on disk, scoped by user id, and
    /// are flushed by the next session that user signs in to.
    private func stopSyncServices() {
        templateSyncService?.stop()
        customExerciseSyncService?.stop()
        templateSyncService = nil
        customExerciseSyncService = nil
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

    func loadAll() async throws -> [Exercise] {
        let snapshot = try await Firestore.firestore()
            .collection("Exercises")
            .getDocuments()

        // Decode per document, as the template fetcher does. The catalogue is
        // edited by hand-run scripts, and one exercise with a category the app
        // does not know would otherwise empty the whole picker.
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Exercise.self)
            } catch {
                print("❌ Skipping exercise \(document.documentID): \(error)")
                return nil
            }
        }
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
        let dir = MyDayStoreLocation.root

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
        let dir = MyDayStoreLocation.root
        
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
        let path = "Clips/\(id)"
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
