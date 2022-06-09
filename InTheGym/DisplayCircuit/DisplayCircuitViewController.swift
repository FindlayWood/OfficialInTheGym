//
//  DisplayCircuitViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DisplayCircuitViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: DisplayCircuitCoordinator?
    var viewModel = DisplayCircuitViewModel()
    var display = DisplayCircuitView()
    var dataSource: CircuitDataSource!
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        initNavBar()
        initDataSource()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = viewModel.circuitModel.circuitName
        editNavBarColour(to: .white)
    }
    // MARK: - Nav Bar
    func initNavBar() {
        let barButton = UIBarButtonItem(title: "Completed", style: .done, target: self, action: #selector(completePressed(_:)))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isInteractionEnabled()
    }
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
        dataSource.updateCollection(with: viewModel.circuitModel.intergrate())
        dataSource.exerciseNameButtonAction
            .sink { [weak self] in self?.showExerciseDiscovery($0)}
            .store(in: &subscriptions)
        dataSource.completeButtonAction
            .sink { [weak self] in self?.completedCell(at: $0)}
            .store(in: &subscriptions)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0)}
            .store(in: &subscriptions)
        viewModel.updateModelPublisher
            .sink { [weak self] (newCell, indexPath) in
                self?.dataSource.updateCell(newCell: newCell, at: indexPath)}
            .store(in: &subscriptions)
        viewModel.completedCircuitPublisher
            .sink { [weak self] in self?.uploadedView()}
            .store(in: &subscriptions)
    }
    // MARK: - Actions
    @objc func completePressed(_ sender: UIButton){
        showCircuitRPE { score in
            self.viewModel.completeCircuit(with: score)
        }
    }
    func completedCell(at indexPath: IndexPath) {
        if viewModel.isInteractionEnabled() {
            guard let cell = display.collectionView.cellForItem(at: indexPath) else {return}
            cell.circuitFlash {
                self.viewModel.completedExercise(at: indexPath)
            }
        }
    }
    func uploadedView(){
        let showView = UIView()
        showView.backgroundColor = .white
        self.view.addSubview(showView)
        showView.frame = view.frame
        let label = UILabel()
        label.text = "Circuit Complete!"
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.textColor = .black
        showView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: showView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: showView.centerYAnchor).isActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showView.removeFromSuperview()
            self.coordinator?.completed()
        }
    }
}
// MARK: - Actions
private extension DisplayCircuitViewController {
    func showExerciseDiscovery(_ model: CircuitTableModel) {
        let discoverModel = DiscoverExerciseModel(exerciseName: model.exerciseName)
        coordinator?.showExerciseDiscovery(discoverModel)
    }
    func setLoading(to loading: Bool) {
        if loading {
            initLoadingNavBar(with: .white)
        } else {
            initNavBar()
        }
    }
}
