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
}

public class WorkoutLibraryManager: ObservableObject {

    @Published public var state: WorkoutLibraryState = .loading

    private let fetcher: WorkoutTemplateFetching

    public init(fetcher: WorkoutTemplateFetching) {
        self.fetcher = fetcher
    }

    public func addTemplate(_ template: WorkoutTemplateModel) {
        switch state {
        case .loaded(var templates):
            templates.insert(template, at: 0)
            state = .loaded(templates)
        case .empty:
            state = .loaded([template])
        case .loading:
            break
        }
    }

    public func loadIfNeeded() {
        guard case .loading = state else { return }
        load()
    }

    public func load() {
        state = .loading
        Task {
            do {
                let templates = try await fetcher.fetchAll()
                await MainActor.run {
                    state = templates.isEmpty ? .empty : .loaded(templates)
                }
            } catch {
                await MainActor.run {
                    state = .empty
                }
            }
        }
    }
}
