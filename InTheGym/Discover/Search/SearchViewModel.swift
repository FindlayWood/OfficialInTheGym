//
//  SearchViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    
    // MARK: - Publishers
    @Published var isSearching: Bool = false
    @Published var searchedUsers: [Users] = []
    @Published var searchText: String = ""
    
    // MARK: - Properties
    var navigationTitle: String = "Search"
    
    var searchModel: UsernameSearchModel = UsernameSearchModel(equalTo: "")
    
    private var subscriptions = Set<AnyCancellable>()
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Functions
    func initSubscribers() {
        $searchText
            .sink { [weak self] in self?.searchModel.equalTo = $0 }
            .store(in: &subscriptions)
        $searchText
            .filter { $0.isEmpty }
            .sink { [weak self] _ in self?.searchedUsers = [] }
            .store(in: &subscriptions)
        $searchText
            .filter { $0.count > 0 }
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] in self?.searchDatabase($0.lowercased())}
            .store(in: &subscriptions)
    }
    func searchDatabase(_ text: String) {
        isSearching = true
        Task {
            do {
                let users: [Users] = try await apiService.searchTextQueryModelAsync(model: searchModel)
                let filteredUsers = users.filter { $0.uid != UserDefaults.currentUser.uid }
                searchedUsers = filteredUsers
                isSearching = false
            } catch {
                print(String(describing: error))
                isSearching = false
            }
        }
    }
}
