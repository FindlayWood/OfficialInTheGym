//
//  PublicClipsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class PublicClipsViewModel {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var clips: [ClipModel] = []
    @Published var searchText: String = ""
    private var storedClips: [ClipModel] = []
    private var filteredClips: [ClipModel] = []
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    public lazy var navigationTitle: String = "\(user.username) Clips"
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    var user: Users!
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func filterClips(with text: String) {
        if text.isEmpty {
            clips = storedClips
        } else {
            filteredClips = storedClips.filter { $0.exerciseName.lowercased().contains(text.trimTrailingWhiteSpaces().lowercased())}
            clips = filteredClips
        }
    }
    // MARK: - Functions
    func initSubscribers() {
        $searchText
            .sink { [weak self] in self?.filterClips(with: $0)}
            .store(in: &subscriptions)
    }
    public func fetchClipKeys() {
        isLoading = true
        let searchModel = UserClipsModel(id: user.uid)
        apiService.fetchInstance(of: searchModel, returning: KeyClipModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.loadClips(from: models)
            case .failure(_):
                self?.isLoading = false
                break
            }
        }
    }
    fileprivate func loadClips(from keys: [KeyClipModel]) {
        apiService.fetchRange(from: keys, returning: ClipModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                var filteredModels = models.filter { !($0.isPrivate) }
                filteredModels.sort { $0.time > $1.time }
                self?.clips = filteredModels
                self?.storedClips = filteredModels
                self?.isLoading = false
            case .failure(_):
                self?.isLoading = false
                break
            }
        }
    }
}

