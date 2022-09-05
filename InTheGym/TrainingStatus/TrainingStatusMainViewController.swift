//
//  TrainingStatusMainViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class TrainingStatusMainViewController: UIViewController {

    // MARK: - Properties
    var childContentView: TrainingStatusView!
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Training Status"
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init()
        addSwiftUIView(childContentView)
    }
}
