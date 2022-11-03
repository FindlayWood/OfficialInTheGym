//
//  PracticeTrackerDetailViewController.swift
//  InTheGym
//
//  Created by Findlay-Personal on 03/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PracticeTrackerDetailViewController: UIViewController {

    // MARK: - Coordinator
    weak var coordinator: PracticeTrackerCoordinator?

    // MARK: - Properties
    var childContentView: PracticeTrackerDetailView!
    var practiceTrackerModel: PracticeTrackerModel!
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Practice Detail"
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(model: practiceTrackerModel)
        addSwiftUIView(childContentView)
    }
}
