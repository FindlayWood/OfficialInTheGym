//
//  DiscoverMoreTagsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class DiscoverMoreTagsViewModel {
    
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var cellModels: [TagAndExerciseCellModel] = []
    var tagModels: [TagModel] = []
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    var navigationTitle: String = "Tags"
    
    var searchTagModel: TagSearchModel = .init(equalTo: "")
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func search(_ text: String) {
        if text.isEmpty {
            
        } else {
            isLoading = true
            Task { @MainActor in
                do {
                    let models: [TagModel] = try await apiService.searchTextQueryModelAsync(model: searchTagModel)
                    getExericses(from: models)
                    tagModels = models
                } catch {
                    print(String(describing: error))
                    isLoading = false
                }
            }
        }
    }
    func getExericses(from tags: [TagModel]) {
        let newCellModels = tags.map { tag in
            tag.exercises.map { exercise in
                TagAndExerciseCellModel(tag: tag.tagName, exercise: exercise.value)
            }
        }
        let flatModels = newCellModels.flatMap { $0 }
        cellModels = flatModels
        isLoading = false
    }
    
    // MARK: - Functions
    func initSubscriptions() {
        $searchText
            .sink { [weak self] in self?.searchTagModel.equalTo = $0.lowercased() }
            .store(in: &subscriptions)
        $searchText
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] in self?.search($0.lowercased())}
            .store(in: &subscriptions)
    }
}
