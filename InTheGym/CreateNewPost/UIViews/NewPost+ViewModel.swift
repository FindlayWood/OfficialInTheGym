//
//  NewPost+ViewModel.swift
//  InTheGym
//
//  Created by Findlay-Personal on 27/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import Foundation

class NewPostViewModel: Attachments {
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var text: String = ""
    @Published var placeholder: String = "enter text..."
    
    @Published var attachedWorkout: WorkoutModel?
    @Published private(set) var attachedSavedWorkout: SavedWorkoutModel?
    @Published var attachedClip: ClipModel?
    @Published private(set) var taggedUsers: [Users] = []
    @Published private(set) var isPrivate: Bool = false
    
    @Published var successfullyPosted: Bool?
    @Published var errorPosting: Error?
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService
    var postable: Postable! /// postable - either post or group post
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
        initSubscriptions()
    }
    // MARK: - Subscriptions
    func initSubscriptions() {
        $text
            .dropFirst()
            .compactMap { $0 }
            .sink { [weak self] in self?.postable.text = $0 }
            .store(in: &subscriptions)
        $isPrivate
            .dropFirst()
            .sink { [weak self] in self?.postable.isPrivate = $0 }
            .store(in: &subscriptions)
        $taggedUsers
            .dropFirst()
            .sink { [weak self] in self?.postable.taggedUsers = $0.map { $0.uid }}
            .store(in: &subscriptions)
        $attachedWorkout
            .dropFirst()
            .compactMap { $0 }
            .sink { [weak self] in self?.postable.workoutID = $0.id }
            .store(in: &subscriptions)
        $attachedSavedWorkout
            .dropFirst()
            .compactMap { $0 }
            .sink { [weak self] in self?.postable.savedWorkoutID = $0.id }
            .store(in: &subscriptions)
    }
    // MARK: - Methods
    func updateAttachedTaggedUser(_ user: Users) {
        if !taggedUsers.contains(where: { $0.uid == user.uid }) {
            taggedUsers.append(user)
        }
    }
    func removeTaggedUsers(at offsets: IndexSet) {
        taggedUsers.remove(atOffsets: offsets)
    }
    func updateAttachedSavedWorkout(with model: SavedWorkoutModel) {
        attachedSavedWorkout = model
    }
    func removeAttachedSavedWorkout() {
        attachedSavedWorkout = nil
        postable.savedWorkoutID = nil
    }
    func updateAttachedWorkout(with model: WorkoutModel) {
        attachedWorkout = model
    }
    func updatePrivacy(to isPrivate: Bool) {
        self.isPrivate = isPrivate
    }
    // MARK: - Actions
    func postAction() {
        isLoading = true
        postable.time = Date().timeIntervalSince1970
        if let postModel = postable as? PostModel {
            post(postModel)
        }
    }
    
    private func post<Model>(_ model: Model) where Model: Postable {
        apiService.uploadTimeOrderedModel(model: model) { [weak self] result in
            switch result {
            case .success(let model):
                self?.reference(model)
            case .failure(let error):
                self?.errorPosting = error
                self?.isLoading = false
            }
        }
    }
    
    private func reference(_ model: Postable) {
        if model is PostModel {
            let uploadPoint = UploadPostReferenceModel(id: model.id).uploadPoint
            apiService.multiLocationUpload(data: [uploadPoint]) { [weak self] result in
                switch result {
                case .success(()):
                    NotificationCenter.default.post(name: Notification.newPostFromCurrentUser, object: model)
                    self?.successfullyPosted = true
                    self?.isLoading = false
                case .failure(let error):
                    self?.errorPosting = error
                    self?.isLoading = false
                }
            }
        } else {
            self.successfullyPosted = true
            self.isLoading = false
        }
    }
}
 
