//
//  File.swift
//  
//
//  Created by Findlay-Personal on 11/04/2023.
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
}
