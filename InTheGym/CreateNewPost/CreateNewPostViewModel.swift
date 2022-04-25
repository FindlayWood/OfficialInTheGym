//
//  CreateNewPostViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class CreateNewPostViewModel {
    
    // MARK: - Publishers
    @Published var postText: String = ""
    @Published var canPost: Bool = false
    @Published var isPrivate: Bool = false
    @Published var isLoading: Bool = false
    
    var succesfullyPostedClosure:(()->())?
    var errorPostingClosure:(()->())?
    
    // MARK: - Properties
    private var newPostModel = CreateNewPostModel()
    
    var postable: Postable!
    
    weak var listener: NewPostListener?
    
    var postAttachedWorkout: attachedWorkout?
    var attachedPhoto: attachedPhoto?
    var attachedClip: attachedClip?
    
    var assignee: Assignable!
    
    var apiService: FirebaseDatabaseManagerService
    
    var successfullyPosted: Bool = false {
        didSet {
            succesfullyPostedClosure?()
            updateText(with: "")
            removeAllAttachments()
        }
    }
    var errorPosting: Error? {
        didSet {
            errorPostingClosure?()
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
        initSubscriptions()
    }
    
    func initSubscriptions() {
        
        $postText
            .dropFirst()
            .sink { [unowned self] in self.postable.text = $0 }.store(in: &subscriptions)
        
        $postText
            .map { return $0.count > 0 }
            .sink { [unowned self] in self.canPost = $0 }
            .store(in: &subscriptions)
        
        $isPrivate
            .dropFirst()
            .sink { [unowned self] in self.postable.isPrivate = $0 }
            .store(in: &subscriptions)
        
    }
    
    func postTapped() {
        isLoading = true
        postable.time = Date().timeIntervalSince1970
        if let postModel = postable as? post {
            post(postModel)
        } else if let groupPost = postable as? GroupPost {
            post(groupPost)
        }
    }
    
    func post<Model>(_ model: Model) where Model: Postable {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.isLoading = false
//            self.listener?.send(model)
////            self.updateText(with: "")
////            self.removeAllAttachments()
//            self.succesfullyPostedClosure?()
//        }
        apiService.uploadTimeOrderedModel(model: model) { [weak self] result in
            switch result {
            case .success(let model):
                self?.successfullyPosted = true
                self?.listener?.send(model)
                self?.isLoading = false
            case .failure(let error):
                self?.errorPosting = error
                self?.isLoading = false
            }
        }
    }
    
    // MARK: - Actions
    func updateText(with newText: String) {
        postText = newText
    }
    
    func updateAttachedWorkout(with model: SavedWorkoutModel) {
        removeAllAttachments()
        postable.savedWorkoutID = model.id
    }
    
    func updateAttachedPhoto(with newPhoto: attachedPhoto) {
        removeAllAttachments()
        newPostModel.attachedPhoto = newPhoto
    }
    
    func removeAllAttachments() {
        postable.savedWorkoutID = nil
    }
}
