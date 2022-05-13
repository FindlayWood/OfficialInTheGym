//
//  EditProfileViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//


import Foundation
import Combine
import UIKit


class EditProfileViewModel {
    
    // MARK: - Publishers
    @Published var profileImage: UIImage?
    @Published var bioText: String = ""
    
    var imageError = PassthroughSubject<Error,Never>()
    var bioError = PassthroughSubject<Error,Never>()
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
        initSubscriptions()
    }
    
    // MARK: - Actions
    func saveImage() {
        if let profileImage = profileImage {
            let uploadImageModel = ProfileImageUploadModel(id: UserDefaults.currentUser.uid, image: profileImage)
            FirebaseStorageManager.shared.dataUpload(model: uploadImageModel) { [weak self] result in
                switch result {
                case .success(()):
                    break
                case .failure(let error):
                    self?.imageError.send(error)
                }
            }
        }
    }
    func saveBio() {
        UserDefaults.currentUser.profileBio = bioText
        let editProfileBioModel = EditProfileBioModel(newBio: bioText)
        let uploadPoint = editProfileBioModel.uploadPoint
        apiService.multiLocationUpload(data: [uploadPoint]) { [weak self] result in
            switch result {
            case .success(()):
                break
            case .failure(let error):
                self?.bioError.send(error)
            }
        }
    }
    
    // MARK: - Functions
    func initSubscriptions() {
        
        $bioText
            .dropFirst()
            .debounce(for: 5, scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveBio() }
            .store(in: &subscriptions)
        
        $profileImage
            .dropFirst()
            .sink { [weak self] _ in self?.saveImage() }
            .store(in: &subscriptions)
    }
    
    func initialLoad() {
        let imageSearchModel = ProfileImageDownloadModel(id: UserDefaults.currentUser.uid)
        ImageCache.shared.load(from: imageSearchModel) { [weak self] result in
            guard let image = try? result.get() else {return}
            self?.profileImage = image
        }
        bioText = UserDefaults.currentUser.profileBio ?? ""
    }
}
