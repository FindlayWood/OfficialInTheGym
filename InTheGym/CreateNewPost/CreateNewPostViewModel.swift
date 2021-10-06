//
//  CreateNewPostViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class CreateNewPostViewModel {
    
    var succesfullyPostedClosure:(()->())?
    var errorPostingClosure:(()->())?
    
    private var newPostModel = CreateNewPostModel()
    
    var postAttachedWorkout: attachedWorkout?
    var attachedPhoto: attachedPhoto?
    var attachedClip: attachedClip?
    
    var assignee: Assignable!
    
    var apiService: FirebaseManagerService!
    
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
    
    init(apiService: FirebaseManagerService = FirebaseManager.shared) {
        self.apiService = apiService
    }
    
    func postTapped() {
        configureUploadMethod()
//        //newPostModel.username = FirebaseAuthManager.currentlyLoggedInUser.username
//        //newPostModel.posterID = FirebaseAuthManager.currentlyLoggedInUser.uid
//        //newPostModel.time = Date().timeIntervalSince1970
//        PostEndpoints.postToGroup(groupID: assignee.uid, postModel: newPostModel).upload { [weak self] result in
//            guard let self = self else {return}
//            switch result {
//            case .success(_):
//                self.successfullyPosted = true
//            case .failure(let error):
//                print(error.localizedDescription)
//                self.errorPosting = error
//            }
//        }
    }
    
    func configureUploadMethod() {
        switch assignee {
        case is Users:
            let endpoint = PostEndpoints.post(postModel: newPostModel)
            post(to: endpoint)
        case is groupModel:
            let endpoint = PostEndpoints.postToGroup(groupID: assignee.uid, postModel: newPostModel)
            post(to: endpoint)
        default:
            break
        }
    }
    
    func post(to endpoint: PostEndpoints) {
        apiService.upload(from: endpoint) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(_):
                self.successfullyPosted = true
            case .failure(let error):
                self.errorPosting = error
            }
        }
    }
    
    
    func updateText(with newText: String) {
        newPostModel.text = newText
    }
    
    func updateAttachedWorkout(with workout: WorkoutDelegate) {
        removeAllAttachments()
        let newWorkout = attachedWorkout(title: workout.title,
                                         createdBy: workout.createdBy,
                                         exerciseCount: workout.exercises?.count ?? 0,
                                         storageID: workout.savedID,
                                         postedWorkoutType: .saved)
        newPostModel.attachedWorkout = newWorkout
    }
    
    func updateAttachedPhoto(with newPhoto: attachedPhoto) {
        removeAllAttachments()
        newPostModel.attachedPhoto = newPhoto
    }
    
    func removeAllAttachments() {
        newPostModel.attachedWorkout = nil
        newPostModel.attachedClip = nil
        newPostModel.attachedPhoto = nil
    }
}
