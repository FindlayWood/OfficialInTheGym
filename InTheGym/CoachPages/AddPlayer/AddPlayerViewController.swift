//
//  AddPlayerViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/06/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class AddPlayerViewController: UIViewController {
    
    // MARK: - Properties
    var display = AddPlayerView()
    var viewModel = AddPlayerViewModel()
    var dataSource: CoachRequestsDataSource!
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initDisplay()
        initDataSource()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    // MARK: - Display
    func initDisplay() {
        display.searchField.delegate = self
        display.tableview.backgroundColor = .secondarySystemBackground
        display.dismissButton.addTarget(self, action: #selector(dismissAction(_:)), for: .touchUpInside)
    }
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        dataSource.requestSent
            .sink { [weak self] in self?.viewModel.requestSent(at: $0)}
            .store(in: &subscriptions)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$loadingRequests
            .sink { [weak self] in self?.setInitialLoading(to: $0)}
            .store(in: &subscriptions)
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading($0)}
            .store(in: &subscriptions)
        viewModel.$cellModels
            .compactMap { $0 }
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        viewModel.initSubscriptions()
        viewModel.loadCurrentRequests()
    }
}
//MARK: - Actions
private extension AddPlayerViewController {
    func setLoading(_ loading: Bool) {
        if loading {
            display.activityIndicator.startAnimating()
        } else {
            display.activityIndicator.stopAnimating()
        }
    }
    func setInitialLoading(to loading: Bool) {
        if loading {
            display.activityIndicator.startAnimating()
            display.searchField.isUserInteractionEnabled = false
        } else {
            display.activityIndicator.stopAnimating()
            display.searchField.isUserInteractionEnabled = true
        }
    }
    @objc func dismissAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
// MARK: - Search Bar Delegate
extension AddPlayerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
