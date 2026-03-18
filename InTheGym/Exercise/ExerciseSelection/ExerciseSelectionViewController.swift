//
//  ExerciseSelectionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit


class ExerciseSelectionViewController: UIViewController {
    
    //MARK: - Properties
    weak var coordinator: ExerciseSelectionFlow?
    
    var display = ExerciseSelectionView()
    
    var viewModel = ExerciseSelectionViewModel()
    
    var adapter: ExerciseSelectionAdapter!
    
    var workoutCreationViewModel: ExerciseAdding!

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initViewModel()
        initDisplay()
        initNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.reloadCollectionClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.display.collectionView.reloadData()
            }
        }
        
        viewModel.updateLoadingStatusClosure = { [weak self] in
            guard let self = self else {return}
            if self.viewModel.isLoading {
                UIView.animate(withDuration: 0.3) {
                    self.display.collectionView.alpha = 0.0
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.display.collectionView.alpha = 1.0
                }
            }
        }
        viewModel.loadExercises()
    }
    
    func initDisplay() {
        adapter = .init(delegate: self)
        display.collectionView.delegate = adapter
        display.collectionView.dataSource = adapter
        display.searchBar.delegate = self
    }
    func initNavBar() {
        navigationItem.title = "Select Exercise"
        let otherButton = UIBarButtonItem(title: "Other", style: .done, target: self, action: #selector(otherTapped(_:)))
        navigationItem.rightBarButtonItem = otherButton
    }
    
    @objc func otherTapped(_ sender: UIBarButtonItem) {
        coordinator?.otherSelected(viewModel.exercise)
    }
}


extension ExerciseSelectionViewController: ExerciseSelectionProtocol {
    func getData(at indexPath: IndexPath) -> String {
        return viewModel.getData(at: indexPath)
    }
    func numberOfItems(at section: Int) -> Int {
        return viewModel.numberOfItems(at: section)
    }
    func numberOfSections() -> Int {
        return viewModel.numberOfSections()
    }
    func itemSelected(at indexPath: IndexPath) {
        let exercise = viewModel.getData(at: indexPath)
        let type = viewModel.getBodyType(from: indexPath)
        viewModel.exercise.exercise = exercise
        viewModel.exercise.type = type
        coordinator?.exerciseSelected(viewModel.exercise)
    }
    func infoButtonSelected(at indexPath: IndexPath) {
        let exercise = viewModel.getData(at: indexPath)
        let discoverModel = DiscoverExerciseModel(exerciseName: exercise)
        coordinator?.infoSelected(discoverModel)
    }
}

extension ExerciseSelectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterExercises(with: searchText)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        display.searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        display.searchBar.resignFirstResponder()
    }
}
