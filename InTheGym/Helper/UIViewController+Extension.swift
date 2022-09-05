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
    func displayTopMessage(with message: String) {
        let viewHeight = view.bounds.height * 0.07
        let screenWidth = view.bounds.width
        let viewWidth = view.bounds.width * 0.8
        let margins = navigationController?.view.safeAreaInsets
        
        let startingPoint = CGRect(x: (screenWidth * 0.1), y: -30 - viewHeight, width: viewWidth, height: viewHeight)
        let showingPoint = CGRect(x: (screenWidth * 0.1), y: margins!.top, width: viewWidth, height: viewHeight)
        
        let topView: UITopMessageView = {
            let view = UITopMessageView()
            view.configure(with: message)
            return view
        }()
        
//        let label: UILabel = {
//            let label = UILabel()
//            label.font = .systemFont(ofSize: 20, weight: .bold)
//            label.textColor = .white
//            label.adjustsFontSizeToFitWidth = true
//            label.minimumScaleFactor = 0.25
//            label.text = message
//            label.textAlignment = .center
//            label.translatesAutoresizingMaskIntoConstraints = false
//            return label
//        }()
//        let topView: UIView = {
//            let view = UIView(frame: startingPoint)
//            view.backgroundColor = .darkColour
//            view.layer.borderWidth = 4.0
//            view.layer.borderColor = UIColor.white.cgColor
//            view.layer.cornerRadius = 20
//            return view
//        }()
//
//        topView.addSubview(label)
//        label.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
//        label.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
//        label.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 2).isActive = true
//        label.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -2).isActive = true
        
        navigationController?.view.addSubview(topView)
        
        UIView.animate(withDuration: 0.6) {
            topView.frame = showingPoint
        } completion: { (_) in
            UIView.animate(withDuration: 0.6, delay: 2.8, options: .curveEaseOut) {
                topView.frame = startingPoint
                } completion: { (_) in
                    topView.removeFromSuperview()
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
}
