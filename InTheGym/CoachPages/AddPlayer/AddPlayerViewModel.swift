//
//  AddPlayerViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class AddPlayerViewModel {
    
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
            apiService.searchTextQueryModel(model: searchModel, returning: Users.self) { [weak self] result in
                switch result {
                case .success(let returnedUsers):
                    let filteredUsers = returnedUsers.filter { !($0.admin) }
                    self?.initCellModels(from: filteredUsers)
                case .failure(let error):
                    print(String(describing: error))
                    self?.isLoading = false
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
    private func sendRequest(to user: Users) {
        self.isLoading = true
        let coachRequestModel = CoachRequestUploadModel(playerID: user.uid, coachID: UserDefaults.currentUser.uid)
        let playerRequestModel = PlayerRequestUploadModel(playerID: user.uid, coachID: UserDefaults.currentUser.uid)
        
        let uploadPoints: [FirebaseMultiUploadDataPoint] = [FirebaseMultiUploadDataPoint(value: true, path: coachRequestModel.internalPath), FirebaseMultiUploadDataPoint(value: true, path: playerRequestModel.internalPath)]
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            switch result {
            case .success(()):
                self?.isLoading = false
            case .failure(_):
                self?.isLoading = false
            }
        }
    }
    func requestSent(at indexPath: IndexPath) {
        let cellModel = cellModels[indexPath.item]
        requestSentUsers.append(cellModel.user.uid)
        sendRequest(to: cellModel.user)
    }
}
