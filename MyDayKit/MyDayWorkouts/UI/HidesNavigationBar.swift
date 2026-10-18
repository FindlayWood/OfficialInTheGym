//
//  HidesNavigationBar.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import UIKit

/// Marks a view controller that keeps the system navigation bar hidden while it is showing.
///
/// `NavBarHidingHostingController` restores the bar as it disappears, for the screens with a
/// system bar that follow it. When the screen taking its place hides the bar too — session →
/// summary in the demo, template detail → session in MyDay — restoring it showed the bar for the
/// length of the push before the next screen hid it again: **a white flash in dark mode**, since
/// the summary's toolbar was forced light. Checking for this marker skips the restore.
protocol HidesNavigationBar: UIViewController {}
