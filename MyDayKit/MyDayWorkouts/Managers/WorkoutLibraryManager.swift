//
//  WorkoutLibraryManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/06/2026.
//

import Combine
import Foundation

public enum WorkoutLibraryState {
    case loading
    case empty
    case loaded([WorkoutTemplateModel])
    case failed(String)
}

/// Drives the workout library screen, **local-first**.
///
/// Reads used to be Firestore-only while writes were local-first
/// (`WorkoutTemplateSaver` writes FileManager, then queues the remote write), so
/// a template that had not synced yet was invisible in the library it had just
/// been saved to. `load()` now reads local storage first and shows it
/// immediately, then refreshes from remote in the background — the same shape
/// as the write path, in the opposite direction.
///
/// Remote failure is **not** an error once local has produced something: being
/// offline means the library is stale, not broken, and blanking a list the user
/// can see for a network blip would be a worse lie than showing it.
public class WorkoutLibraryManager: ObservableObject {

    @Published public var state: WorkoutLibraryState = .loading

    private let local: WorkoutTemplateFetching
    private let remote: WorkoutTemplateFetching
    private var isFetching = false

    /// Templates saved while a load was in flight. Applied when it settles.
    ///
    /// `addTemplate` used to drop them: the builder finishes, calls through to
    /// `onUploadSuccess`, and if that landed during `.loading` the new template
    /// vanished until the next fetch. It is the one moment the user is
    /// guaranteed to be looking for it.
    private var pendingTemplates: [WorkoutTemplateModel] = []

    public init(local: WorkoutTemplateFetching, remote: WorkoutTemplateFetching) {
        self.local = local
        self.remote = remote
    }

    // MARK: - Adding

    public func addTemplate(_ template: WorkoutTemplateModel) {
        switch state {
        case .loaded(let templates):
            state = Self.resolve(Self.merge(templates, with: [template]))
        case .empty, .failed:
            state = .loaded([template])
        case .loading:
            pendingTemplates.append(template)
        }
    }

    // MARK: - Loading

    /// Called on every appearance of the library. Only a successful load is
    /// treated as settled — an empty or failed result is retried, since the
    /// manager outlives the screen and would otherwise stay blank until relaunch.
    public func loadIfNeeded() {
        if case .loaded = state { return }
        load()
    }

    public func load() {
        guard !isFetching else { return }
        isFetching = true
        state = .loading

        Task {
            // Local first. It is on-device and effectively instant, so the
            // library is populated before the network is even consulted.
            let localTemplates = (try? await local.fetchAll()) ?? []
            if !localTemplates.isEmpty {
                await MainActor.run { publish(localTemplates) }
            }

            do {
                let remoteTemplates = try await remote.fetchAll()
                await MainActor.run {
                    isFetching = false
                    publish(Self.merge(localTemplates, with: remoteTemplates))
                }
            } catch {
                await MainActor.run {
                    isFetching = false
                    // Local already on screen? Then this is a stale library,
                    // not a broken one — leave what is showing alone.
                    if localTemplates.isEmpty {
                        state = .failed(error.localizedDescription)
                        applyPendingTemplates()
                    } else {
                        publish(localTemplates)
                    }
                }
            }
        }
    }

    // MARK: - Publishing

    /// Folds in anything saved during the load before deciding the state, so a
    /// template created mid-fetch is never lost to the result overwriting it.
    private func publish(_ templates: [WorkoutTemplateModel]) {
        var merged = templates
        if !pendingTemplates.isEmpty {
            merged = Self.merge(merged, with: pendingTemplates)
            pendingTemplates.removeAll()
        }
        state = Self.resolve(merged)
    }

    private func applyPendingTemplates() {
        guard !pendingTemplates.isEmpty else { return }
        let pending = pendingTemplates
        pendingTemplates.removeAll()
        state = Self.resolve(pending)
    }

    private static func resolve(_ templates: [WorkoutTemplateModel]) -> WorkoutLibraryState {
        templates.isEmpty ? .empty : .loaded(templates)
    }

    // MARK: - Merging

    /// Unions two sets of templates by id, newest-created first.
    ///
    /// Neither side is authoritative on its own: local holds templates that have
    /// not synced yet, remote holds templates created on another device. Where
    /// both hold the same id, the later `updatedAt` wins — that is the same
    /// template edited in two places, and the newer edit is the one to keep.
    static func merge(
        _ templates: [WorkoutTemplateModel],
        with others: [WorkoutTemplateModel]
    ) -> [WorkoutTemplateModel] {
        var byId: [String: WorkoutTemplateModel] = [:]
        for template in templates + others {
            if let existing = byId[template.id], existing.updatedAt >= template.updatedAt {
                continue
            }
            byId[template.id] = template
        }
        return byId.values.sorted { $0.createdAt > $1.createdAt }
    }
}
