//
//  SearchViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class SearchViewController: UIViewController {

    var display = SearchView()
    
    var dataSource: UsersDataSource!
    
    var viewModel = SearchViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func loadView() {
        view = display
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDataSource()
        initViewModel()
        display.searchField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = viewModel.navigationTitle
        editNavBarColour(to: .darkColour)
    }
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        
    }
    func initViewModel() {
        viewModel.$isSearching
            .sink { [weak self] in self?.setNavBar($0)}
            .store(in: &subscriptions)
        viewModel.$initialUsers
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        viewModel.returnedSearchUser
            .sink { [weak self] in self?.dataSource.insertFirst($0)}
            .store(in: &subscriptions)
        viewModel.loadInitialUsers()
        viewModel.initSubscribers()
    }
}
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.searchDatabase()
    }
}
private extension SearchViewController {
    func setNavBar(_ searching: Bool) {
        if searching {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}


// MARK: - IMPORTANT!
/// Text search is not supported by Firebase which makes this feature tricky
/// They have some suggestions to use third parties to search but these seem to be for Firestore and cost money
/// So the only solution i can see that might work is as follows
///
/// Create three separate searches for firstname, lastname and username using the below method
/// Ending the query with uf8ff is a very high code point in the Unicode range and it is after most regular characters in Unicode
///
/// databaseReference.orderByChild('_searchFirstName')
///    .startAt(queryText)
///    .endAt(queryText+"uf8ff")
// MARK: - Update!
/// This now works by initial loading 20 users from the database
/// These users are then filtered when the search bar receives text
/// If the search bar is tapped the database will be searched for matching username
/// If found this user will be inserted into the loaded users
