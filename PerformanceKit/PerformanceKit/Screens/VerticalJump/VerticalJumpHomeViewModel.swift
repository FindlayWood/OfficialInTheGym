//
//  VerticalJumpHomeViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// Vertical Jump's home: the athlete's best, and the way to record, review or
/// read how to use it. The legacy `MyJumpsViewModel`, with its actions as
/// closures rather than a published enum the view controller sinks.
///
/// **Recording is offered only on your own Performance Center** (`canRecord`).
/// The legacy screens always read and wrote the signed-in user's jumps, so a
/// coach opening an athlete's centre was shown their own. The jumps shown are
/// the athlete's now, and a coach cannot record one on the athlete's behalf.
@MainActor
final class VerticalJumpHomeViewModel: ObservableObject {

    @Published private(set) var isLoading = false
    @Published private(set) var max: VerticalJump?

    let canRecord: Bool

    var onRecordNewJump: ((VerticalJump?) -> Void)?
    var onPreviousJumps: (() -> Void)?
    var onHelp: (() -> Void)?

    private let loader: MaxVerticalJumpLoader

    init(loader: MaxVerticalJumpLoader, canRecord: Bool) {
        self.loader = loader
        self.canRecord = canRecord
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            max = try await loader.loadMax()
        } catch {
            print("❌ Max jump load failed: \(error)")
        }
    }

    /// The best is handed on so the result screen can tell whether a new jump
    /// beats it without reading it again.
    func recordNewJump() {
        onRecordNewJump?(max)
    }

    func previousJumps() {
        onPreviousJumps?()
    }

    func help() {
        onHelp?()
    }
}
