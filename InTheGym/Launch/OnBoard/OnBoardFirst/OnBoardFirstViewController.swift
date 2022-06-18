//
//  OnBoardFirstViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import SwiftUI

class OnBoardFirstViewController: UIViewController {
    //MARK: - Properties
    var childContentView = OnBoardFirstView()
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .green
        addChildView()
    }
    func addChildView() {
        let childView = UIHostingController(rootView: childContentView)
        addChild(childView)
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        childView.view.translatesAutoresizingMaskIntoConstraints = false
//        childView.view.isUserInteractionEnabled = false
        NSLayoutConstraint.activate([
            childView.view.topAnchor.constraint(equalTo: view.topAnchor),
            childView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
