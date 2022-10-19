//
//  MatchTrackerDetailViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class MatchTrackerDetailViewController: UIViewController {

    // MARK: - Coordinator
    weak var coordinator: MatchTrackerCoordinator?

    // MARK: - Properties
    var childContentView: MatchTrackerDetailView!
    var matchTrackerModel: MatchTrackerModel!
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Match Detail"
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(model: matchTrackerModel)
        addSwiftUIView(childContentView)
    }
}
