//
//  AddMoreToExerciseViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddMoreToExerciseViewController: UIViewController {
    
    weak var coordinator: AddMoreToExerciseCoordinator?
    
    var display = AddMoreToExerciseView()
    
    var newExercise: exercise?
    
    var adapter: AddMoreToExerciseAdapter!
    
    var viewModel: AddMoreToExerciseViewModel = {
        return AddMoreToExerciseViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDisplay()
        initBarButton()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = UIColor.darkColour
        navigationItem.title = "Add More"
    }
    func initBarButton() {
        let barButton = UIBarButtonItem(title: "Finish", style: .done, target: self, action: #selector(continuePressed))
        navigationItem.rightBarButtonItem = barButton
    }
    func initDisplay() {
        adapter = .init(delegate: self)
        display.collectionView.delegate = adapter
        display.collectionView.dataSource = adapter
    }
}

extension AddMoreToExerciseViewController: AddMoreToExerciseProtocol {
    func getData(at indexPath: IndexPath) -> AddMoreCellModel {
        return viewModel.getData(at: indexPath)
    }
    
    func numberOfItems() -> Int {
        return viewModel.numberOfItems
    }
    
    func itemSelected(at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            coordinator?.timeSelected(viewModel.getData(at: indexPath))
        case 1:
            coordinator?.distanceSelected(viewModel.getData(at: indexPath))
        case 2:
            coordinator?.restTimeSelected(viewModel.getData(at: indexPath))
        case 3:
            coordinator?.noteSelected(viewModel.getData(at: indexPath))
        default:
            break
        }
    }  
}

extension AddMoreToExerciseViewController {
    @objc func continuePressed() {
        coordinator?.addNewExercise()
    }
}
