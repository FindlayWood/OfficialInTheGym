//
//  ClipsView+ViewModel.swift
//  InTheGym
//
//  Created by Findlay-Personal on 27/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import Foundation

@MainActor
class ClipsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var clips: [ClipModel] = []
    
    // MARK: - Computed Properties
    @Published var filteredClips: [ClipModel] = []
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
        initSubscriptions()
    }
    
    // MARK: - Methods
    func fetchClips() async {
        isLoading = true
        let searchModel = UserClipsModel(id: UserDefaults.currentUser.uid)
        do {
            let keys: [KeyClipModel] = try await apiService.fetchInstanceAsync(of: searchModel)
            await loadClips(from: keys)
        } catch {
            print(String(describing: error))
            isLoading = false
        }
    }
    func loadClips(from keys: [KeyClipModel]) async {
        do {
            let clipModels: [ClipModel] = try await apiService.fetchRangeAsync(from: keys)
            let sortedClips = clipModels.sorted { $0.time > $1.time }
            clips = sortedClips
            isLoading = false
        } catch {
            print(String(describing: error))
            isLoading = false
        }
    }
    func filterSearch(_ text: String) {
        filteredClips = clips.filter { $0.exerciseName.contains(text) }
    }
    
    // MARK: - Subscriptions
    func initSubscriptions() {
        $searchText
            .filter { $0.count > 0 }
            .sink { [weak self] in self?.filterSearch($0) }
            .store(in: &subscriptions)
    }
}
