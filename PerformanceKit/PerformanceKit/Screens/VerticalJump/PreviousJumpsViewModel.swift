//
//  PreviousJumpsViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// Every saved jump, sorted newest first or highest first, shown in centimetres
/// or inches. The legacy `PreviousJumpsView.ViewModel`, moved as it was.
@MainActor
final class PreviousJumpsViewModel: ObservableObject {

    @Published private(set) var isLoading = false
    @Published private(set) var jumps: [VerticalJump] = []
    @Published private(set) var sortedByDate = true
    @Published var measurement: JumpMeasurement = .cm

    private let loader: VerticalJumpHistoryLoader

    init(loader: VerticalJumpHistoryLoader) {
        self.loader = loader
    }

    var sortedJumps: [VerticalJump] {
        sortedByDate
            ? jumps.sorted { $0.time > $1.time }
            : jumps.sorted { $0.height > $1.height }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            jumps = try await loader.loadJumps()
        } catch {
            print("❌ Jump history load failed: \(error)")
        }
    }

    func sortByDate(_ value: Bool) {
        sortedByDate = value
    }
}
