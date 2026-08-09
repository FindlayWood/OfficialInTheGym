//
//  View+Extension.swift
//  LoginKit
//
//  Created by Findlay-Personal on 03/04/2023.
//

import UIKit
import SwiftUI

extension UIViewController {
    func addSwiftUIView<T: View>(_ childContentView: T) {
        let childView = UIHostingController(rootView: childContentView)
        addChild(childView)
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        // The page sits on `systemBackground` and the cards on `secondarySystemBackground`, the way
        // round MyDay uses them. It was inverted before, when the cards were the lighter surface.
        childView.view.backgroundColor = .systemBackground
        childView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.view.topAnchor.constraint(equalTo: view.topAnchor),
            childView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// The nav bar takes the brand colour from the framework rather than being handed one — the app
    /// only ever passed `.darkColour`, which is `#1C496E`, the same colour `Color.darkColor` is.
    func editNavBarColour() {
        let colour = UIColor(Color.darkColor)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: colour]
        navigationController?.navigationBar.tintColor = colour
    }
}
