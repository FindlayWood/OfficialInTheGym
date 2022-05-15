//
//  SearchViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class SearchViewModel {
    
    // MARK: - Publishers
    @Published var isSearching: Bool = false
    @Published var initialUsers: [Users] = []
    @Published var searchText: String = ""
    var returnedSearchUser = PassthroughSubject<Users,Never>()
    var storedInitialUsers = Set<Users>()
    var filteredInitialUsers: [Users] = []
    
    // MARK: - Properties
    var navigationTitle: String = "Search"
    
    var searchModel: UsernameSearchModel = UsernameSearchModel(equalTo: "")
    
    private var subscriptions = Set<AnyCancellable>()
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func initSubscribers() {
        $searchText
            .sink { [weak self] in self?.searchModel.equalTo = $0 }
            .store(in: &subscriptions)
        $searchText
            .sink { [weak self] in self?.filterInitialUsers(with: $0)}
            .store(in: &subscriptions)
    }
    func loadInitialUsers() {
        apiService.fetchLimited(model: Users.self, limit: 20) { [weak self] result in
            switch result {
            case .success(let initalModels):
                self?.storedInitialUsers = Set(initalModels)
                self?.initialUsers = initalModels
            case .failure(let error):
                print(String(describing: error))
                break
            }
        }
    }
    func searchDatabase() {
        isSearching = true
        apiService.searchQueryModel(model: searchModel, returning: Users.self) { [weak self] result in
            switch result {
            case .success(let newUser):
                self?.returnedSearchUser.send(newUser)
                self?.storedInitialUsers.insert(newUser)
                self?.isSearching = false
            case .failure(let error):
                print(String(describing: error))
                self?.isSearching = false
            }
        }
    }
    func filterInitialUsers(with text: String) {
        if text.isEmpty {
            initialUsers = Array(storedInitialUsers)
        } else {
            filteredInitialUsers = storedInitialUsers.filter { $0.username.contains(text)}
            initialUsers = filteredInitialUsers
        }
    }
}
