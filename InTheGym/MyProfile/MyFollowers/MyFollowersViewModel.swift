//
//  MyFollowersViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class MyFollowersViewModel: ObservableObject {
    
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var usersToShow: [Users] = []
    @Published var searchText: String = ""
    @Published var optionSelected: FollowerFollowingOptions = .followers
    private var storedFollowers: [Users] = []
    private var storedFollowing: [Users] = []
    var filteredFollowers: [Users] = []
    
    // MARK: - Properties
    @Published var navigationTitle: String = "Followers"
    private var subscriptions = Set<AnyCancellable>()
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func switchSegment(to option: FollowerFollowingOptions) {
        usersToShow = option == .following ? storedFollowing : storedFollowers
        navigationTitle = option == .following ? "Following" : "Followers"
        optionSelected = option
    }
    
    // MARK: - Functions
    func initSubscribers() {
        $searchText
            .sink { [weak self] in self?.filterFollowers(with: $0)}
            .store(in: &subscriptions)
    }
    func fetchFollowerKeys() {
        isLoading = true
        let followerModel = FollowersModel(id: UserDefaults.currentUser.uid)
        apiService.fetchKeys(from: followerModel) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.loadFollowers(from: keys)
            case .failure(let error):
                print(String(describing: error))
                self?.isLoading = false
                break
            }
        }

    }
    private func loadFollowers(from keys: [String]) {
        let models = keys.map { UserSearchModel(uid: $0) }
        UsersLoader.shared.loadRange(from: models) { [weak self] result in
            switch result {
            case .success(let followers):
                self?.usersToShow = followers
                self?.storedFollowers = followers
                self?.isLoading = false
            case .failure(let error):
                print(String(describing: error))
                self?.isLoading = false
                break
            }
        }
    }
    func fetchFollowingKeys() {
        isLoading = true
        let followingModel = FollowingModel(id: UserDefaults.currentUser.uid)
        apiService.fetchKeys(from: followingModel) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.loadFollowing(from: keys)
            case .failure(let error):
                print(String(describing: error))
                self?.isLoading = false
                break
            }
        }

    }
    private func loadFollowing(from keys: [String]) {
        let models = keys.map { UserSearchModel(uid: $0) }
        UsersLoader.shared.loadRange(from: models) { [weak self] result in
            switch result {
            case .success(let followers):
                self?.storedFollowing = followers
                self?.isLoading = false
            case .failure(let error):
                print(String(describing: error))
                self?.isLoading = false
                break
            }
        }
    }
    
    func filterFollowers(with text: String) {
        if text.isEmpty {
            usersToShow = Array(storedFollowers)
        } else {
            filteredFollowers = storedFollowers.filter { $0.username.contains(text)}
            usersToShow = storedFollowers
        }
    }
}

enum FollowerFollowingOptions: CaseIterable {
    
    case followers
    case following
    
    var title: String {
        switch self {
        case .following:
            return "Following"
        case .followers:
            return "Followers"
        }
    }
}
