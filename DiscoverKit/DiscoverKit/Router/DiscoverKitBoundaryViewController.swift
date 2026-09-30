//
//  DiscoverKitBoundaryViewController.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI
import UIKit

/// Hosts the DISCOVER home and hides the system bar around it — the home
/// screen draws its own title bar, as STATS does. Pushed lists get the system
/// bar back in `viewWillDisappear`.
class DiscoverKitBoundaryViewController: UIViewController {

    var display: DiscoverHomeScreen!
    var router: DiscoverKitRouter!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Display
    func addDisplay() {
        addSwiftUIView(display)
    }

    func addSwiftUIView<T: View>(_ childContentView: T) {
        let childView = UIHostingController(rootView: childContentView)
        addChild(childView)
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        childView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.view.topAnchor.constraint(equalTo: view.topAnchor),
            childView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
