//
//  WorkoutSessionDialog.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/08/2026.
//

import Foundation

/// Which card `WorkoutSessionDialogOverlay` is showing on the session screen.
///
/// One overlay with two states rather than two separate overlays, so stepping
/// from the `⋯` menu into the cancel confirmation crossfades inside a single
/// backdrop instead of stacking a second dim layer over the first — the
/// confirmation replaces the menu, it does not sit on top of it.
enum WorkoutSessionDialog {

    /// The `⋯` menu.
    case options

    /// Confirming the destructive `cancelSession()`.
    case confirmCancel
}
