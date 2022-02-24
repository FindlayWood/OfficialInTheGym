//
//  ProgramCreationDetailViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class ProgramCreationDetailViewModel {
    // MARK: - Publishers
    @Published var title: String = ""
    @Published var canUpload: Bool = false
    @Published var isLoading: Bool = false
    
    var successfullyUploaded = PassthroughSubject<Bool,Never>()
    
    var descriptionText: String = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Properties
    var navigationTitle = "Program Detail"
    var navBarButtonTitle = "Upload"
    var uploadMessage = "Uploaded!"
    var errorMessage = "Error! Try again."
    
    var createdProgram: CreateProgramModel!
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
        initSubscriptions()
    }
    
    // MARK: - Subscriptions
    func initSubscriptions() {
        $title
            .map { return $0.count > 0 }
            .sink { [unowned self] in self.canUpload = $0 }
            .store(in: &subscriptions)
    }
    
    // MARK: - Actions
    func updateTitle(with newTitle: String) {
        title = newTitle
        createdProgram.title = newTitle
    }
    func updateDescription(with newText: String) {
        descriptionText = newText
        createdProgram.description = newText
    }
    func upload() {
        isLoading = true
        let savedProgramModel = SavedProgramModel(createdModel: createdProgram)
        apiService.uploadTimeOrderedModel(model: savedProgramModel) { [weak self] result in
            switch result {
            case .success(let model):
                self?.uploadRef(model)
            case .failure(_):
                self?.isLoading = false
                self?.successfullyUploaded.send(false)
            }
        }
    }
    
    func uploadRef(_ model: SavedProgramModel) {
        let refModel = MyProgramReferenceModel(id: model.id)
        apiService.multiLocationUpload(data: refModel.getUploadPoints()) { [weak self] result in
            switch result {
            case .success(()):
                self?.isLoading = false
                self?.successfullyUploaded.send(true)
            case .failure(_):
                self?.isLoading = false
                self?.successfullyUploaded.send(false)
            }
        }
    }
    
    // MARK: - Functions
}
