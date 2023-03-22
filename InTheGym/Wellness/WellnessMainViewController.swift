//
//  WellnessMainViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class WellnessMainViewController: UIViewController {
    
    // MARK: - Properties
    var childContentView: WellnessMainView!
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Wellness"
        editNavBarColour(to: .premiumColour)
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init()
        addSwiftUIView(childContentView)
    }
}
