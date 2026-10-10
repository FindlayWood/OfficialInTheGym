//
//  PerformanceKitHostingController.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI
import UIKit

/// A `UIHostingController` that keeps its router alive.
///
/// Nothing else holds `PerformanceKitRouter` once the composition root returns.
/// Every closure the router hands out captures it weakly, so without this the
/// router is released straight after `start()` and every tap on the home
/// screen does nothing. The other frameworks' boundary view controllers hold
/// theirs the same way (`var router`). This one keeps the system navigation
/// bar, which those hide.
///
/// **It puts the bar's colours back every time it appears.** The legacy tools
/// still in the app call `editNavBarColour(to: .premiumColour)`, which turns
/// the title and back chevron of this whole stack purple and never restores
/// them. Without the reset, coming back from a tool leaves the home screen in
/// that tool's colours.
final class PerformanceKitHostingController<Content: View>: UIHostingController<Content> {

    var router: PerformanceKitRouter?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let bar = navigationController?.navigationBar else { return }
        bar.tintColor = UIColor(Color.darkColor)
        bar.titleTextAttributes = [.foregroundColor: UIColor.label]
    }
}
