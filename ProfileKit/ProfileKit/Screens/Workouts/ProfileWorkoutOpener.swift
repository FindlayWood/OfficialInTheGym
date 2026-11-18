//
//  ProfileWorkoutOpener.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import Combine
import Foundation

/// Acts on a tapped workout row: works out its `ProfileWorkoutDestination` and either opens a page
/// or holds the row as `choice` while the choice card is up. One per screen, built by the router,
/// which owns the two closures.
///
/// **Both pages belong to other frameworks**, MyDay's workout page and DISCOVER's, so this only
/// raises intent. A `nil` closure means this router cannot open that page, and the destination
/// rule then never sends a row there.
@MainActor
final class ProfileWorkoutOpener: ObservableObject {

    /// The row whose choice card is showing, `nil` when none is.
    @Published private(set) var choice: ProfileWorkout?

    private let currentUserId: String
    private let openWorkout: ((String) -> Void)?
    private let openDiscover: ((ProfileWorkout) -> Void)?

    init(
        currentUserId: String,
        openWorkout: ((String) -> Void)?,
        openDiscover: ((ProfileWorkout) -> Void)?
    ) {
        self.currentUserId = currentUserId
        self.openWorkout = openWorkout
        self.openDiscover = openDiscover
    }

    func destination(for workout: ProfileWorkout, from source: ProfileWorkoutSource) -> ProfileWorkoutDestination {
        ProfileWorkoutDestination(
            for: workout,
            from: source,
            currentUserId: currentUserId,
            canOpenWorkout: openWorkout != nil,
            canOpenDiscover: openDiscover != nil
        )
    }

    func open(_ workout: ProfileWorkout, from source: ProfileWorkoutSource) {
        switch destination(for: workout, from: source) {
        case .choice: choice = workout
        case .workout: openWorkout?(workout.workoutId)
        case .discover: openDiscover?(workout)
        case .none: break
        }
    }

    // MARK: - Choice card

    func chooseWorkout() {
        guard let choice else { return }
        self.choice = nil
        openWorkout?(choice.workoutId)
    }

    func chooseDiscover() {
        guard let choice else { return }
        self.choice = nil
        openDiscover?(choice)
    }

    func dismissChoice() {
        choice = nil
    }
}
