//
//  PracticeTrackerHomeViewController.swift
//  InTheGym
//
//  Created by Findlay-Personal on 03/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import UIKit

class PracticeTrackerHomeViewController: UIViewController {

    // MARK: - Coordinator
    weak var coordinator: PracticeTrackerCoordinator?

    // MARK: - Properties
    var childContentView: PracticeTrackerHomeView!
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
        initSubscriptions()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Practice Tracker"
        editNavBarColour(to: .premiumColour)
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
    func showDetail(_ model: PracticeTrackerModel) {
        coordinator?.showDetail(model)
    }
}
