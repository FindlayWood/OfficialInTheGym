//
//  CMJMyJumpsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/09/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class CMJMyJumpsViewController: UIViewController {

    // MARK: - Properties
    var childContentView: CMJMyJumpsView!
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "My CMJ Jumps"
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init()
        addSwiftUIView(childContentView)
    }
}
