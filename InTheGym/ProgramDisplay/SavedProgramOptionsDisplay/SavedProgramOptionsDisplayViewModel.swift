//
//  SavedProgramOptionsDisplayViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class SavedProgramOptionsDisplayViewModel {
    
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var currentOptions: [Options]!
    var makedCurrentProgram: CurrentValueSubject<CurrentProgramModel? ,Never>!
    var addedSavedProgram = PassthroughSubject<SavedProgramModel,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    var baseOptions: [Options] = [.makeCurrentProgram, .viewCreatorProfile, .review]
    
    var savedProgram: SavedProgramModel!
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func optionSelected(_ option: Options) {
        print(option)
        switch option {
        case .makeCurrentProgram:
            makeCurrentProgram()
        case .save:
            saveProgram()
        default:
            break
        }
    }
    // MARK: - Functions
    func loadOptions() {
        isLoading = true
        if UserDefaults.currentUser.accountType == .coach { baseOptions.append(.assign) }
        let refModel = MyProgramReferenceModel(id: savedProgram.id)
        apiService.checkExistence(of: refModel) { [weak self] result in
            guard let self = self else {return}
            defer {
                self.isLoading = false
                self.currentOptions = self.baseOptions
            }
            switch result {
            case .success(let exists):
                if !exists {
                    self.baseOptions.append(.save)
                }
            case .failure(_):
                self.baseOptions.append(.save)
            }
        }
    }
    
    // MARK: - Save
    func saveProgram() {
        let refModel = MyProgramReferenceModel(id: savedProgram.id)
        apiService.multiLocationUpload(data: refModel.getUploadPoints()) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                self.addedSavedProgram.send(self.savedProgram)
            case .failure(_):
                break
            }
        }
    }
    
    func makeCurrentProgram() {
        let currentProgramModel = CurrentProgramModel(savedProgram)
        makedCurrentProgram.send(currentProgramModel)
//        apiService.upload(data: currentProgramModel, autoID: false) { [weak self] result in
//            switch result {
//            case .success(()):
//                self?.makedCurrentProgram.send(currentProgramModel)
//            case .failure(_):
//                break
//            }
//        }
    }
    
}
