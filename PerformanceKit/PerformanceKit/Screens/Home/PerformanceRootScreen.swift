//
//  PerformanceRootScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// The root of the PERFORMANCE tab: the home with pro, the locked screen
/// without. One screen switching between the two, rather than two routes, so
/// the tab's root never changes and a check on appearance is all it takes.
///
/// The title is `PerformanceTabHeader`, not the system bar, which the hosting
/// controller hides on this screen only — pushed screens keep theirs.
struct PerformanceRootScreen: View {

    @ObservedObject var gate: PerformanceGateViewModel
    @ObservedObject var home: PerformanceDashboardViewModel
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            PerformanceTabHeader(title: "Performance", onDismiss: onDismiss)
            Group {
                if gate.isUnlocked {
                    PerformanceHomeScreen(viewModel: home)
                } else {
                    PerformanceLockedScreen(viewModel: gate)
                }
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}
