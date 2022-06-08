//
//  WorkoutCreationOptionsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class WorkoutCreationOptionsViewModel {
    // MARK: - Publishers
    @Published var currentTags: [ExerciseTagReturnModel]!
    var addNewTagPublisher: PassthroughSubject<ExerciseTagReturnModel,Never>!
    var toggledSaving: PassthroughSubject<Void,Never>?
    var toggledPrivacy: PassthroughSubject<Void,Never>?
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    private var subscriptions = Set<AnyCancellable>()
    var saving: Bool!
    var isPrivate: Bool!
    var assignTo: Users?
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Actions
    
    // MARK: - Functions
    func initSubscriptions() {
        addNewTagPublisher
            .sink { [weak self] in self?.currentTags.append($0)}
            .store(in: &subscriptions)
    }
}
