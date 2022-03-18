//
//  DescriptionUploadViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class DescriptionUploadViewModel {
    
    // MARK: - Publishers
    @Published var postText: String = ""
    @Published var canPost: Bool = false
    @Published var isLoading: Bool = false
    
    var postedPublisher = PassthroughSubject<Bool,Never>()
    
    var errorPublisher = PassthroughSubject<Error,Never>()
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    
    var descriptionModel: DescriptionModel!
    
    var listener: NewDescriptionListener?
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
        initSubscriptions()
    }
    
    func initSubscriptions() {
        
        $postText
            .dropFirst()
            .sink { [unowned self] in self.descriptionModel.description = $0 }
            .store(in: &subscriptions)
        
        $postText
            .map { return $0.count > 0 }
            .sink { [unowned self] in self.canPost = $0 }
            .store(in: &subscriptions)
        
    }
    
    // MARK: - Actions
    func updateText(with newText: String) {
        postText = newText
    }
    
    // MARK: - Functions
    func upload() {
        descriptionModel.time = Date().timeIntervalSince1970
        isLoading = true
        
        let uploadPoints = descriptionModel.uploadPoints()
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                self.postedPublisher.send(true)
                self.listener?.send(self.descriptionModel)
                self.isLoading = false
            case .failure(let error):
                self.errorPublisher.send(error)
                self.isLoading = false
            }
        }
    }
    
}
