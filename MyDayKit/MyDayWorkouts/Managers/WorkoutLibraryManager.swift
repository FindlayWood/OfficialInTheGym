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

public class WorkoutLibraryManager: ObservableObject {

    @Published public var state: WorkoutLibraryState = .loading

    private let fetcher: WorkoutTemplateFetching
    private var isFetching = false

    public init(fetcher: WorkoutTemplateFetching) {
        self.fetcher = fetcher
    }

    public func addTemplate(_ template: WorkoutTemplateModel) {
        switch state {
        case .loaded(var templates):
            templates.insert(template, at: 0)
            state = .loaded(templates)
        case .empty, .failed:
            state = .loaded([template])
        case .loading:
            break
        }
    }

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
            do {
                let templates = try await fetcher.fetchAll()
                await MainActor.run {
                    isFetching = false
                    state = templates.isEmpty ? .empty : .loaded(templates)
                }
            } catch {
                await MainActor.run {
                    isFetching = false
                    state = .failed(error.localizedDescription)
                }
            }
        }
    }
}
