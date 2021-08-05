//
//  DisplayExerciseStatsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplayExerciseStatsViewController: UIViewController {
    
    var display = DisplayExerciseStatsView()
    var adapter: DisplayExerciseStatsAdapter!
    var firebaseService = FirebaseAPILoader.shared
    lazy var viewModel: DisplayExerciseStatsViewModel = {
        return DisplayExerciseStatsViewModel(firebaseService: firebaseService)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initAdapter()
        initViewModel()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: Constants.screenSize.width, height: Constants.screenSize.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Exercise Stats"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: Constants.darkColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.darkColour
    }

  
    func initAdapter() {
        adapter = DisplayExerciseStatsAdapter(delegate: self)
        display.tableview.delegate = adapter
        display.tableview.dataSource = adapter
        display.tableview.register(ExerciseStatsTitleCell.self, forCellReuseIdentifier: "titleCell")
        display.tableview.register(ExerciseStatsSectionCell.self, forCellReuseIdentifier: "sectionCell")
        display.searchController.searchResultsUpdater = self
    }
    
    func initViewModel() {
        viewModel.reloadCollectionViewClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.display.tableview.reloadData()
            }
        }
        
        viewModel.updateLoadingStatusClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                let isLoading = self.viewModel.isLoading
                if isLoading {
                    self.display.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.display.tableview.alpha = 0.0
                    })
                } else {
                    self.display.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.display.tableview.alpha = 1.0
                    })
                }
            }
        }
        viewModel.filteredResultsClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.display.tableview.reloadData()
            }
        }
        viewModel.fetchData()
    }
    

}

extension DisplayExerciseStatsViewController: DisplayExerciseStatsProtocol {
    func getData(at indexPath: IndexPath) -> DisplayExerciseStatsModel {
        if display.isFiltering {
            return viewModel.getData(from: viewModel.filteredExercises, at: indexPath)
        } else {
            return viewModel.getData(from: viewModel.exercises, at: indexPath)
        }
    }
    
    func getTitleCellData(at indexPath: IndexPath) -> String {
        if display.isFiltering {
            return viewModel.getTitleCellData(from: viewModel.filteredExercises, at: indexPath)
        } else {
            return viewModel.getTitleCellData(from: viewModel.exercises, at: indexPath)
        }
    }
    
    func getSectionCellData(at indexPath: IndexPath) -> SectionCellModel {
        if display.isFiltering {
            return viewModel.getSectionCellData(from: viewModel.filteredExercises, at: indexPath)
        } else {
            return viewModel.getSectionCellData(from: viewModel.exercises, at: indexPath)
        }
    }
    
    func numberOfItems() -> Int {
        if display.isFiltering {
            return viewModel.numberOfFilteredItems
        } else {
            return viewModel.numberOfItems
        }
    }
    
    func getSectionState(at section: Int) -> sectionState {
        if display.isFiltering {
            return viewModel.getSectionState(from: viewModel.filteredExercises, at: section)
        } else {
            return viewModel.getSectionState(from: viewModel.exercises, at: section)
        }
    }
    
    func changeSectionState(at section: Int) {
        
        if display.isFiltering {
            if viewModel.filteredExercises[section].sectionState == .collapsed {
                viewModel.filteredExercises[section].sectionState = .expanded
                let sections = IndexSet.init(integer: section)
                display.tableview.reloadSections(sections, with: .none)
                display.tableview.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
            } else {
                viewModel.filteredExercises[section].sectionState = .collapsed
                let sections = IndexSet.init(integer: section)
                display.tableview.reloadSections(sections, with: .none)
            }
        } else {
            if viewModel.exercises[section].sectionState == .collapsed {
                viewModel.exercises[section].sectionState = .expanded
                let sections = IndexSet.init(integer: section)
                display.tableview.reloadSections(sections, with: .none)
                display.tableview.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
            } else {
                viewModel.exercises[section].sectionState = .collapsed
                let sections = IndexSet.init(integer: section)
                display.tableview.reloadSections(sections, with: .none)
            }
        }
    }
}

extension DisplayExerciseStatsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // If the search bar contains text, filter out data with the string
        if let searchText = searchController.searchBar.text {
            viewModel.filterExercises(from: searchText)
        }
    }

}
