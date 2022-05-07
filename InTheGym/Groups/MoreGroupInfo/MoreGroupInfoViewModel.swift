//
//  MoreGroupInfoViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine
import UIKit

class MoreGroupInfoViewModel {
    
    // MARK: - Publishers
    @Published private var validTitle: Bool = true
    @Published var infoUpdated: Bool = false
    @Published var isLoading: Bool = false
    
    var errorUpdating = PassthroughSubject<Error,Never>()
    var updatedGroup: PassthroughSubject<(GroupModel,UIImage?),Never>?
    
    // MARK: - Properties
    var groupModel: GroupModel!
    
    var newImage: UIImage? {
        didSet {
            infoUpdated = true
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    let descriptionPlaceholder = "description..."
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func updatetitle(_ newTitle: String) {
        groupModel.username = newTitle
        groupModel.title = newTitle
        infoUpdated = true
    }
    func updateDescription(_ newDescriptions: String) {
        groupModel.description = newDescriptions
        infoUpdated = true
    }
    func save() {
        isLoading = true
        if let newImage = newImage {
            let profileImageUpload = ProfileImageUploadModel(id: groupModel.uid, image: newImage)
            FirebaseStorageManager.shared.dataUpload(model: profileImageUpload) { [weak self] result in
                switch result {
                case .success(()):
                    self?.updateGroup()
                case .failure(let error):
                    self?.errorUpdating.send(error)
                    self?.isLoading = false
                }
            }
        } else {
            updateGroup()
        }
    }
    func updateGroup() {
        apiService.upload(data: groupModel, autoID: false) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                self.updatedGroup?.send((self.groupModel,self.newImage))
                self.isLoading = false
            case .failure(let error):
                self.errorUpdating.send(error)
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Functions
    func monitorTitle(on publisher: AnyPublisher<String,Never>) {
        publisher
            .map { $0.count > 0 }
            .sink { [weak self] in self?.validTitle = $0 }
            .store(in: &subscriptions)
        publisher
            .sink { [weak self] in self?.updatetitle($0)}
            .store(in: &subscriptions)
    }
    func monitorDescriptions(on publisher: AnyPublisher<String,Never>) {
        publisher
            .sink { [weak self] in self?.updateDescription($0)}
            .store(in: &subscriptions)
    }
}
