//
//  AddWorkoutTagsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class AddWorkoutTagsViewModel {
    // MARK: - Publishers
    @Published var canAdd: Bool = false
    @Published var text: String = ""
    var addNewTagPublisher: PassthroughSubject<ExerciseTagReturnModel,Never>!
    var alreadyExists = PassthroughSubject<Void,Never>()
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var currentTags: [ExerciseTagReturnModel] = []
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Actions
    func addButtonAction() {
        if checkTags() {
            let tag = text.lowercased().filter { !$0.isWhitespace }
            let model = ExerciseTagReturnModel(tag: tag)
            addNewTagPublisher.send(model)
        } else {
            alreadyExists.send(())
        }
    }
    // MARK: - Functions
    func initSubscriptions() {
        $text
            .map { $0.count > 1 }
            .sink { [weak self] in self?.canAdd = $0}
            .store(in: &subscriptions)
    }
    func checkTags() -> Bool {
        let newTag = text.lowercased().filter { !$0.isWhitespace }
        for tag in currentTags {
            if tag.tag == newTag {
                return false
            }
        }
        return true
    }
}
