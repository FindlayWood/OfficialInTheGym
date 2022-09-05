//
//  CMJHomeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

class CMJHomeViewController: UIViewController {
    // MARK: - Coordinator
    weak var coordinator: CMJCoordinator?
    
    // MARK: - Properties
    var childContentView: CMJHomeViewSwiftUI!
    var display = Display()
    var viewModel = CMJHomeViewModel()
    
    var tileView = TitleView()
    var currentScoreView = CMJCurrentScoreView()

    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
//    override func loadView() {
//        view = display
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        addChildView()
//        addSubViews()
//        initNavBar()
        initTargets()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "CMJ"
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        addSwiftUIViewWithNavBar(childContentView)
//        let childView = UIHostingController(rootView: childContentView)
//        addChild(childView)
//        view.addSubview(childView.view)
//        childView.didMove(toParent: self)
//        childView.view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            childView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            childView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            childView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            childView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
    }
    // MARK: - Display
    func addSubViews() {
        addToStack(tileView)
        addToStack(currentScoreView)
        addToStack(display.newJumpButton)
        addToStack(display.jumpsButton)
        addToStack(display.myMeasurementsButton)
        addToStack(display.helpButton)
    }
    func addToStack(_ view: UIView) {
        display.stack.addArrangedSubview(view)
    }
    // MARK: - Nav Bar
    func initNavBar() {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .done, target: self, action: #selector(plusButtonAction(_:)))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    // MARK: - Targets
    func initTargets() {
        display.newJumpButton.addTarget(self, action: #selector(plusButtonAction(_:)), for: .touchUpInside)
        display.myMeasurementsButton.addTarget(self, action: #selector(measurementsButtonAction(_:)), for: .touchUpInside)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.$action
            .compactMap { $0 }
            .sink { [weak self] in self?.buttonAction($0) }
            .store(in: &subscriptions)
//        viewModel.$isLoading
//            .sink { [weak self] in self?.setLoading($0) }
//            .store(in: &subscriptions)
//
//        viewModel.$measurementsModel
//            .sink { [weak self] model in
//                if model == nil {
//                    self?.display.updateMeasurementsButton()
//                } else {
//                    self?.display.updateMeasurementButtonEnabled()
//                    self?.initNavBar()
//                }
//            }
//            .store(in: &subscriptions)
//
//        Task {
//            await viewModel.loadRecentResult()
//            await viewModel.loadMeasurements()
//        }
    }
}
// MARK: - Actions
private extension CMJHomeViewController {
    @objc func plusButtonAction(_ sender: UIBarButtonItem) {
        coordinator?.jumpModel = viewModel.recentModel
        guard let measurementModel = viewModel.measurementsModel else { return }
        coordinator?.measurementsModel = measurementModel
        coordinator?.recordNewJump()
    }
    @objc func measurementsButtonAction(_ sender: UIButton) {
        coordinator?.showMeasurements()
    }
    func setLoading(_ loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    func disableNew() {
        display.newJumpButton.isEnabled = false
        
    }
    func buttonAction(_ action: CMJHomeActions) {
        switch action {
        case .recordNewJump:
            guard let measurementModel = viewModel.measurementsModel else {return}
            coordinator?.jumpModel = viewModel.recentModel
            coordinator?.measurementsModel = measurementModel
            coordinator?.recordNewJump()
        case .myJumps:
            print("not done")
        case .myMeasurements:
            coordinator?.showMeasurements()
        }
    }
}
