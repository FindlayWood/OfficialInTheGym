//
//  JumpResultsViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation
import SwiftUI

/// A measured jump, shown in cm or inches, with a button to save it.
///
/// Saving writes the jump and the athlete's best (`VerticalJump.best`) through
/// one `VerticalJumpWriter`. The best is worked out against the best the home
/// screen had loaded, which is carried here in the route rather than read again.
///
/// **A failed save puts the button back.** The legacy view model only cleared
/// `isSaving` on success, so a failed write left "Saving Result..." on screen
/// for good.
@MainActor
final class JumpResultsViewModel: ObservableObject {

    @Published var measurement: JumpMeasurement = .cm {
        didSet { convert(from: oldValue, to: measurement) }
    }
    @Published private(set) var height: Double
    @Published private(set) var isSaving = false
    @Published private(set) var saveSucceeded = false

    var onDismiss: (() -> Void)?

    private let max: VerticalJump?
    private let writer: VerticalJumpWriter
    private let now: () -> Date

    init(height: Double, max: VerticalJump?, writer: VerticalJumpWriter, now: @escaping () -> Date = Date.init) {
        self.height = height
        self.max = max
        self.writer = writer
        self.now = now
    }

    func save() async {
        withAnimation { isSaving = true }
        // Heights are stored in centimetres whatever is on screen.
        if measurement == .inches {
            measurement = .cm
        }
        let jump = VerticalJump(time: now(), height: height)
        let save = VerticalJumpSave(jump: jump, best: VerticalJump.best(current: max, new: jump))
        do {
            try await writer.write(save)
            withAnimation {
                saveSucceeded = true
                isSaving = false
            }
        } catch {
            print("❌ Jump save failed: \(error)")
            withAnimation { isSaving = false }
        }
    }

    func dismiss() {
        onDismiss?()
    }

    /// The legacy rounding, to two places on each switch, kept as it was.
    private func convert(from old: JumpMeasurement, to new: JumpMeasurement) {
        guard old != new else { return }
        switch new {
        case .inches:
            height = JumpMeasurement.inches(fromCentimetres: height).rounded(toPlaces: 2)
        case .cm:
            height = JumpMeasurement.centimetres(fromInches: height).rounded(toPlaces: 2)
        }
    }
}
