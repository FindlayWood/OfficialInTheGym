//
//  PreviousJumpsViewController.swift
//  InTheGym
//
//  Created by Findlay-Personal on 31/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PreviousJumpsViewController: UIViewController {

    // MARK: - Properties
    var childContentView: PreviousJumpsView!
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "My Vertical Jumps"
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init()
        addSwiftUIView(childContentView)
    }
}
