//
//  AddPlayerViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class AddPlayerViewModel: ObservableObject {
    
    // MARK: - Publishers
    @Published var cellModels: [CoachRequestCellModel] = []
    @Published var username: String = ""
    @Published var canAdd: Bool = false
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var loadingRequests: Bool = false
    var requestSentUsers: [String] = []
    
    // MARK: - Properties
    var currentPlayers: [Users]!
    
    var searchModel: UsernameSearchModel = UsernameSearchModel(equalTo: "")
    
    private var subscriptions = Set<AnyCancellable>()
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
        initSubscriptions()
    }
    
    // MARK: - Subscriptions
    func initSubscriptions() {
        $searchText
            .sink { [weak self] in self?.searchModel.equalTo = $0 }
            .store(in: &subscriptions)
        $searchText
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] in self?.search($0) }
            .store(in: &subscriptions)
    }
    
    // MARK: - Actions
    func search(_ text: String) {
        if !text.isEmpty {
            isLoading = true
            Task { @MainActor in
                do {
                    let models: [Users] = try await apiService.searchTextQueryModelAsync(model: searchModel)
                    let filteredUsers = models.filter { !($0.accountType == .coach) }
                    initCellModels(from: filteredUsers)
                } catch {
                    isLoading = false
                }
            }
        }
    }
    func initCellModels(from users: [Users]) {
        var cellModels: [CoachRequestCellModel] = []
        for user in users {
            if currentPlayers.contains(user) {
                cellModels.append(.init(user: user, requestStatus: .accepted))
            } else if requestSentUsers.contains(user.uid) {
                cellModels.append(.init(user: user, requestStatus: .sent))
            } else {
                cellModels.append(.init(user: user, requestStatus: .none))
            }
        }
        self.cellModels = cellModels
        self.isLoading = false
    }
    
    // MARK: - Functions
    func loadCurrentRequests() {
        loadingRequests = true
        let searchModel = CoachRequestsModel(coachID: UserDefaults.currentUser.uid)
        apiService.fetchKeys(from: searchModel) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.requestSentUsers = keys
                self?.loadingRequests = false
            case .failure(let error):
                print(String(describing: error))
                self?.loadingRequests = false
            }
        }
    }
}
