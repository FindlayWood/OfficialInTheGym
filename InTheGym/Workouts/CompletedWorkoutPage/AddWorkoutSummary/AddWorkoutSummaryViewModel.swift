//
//  AddWorkoutSummaryViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class AddWorkoutSummaryViewModel {
    // MARK: - Publishers
    @Published var canSave: Bool = false
    @Published var text: String = ""
    var addedSummaryPublisher: PassthroughSubject<String,Never>?
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var placeholder: String = "add summary..."
    var workoutModel: WorkoutModel!
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Actions
    func updateText(with newText: String) {
        text = newText.trimTrailingWhiteSpaces()
    }
    func saveAction() {
        workoutModel.summary = text
        addedSummaryPublisher?.send(text)
    }
    // MARK: - Functions
    func initSubscriptions() {
        $text
            .map { $0.count > 2 }
            .sink { [weak self] in self?.canSave = $0 }
            .store(in: &subscriptions)
    }
}
