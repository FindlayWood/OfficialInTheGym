//
//  PostCellViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

// PostCellViewModel
// This class is the viewModel for any post cell
// It handles likes
class PostCellViewModel {
    
    // MARK: - Publishers
    var errorLikingPost = PassthroughSubject<Error,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    var post: DisplayablePost! // The post that this view model is responsible for
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func likedPost() {
        switch post {
        case is post:
            like(post as! post)
        case is GroupPost:
            groupLike(post as! GroupPost)
        default:
            break
        }
    }
    
    func like(_ post: post) {
        let likeModels = LikeTransportLayer(postID: post.id).postLike(post: post)
        apiService.multiLocationUpload(data: likeModels) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                LikesAPIService.shared.LikedPostsCache[self.post.id] = true
            case .failure(let error):
                self.errorLikingPost.send(error)
            }
        }
    }
    func groupLike(_ groupPost: GroupPost) {
        let likeModels = LikeTransportLayer(postID: groupPost.id).groupPostLike(post: groupPost)
        apiService.multiLocationUpload(data: likeModels) { [weak self] result in
            switch result {
            case .success(()):
                LikesAPIService.shared.LikedPostsCache[groupPost.id] = true
//                self?.groupListener?.send(post)
            case .failure(let error):
                self?.errorLikingPost.send(error)
            }
        }
    }

    
    // MARK: - Functions
}
