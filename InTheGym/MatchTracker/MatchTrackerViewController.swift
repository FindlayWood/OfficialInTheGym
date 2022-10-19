//
//  MatchTrackerViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import UIKit

class MatchTrackerViewController: UIViewController {
    
    // MARK: - Coordinator
    weak var coordinator: MatchTrackerCoordinator?

    // MARK: - Properties
    var childContentView: MatchTrackerView!
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
        initSubscriptions()
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
    // MARK: - Subscribers
    func initSubscriptions() {
        childContentView.tapped
            .sink { [weak self] in self?.showDetail($0) }
            .store(in: &subscriptions)
    }
    func showDetail(_ model: MatchTrackerModel) {
        coordinator?.showDetail(model)
    }
}
