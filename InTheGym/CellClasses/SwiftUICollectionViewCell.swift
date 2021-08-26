//
//  SwiftUICollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import SwiftUI
import UIKit


/// Subclass for embedding a SwiftUI View inside of UICollectionViewCell
/// Usage: `class MySwiftUICell: SwiftUICollectionViewCell<Card> { ... }`
@available(iOS 13.0, *)
open class SwiftUICollectionViewCell<Content>: UICollectionViewCell where Content: View {
    
    /// Controller to host the SwiftUI View
    private(set) var host: UIHostingController<Content>?
    
    /// Add host controller to the heirarchy
    func embed(in parent: UIViewController, withView content: Content) {
        if let host = self.host {
            host.rootView = content
            host.view.layoutIfNeeded()
        } else {
            let host = UIHostingController(rootView: content)
            
            parent.addChild(host)
            host.didMove(toParent: parent)
            self.contentView.addSubview(host.view)
            self.host = host
        }
    }
    
    // MARK: Controller + view clean up
    
    deinit {
        host?.willMove(toParent: nil)
        host?.view.removeFromSuperview()
        host?.removeFromParent()
        host = nil
    }
}
