//
//  ProfileKitBoundaryViewController.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI
import UIKit

/// Hosts the profile root and hides the system bar around it. The screen draws
/// its own title bar, as the DISCOVER and STATS roots do. Settings, pushed from
/// it, gets the system bar back in `viewWillDisappear`.
///
/// It holds the router strongly. Nothing else keeps the router alive once the
/// composition root returns, and the router owns the closures that reach the
/// app's legacy screens.
class ProfileKitBoundaryViewController: UIViewController {

    var display: MyProfileScreen!
    var router: ProfileKitRouter!

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
