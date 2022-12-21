//
//  ExerciseStatsDetailViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class ExerciseStatsDetailViewController: UIViewController {
    
    // MARK: - Properties
    var display = ExerciseStatsDetailView()

    var viewModel = ExerciseStatsDetailViewModel()
    
    var childContentView: ExerciseStatsView!
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
//    override func loadView() {
//        view = display
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        addChildView()
//        display.configure(with: viewModel.statsModel)
        initViewModel()
        initTargets()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = viewModel.statsModel.exerciseName
        editNavBarColour(to: .darkColour)
    }
    // MARK: - Targets
    func initTargets() {
        display.maxButton.addTarget(self, action: #selector(viewMaxAction(_:)), for: .touchUpInside)
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        let childView = UIHostingController(rootView: childContentView)
        addChild(childView)
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        childView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            childView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.viewMax
            .sink { [weak self] in self?.viewMaxAction()}
            .store(in: &subscriptions)
    }
}
// MARK: - Actions
extension ExerciseStatsDetailViewController {
    @objc func viewMaxAction(_ sender: UIButton) {
        let vc = ExerciseMaxHistoryViewController()
        vc.viewModel.exerciseName = viewModel.statsModel.exerciseName
        navigationController?.pushViewController(vc, animated: true)
    }
    func viewMaxAction() {
        let vc = ExerciseMaxHistoryViewController()
        vc.viewModel.exerciseName = viewModel.statsModel.exerciseName
        navigationController?.pushViewController(vc, animated: true)
    }
}
