//
//  ExerciseClipsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class ExerciseClipsViewModel {
    
    // MARK: - Publishers
    var keyClipPublisher = CurrentValueSubject<[KeyClipModel],Never>([])
    var clipModelPublisher = CurrentValueSubject<[ClipModel],Never>([])
    var addedClipPublisher = PassthroughSubject<ClipModel,Never>()
    
    // MARK: - Properties
    var exerciseModel: ExerciseModel!
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Clips
    func fetchClipKeys() {
        let exerciseClipModel = ExerciseClipsModel(exerciseName: exerciseModel.exercise)
        apiService.fetchInstance(of: exerciseClipModel, returning: KeyClipModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.loadClips(from: models)
            case .failure(_):
                break
            }
        }
    }
    
    func loadClips(from keyModels: [KeyClipModel]) {
        apiService.fetchRange(from: keyModels, returning: ClipModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                let filteredModels = models.filter { !($0.isPrivate) }
                self?.clipModelPublisher.send(filteredModels)
            case .failure(_):
                break
            }
        }
    }
}

// MARK: - Adding Protocol
extension ExerciseClipsViewModel: ClipAdding {
    func addClip(_ model: ClipModel) {
        self.addedClipPublisher.send(model)
    }
}
