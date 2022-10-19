//
//  MatchTrackerViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class MatchTrackerViewController: UIViewController {
    
    // MARK: - Coordinator
    weak var coordinator: MatchTrackerCoordinator?

    // MARK: - Properties
    var childContentView: MatchTrackerView!
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Match Tracker"
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init()
        addSwiftUIView(childContentView)
    }
}
