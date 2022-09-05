//
//  DisplayExerciseStatsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine
import SwiftUI

class DisplayExerciseStatsViewController: UIViewController {
    
    // MARK: - Properties
    var display = DisplayExerciseStatsView()
    
    var viewModel = DisplayExerciseStatsViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var dataSource: ExerciseStatsDataSource!

    var childContentView: ExerciseStatsListView!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addChildView()
//        initDataSource()
//        initAdapter()
        initViewModel()
//        hideKeyboardWhenTappedAround()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        display.frame = getViewableFrameWithBottomSafeArea()
//        view.addSubview(display)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Exercise Stats"
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        addSwiftUIViewWithNavBar(childContentView)
    }

    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
    }
  
    func initAdapter() {
        display.searchController.searchResultsUpdater = self
    }
    
    func initViewModel() {
        
//        viewModel.statModelPublisher
//            .sink { [weak self] in self?.dataSource.updateTable(with: $0) }
//            .store(in: &subscriptions)
//        
//        dataSource.exerciseSelected
//            .sink { [weak self] in self?.showDetail(for: $0)}
//            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading($0) }
            .store(in: &subscriptions)
        
        viewModel.selectedExercise
            .sink { [weak self] in self?.showDetail(for: $0) }
            .store(in: &subscriptions)
        
        viewModel.fetchStatModels()
    }
    
    func showDetail(for model: ExerciseStatsModel) {
        display.searchController.isActive = false
        let vc = ExerciseStatsDetailViewController()
        vc.viewModel.statsModel = model
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
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

extension DisplayExerciseStatsViewController {
    func setLoading(_ loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}
