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


class EditProfileViewModel: ObservableObject {
    
    // MARK: - Publishers
    @Published var newProfileImage: UIImage?
    @Published var profileImage: UIImage?
    @Published var bioText: String = "" {
        didSet {
            if bioText.count > bioCharacterLimit {
                bioText = String(bioText.prefix(bioCharacterLimit))
            }
        }
    }
    @Published var saving = false
    @Published var imageSaved = false
    @Published var bioSaved = false
    
    var dismiss = PassthroughSubject<Bool,Never>()
    var imageError = PassthroughSubject<Error,Never>()
    var bioError = PassthroughSubject<Error,Never>()
    
    // MARK: - Computed Properties
    var canSave: Bool {
        newProfileImage != nil || bioText.trimTrailingWhiteSpaces() != UserDefaults.currentUser.profileBio
    }
    
    // MARK: - Properties
    private let bioCharacterLimit = 200
    var characterRemaining: Int {
        bioCharacterLimit - bioText.count
    }
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
                    self?.imageSaved = true
                    ImageCache.shared.replace(UserDefaults.currentUser.id, with: profileImage)
                case .failure(let error):
                    self?.imageError.send(error)
                    self?.saving = false
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
                self?.bioSaved = true
            case .failure(let error):
                self?.bioError.send(error)
                self?.saving = false
            }
        }
    }
    
    // MARK: - Functions
    func initSubscriptions() {
        
        Publishers.CombineLatest($bioSaved, $imageSaved)
            .map { $0 && $1 }
            .sink { [weak self] in self?.dismiss.send($0) }
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
