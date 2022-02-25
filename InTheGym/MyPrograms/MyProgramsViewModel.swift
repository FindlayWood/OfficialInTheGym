//
//  MyProgramsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class MyProgramsViewModel {
    
    // MARK: - Publishers
    var currentProgram = CurrentValueSubject<[ProgramModel],Never>([])
    var savedPrograms = CurrentValueSubject<[SavedProgramModel],Never>([])
    var completedPrograms = CurrentValueSubject<[ProgramModel],Never>([])
    @Published var isLoadingCurrentProgram: Bool = false
    @Published var isLoadingSavedPrograms: Bool = false
    @Published var isLoadingCompletedProgram: Bool = false
    
    var modelsToShow = CurrentValueSubject<MyProgramsToShow,Never>(.program([]))
    
    var selectedIndex = CurrentValueSubject<Int,Never>(0)
    
    // MARK: - Properties
    var navigationTitle = "My Programs"
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch
    func fetchSavedPrograms() {
        let fetchModel = MyProgramsDownloadModel()
        apiService.fetchKeys(from: fetchModel) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.loadSavedPrograms(from: keys)
            case .failure(_):
                break
            }
        }
    }
    func loadSavedPrograms(from keys: [String]) {
        let models = keys.map { SavedProgramDownloadModel(id: $0) }
        apiService.fetchRange(from: models, returning: SavedProgramModel.self) { [weak self] result in
            switch result {
            case .success(let programModels):
                self?.savedPrograms.send(programModels)
            case .failure(_):
                break
            }
        }
    }
    func fetchCompletedPrograms() {
        
    }
    func fetchCurrentProgram() {
        
    }
    
    // MARK: - Actions
    func setSelectedIndex(to index: Int) {
        selectedIndex.send(index)
        switch index {
        case 0:
            modelsToShow.send(MyProgramsToShow.program(currentProgram.value))
        case 1:
            modelsToShow.send(MyProgramsToShow.saved(savedPrograms.value))
        case 2:
            modelsToShow.send(MyProgramsToShow.program(completedPrograms.value))
        default:
            break
        }
    }
    
    // MARK: - Functions
}

enum MyProgramsToShow {
    case program([ProgramModel])
    case saved([SavedProgramModel])
}
