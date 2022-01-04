//
//  CommentSectionViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class CommentSectionViewModel {
    
    var apiService: FirebaseDatabaseManagerService
    
    var comments = CurrentValueSubject<[Comment],Never>([])
    var errorFetchingComments = PassthroughSubject<Error,Never>()
    
    var uploadingNewComment = PassthroughSubject<Bool,Never>()
    
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    func loadGeneric<T: FirebaseInstance>(for postGeneric: T) {
        apiService.fetchInstance(of: postGeneric, returning: Comment.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let comments):
                self.comments.send(comments)
            case .failure(let error):
                self.errorFetchingComments.send(error)
            }
        }
    }
    
    func upload<T: FirebaseInstance>(_ object: T, autoID: Bool) {
        apiService.upload(data: object, autoID: autoID) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                self.uploadingNewComment.send(true)
            case .failure(_):
                self.uploadingNewComment.send(false)
            }
        }
    }
    
//    func load(for post: post) {
//        apiService.fetchInstance(of: post, to: Comment.self) { [weak self] result in
//            guard let self = self else {return}
//            switch result {
//            case .success(let comments):
//                self.comments.send(comments)
//            case .failure(let error):
//                self.errorFetchingComments.send(error)
//            }
//        }
//    }
}
