//
//  JournalHomeViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// The journal: every entry, newest first, with today's repeated in a section
/// of their own above.
///
/// **Today's entries are derived from `entries`, never kept as a second list.**
/// The legacy view model appended to a separate `todayEntry` array on every
/// load, and the screen loads on every appearance, so leaving and coming back
/// listed today's entries twice, then three times. Derived, they cannot
/// disagree with the list they come from.
@MainActor
final class JournalHomeViewModel: ObservableObject {

    @Published private(set) var entries: [JournalEntry] = []
    @Published private(set) var isLoading = false
    @Published var isShowingNewEntry = false
    @Published var selectedEntry: JournalEntry?

    private let loader: JournalEntriesLoader
    private let isToday: (Date) -> Bool

    init(loader: JournalEntriesLoader, isToday: @escaping (Date) -> Bool = { Calendar.current.isDateInToday($0) }) {
        self.loader = loader
        self.isToday = isToday
    }

    var todayEntries: [JournalEntry] {
        entries.filter { isToday($0.date) }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            entries = try await loader.loadEntries()
        } catch {
            print("❌ Journal load failed: \(error)")
        }
    }

    func addNewEntry() {
        isShowingNewEntry = true
    }

    func entryAdded(_ entry: JournalEntry) {
        entries.insert(entry, at: 0)
    }
}
