//
//  UIViewController+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI


extension UIViewController {
    
    // MARK: - Display Top View 
    func displayTopMessage(with message: String, imageName: String = "checkmark.circle") {
        let viewHeight = view.bounds.height * 0.07
        let screenWidth = view.bounds.width
        let viewWidth = view.bounds.width * 0.8
        let margins = navigationController?.view.safeAreaInsets
        
        let startingPoint = CGRect(x: (screenWidth * 0.1), y: -30 - viewHeight, width: viewWidth, height: viewHeight)
        let showingPoint = CGRect(x: (screenWidth * 0.1), y: margins!.top, width: viewWidth, height: viewHeight)
        
        let topView = UITopMessageView()
        topView.view.frame = startingPoint
        topView.addChildView(message, image: imageName)
        
        navigationController?.view.addSubview(topView.view)
        
        UIView.animate(withDuration: 0.6) {
            topView.view.frame = showingPoint
        } completion: { (_) in
            UIView.animate(withDuration: 0.6, delay: 2.8, options: .curveEaseOut) {
                topView.view.frame = startingPoint
                } completion: { (_) in
                    topView.view.removeFromSuperview()
            }
        }

    }
}

// MARK: - Add Child VC
extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

// MARK: - Loading Nav Bar
extension UIViewController {
    func initLoadingNavBar(with color: UIColor) {
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.startAnimating()
        activityIndicator.color = color
        let barButton = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = barButton
    }
}

// MARK: - SwiftUI View
extension UIViewController {
    func addSwiftUIView<T:View>(_ childContentView: T) {
        let childView = UIHostingController(rootView: childContentView)
        addChild(childView)
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        childView.view.frame = view.bounds
        childView.view.backgroundColor = .secondarySystemBackground
    }
    func addSwiftUIViewWithNavBar<content: View>(_ childContentView: content) {
        let childView = UIHostingController(rootView: childContentView)
        addChild(childView)
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        childView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            childView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    func addSwiftUISubView<content: View>(_ childContentView: content) -> UIHostingController<content> {
        let childView = UIHostingController(rootView: childContentView)
        addChild(childView)
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        childView.view.backgroundColor = .clear
        childView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            childView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        return childView
    }
}
