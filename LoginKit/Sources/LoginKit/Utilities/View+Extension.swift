//
//  File.swift
//  
//
//  Created by Findlay-Personal on 03/04/2023.
//

import UIKit
import SwiftUI

extension UIViewController {
    func addSwiftUIView<T:View>(_ childContentView: T) {
        let childView = UIHostingController(rootView: childContentView)
        addChild(childView)
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        childView.view.frame = view.bounds
        childView.view.backgroundColor = .secondarySystemBackground
    }
    func editNavBarColour(to colour: UIColor) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: colour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = colour
    }
}
