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
    @Published var username: String = ""
    @Published var canAdd: Bool = false
    @Published var isLoading: Bool = false
    
    var nilUserError = PassthroughSubject<Error,Never>()
    var errorSearchingUser = PassthroughSubject<Error,Never>()
    var requestExists = PassthroughSubject<Users,Never>()
    
    var alreadyPlayer = PassthroughSubject<Users,Never>()
    var successfullySentRequest = PassthroughSubject<Bool,Never>()
    
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
        
        $username
            .map { $0.count > 0 }
            .sink { [unowned self] in self.canAdd = $0 }
            .store(in: &subscriptions)
    }
    
    // MARK: - Actions
    func updateSearchModel(with username: String) {
        searchModel.equalTo = username
        self.username = username
    }
    
    // MARK: - Functions
    private func searchForUser() {
        apiService.searchQueryModel(model: searchModel, returning: Users.self) { [weak self] result in
            switch result {
            case .success(let user):
                self?.checkForRequest(user)
            case .failure(let error):
                self?.nilUserError.send(error)
                self?.isLoading = false
            }
        }
    }
    
    func checkAlreadyCoach() {
        isLoading = true
        let filteredUsers = currentPlayers.filter { $0.username == searchModel.equalTo }
        if let user = filteredUsers.first {
            alreadyPlayer.send(user)
            isLoading = false
        } else {
            searchForUser()
        }
    }
    
    private func checkForRequest(_ user: Users) {
        let coachRequestModel = CoachRequestUploadModel(playerID: user.uid, coachID: UserDefaults.currentUser.uid)
        apiService.checkExistence(of: coachRequestModel) { [weak self] result in
            switch result {
            case .success(let exists):
                if exists {
                    self?.requestExists.send(user)
                    self?.isLoading = false
                } else {
                    self?.sendRequest(to: user)
                }
            case .failure(let error):
                self?.errorSearchingUser.send(error)
                self?.isLoading = false
            }
        }
    }
    
    private func sendRequest(to user: Users) {
        let coachRequestModel = CoachRequestUploadModel(playerID: user.uid, coachID: UserDefaults.currentUser.uid)
        let playerRequestModel = PlayerRequestUploadModel(playerID: user.uid, coachID: UserDefaults.currentUser.uid)
        
        let uploadPoints: [FirebaseMultiUploadDataPoint] = [FirebaseMultiUploadDataPoint(value: true, path: coachRequestModel.internalPath), FirebaseMultiUploadDataPoint(value: true, path: playerRequestModel.internalPath)]
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            switch result {
            case .success(()):
                self?.successfullySentRequest.send(true)
                self?.isLoading = false
                self?.sendNotification(to: user)
            case .failure(_):
                self?.successfullySentRequest.send(false)
                self?.isLoading = false
            }
        }
    }
    
    private func sendNotification(to user: Users) {
        NotificationManager().send(.sentRequest(sendTo: user.uid)) { [weak self] result in
            print("doe")
        }
    }
}
