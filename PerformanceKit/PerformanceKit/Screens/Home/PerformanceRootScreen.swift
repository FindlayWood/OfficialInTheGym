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
struct PerformanceRootScreen: View {

    @ObservedObject var gate: PerformanceGateViewModel
    let home: PerformanceHomeViewModel

    var body: some View {
        Group {
            if gate.isUnlocked {
                PerformanceHomeScreen(viewModel: home)
            } else {
                PerformanceLockedScreen(viewModel: gate)
            }
        }
        .navigationTitle("Performance")
        .navigationBarTitleDisplayMode(.large)
    }
}
