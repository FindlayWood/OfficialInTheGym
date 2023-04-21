//
//  DiscoverMoreClipsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class DiscoverMoreClipsViewModel {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var clips: [ClipModel] = []
    @Published var searchText: String = ""
    private var storedClips: [ClipModel] = []
    private var filteredClips: [ClipModel] = []
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    var navigationTitle: String = "More Clips"
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
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
    
    @MainActor
    func loadClips() {
        isLoading = true
        Task {
            do {
                let models: [ClipModel] = try await apiService.fetchAsync()
                let filteredModels = models.filter { !($0.isPrivate) }
                clips = filteredModels
                storedClips = filteredModels
                isLoading = false
            } catch {
                print(String(describing: error))
                isLoading = false
            }
        }
    }
}
