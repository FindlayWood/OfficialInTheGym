//
//  StatsKitRootScreen.swift
//  StatsKit
//
//  Created by Findlay Wood on 12/10/2026.
//

import SwiftUI

/// The root of the STATS tab: the home with pro, the free view (this week, streak, top lift)
/// without. One screen switching between the two, rather than two routes, so the tab's root never
/// changes and a check on appearance is all it takes — the shape `PerformanceRootScreen` set.
struct StatsKitRootScreen: View {

    @ObservedObject var gate: StatsGateViewModel
    let home: StatsKitHomeScreenViewModel
    let free: StatsFreeViewModel

    var body: some View {
        if gate.isUnlocked {
            StatsKitHomeScreen(viewModel: home)
        } else {
            StatsFreeScreen(viewModel: free)
        }
    }
}
