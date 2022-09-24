//
//  PremiumAccountViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PremiumAccountViewController: UIViewController {
    // MARK: - Properties
    var childContentView: PremiumAccountViewSwiftUI!
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init()
        addSwiftUIView(childContentView)
    }
}
