//
//  ExerciseDescriptionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ExerciseDescriptionViewController: UIViewController {

    // MARK: - Properties
    
    var display = ExerciseDescriptionView()
    
    var viewModel = ExerciseDescriptionViewModel()
    
    var descriptionsVC = DescriptionsViewController()
    
    var clipsVC = ExerciseClipsViewController()
    
    var tagsVC = ExerciseTagsViewController()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubscriptions()
        descriptionsVC.viewModel.exerciseModel = viewModel.exercise
        clipsVC.viewModel.exerciseModel = viewModel.exercise
        tagsVC.viewModel.exerciseModel = viewModel.exercise
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = viewModel.exercise.exerciseName
        editNavBarColour(to: .darkColour)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.selectedIndex == 0 {
            addToContainer(vc: clipsVC)
        } else if viewModel.selectedIndex == 1 {
            addToContainer(vc: descriptionsVC)
        } else {
            addToContainer(vc: tagsVC)
        }
    }
    // MARK: - Container
    func addToContainer(vc controller: UIViewController) {
        addChild(controller)
        display.addSubview(controller.view)
        controller.view.frame = display.containerView.frame
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.didMove(toParent: self)
    }
    
    func removeFromContainer(vc controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
    
    // MARK: - Subscriptions
    func initSubscriptions() {
        display.segmentControl.selectedIndex
            .sink { [weak self] in self?.segmentChanged(to: $0) }
            .store(in: &subscriptions)
    }
    
    // MARK: - Switch Segment
    func segmentChanged(to index: Int) {
        viewModel.selectedIndex = index
        if index == 0 {
            removeFromContainer(vc: descriptionsVC)
            removeFromContainer(vc: tagsVC)
            addToContainer(vc: clipsVC)
        } else if index == 1 {
            removeFromContainer(vc: clipsVC)
            removeFromContainer(vc: tagsVC)
            addToContainer(vc: descriptionsVC)
        } else {
            removeFromContainer(vc: clipsVC)
            removeFromContainer(vc: descriptionsVC)
            addToContainer(vc: tagsVC)
        }
    }
}
