//
//  GroupHomePageViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class GroupHomePageViewModel {
    
    // MARK: - Callbacks
    var reloadPostsTableViewClosure: (() -> ())?
    var reloadMembersTableViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    var reloadHeaderImageClosure: (() -> ())?
    var updateNavigationTitleImage: (() -> ())?
    var groupLeaderLoadedClosure: (() -> ())?
    
    // MARK: - Properties
    var apiService: FirebaseAPIGroupService
    
    var posts: [PostProtocol] = [] {
        didSet {
            reloadPostsTableViewClosure?()
        }
    }
    
    var numberOfPosts: Int {
        return posts.count
    }
    
    var members: [Users] = [] {
        didSet {
            reloadMembersTableViewClosure?()
        }
    }
    var numberOfMembers: Int = 0 {
        didSet {
            reloadMembersTableViewClosure?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            updateLoadingStatusClosure?()
        }
    }
    
    var headerImage: UIImage? {
        didSet {
            reloadHeaderImageClosure?()
        }
    }
    
    var headerImageInView: Bool = true {
        didSet {
            if headerImageInView != oldValue {
                updateNavigationTitleImage?()
            }
        }
    }
    var groupLeader: Users! {
        didSet {
            groupLeaderLoadedClosure?()
        }
    }
    
    var postsLoadedSuccessfully: Bool = false
    var membersLoadedSuccessfully: Bool = false
    var groupLeaderLoadedSuccessfully: Bool = false
    
    
    // MARK: - Initializer
    init(apiService: FirebaseAPIGroupService) {
        self.apiService = apiService
    }
    
    // MARK: - Fetching Functions
    func loadPosts(from groupID: String) {
        apiService.loadPosts(from: groupID) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let returnedPosts):
                self.postsLoadedSuccessfully = true
                self.posts = returnedPosts
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    func loadMembers(from groupID: String) {
        apiService.loadGroupMemberCount(from: groupID) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let returnedMemberCount):
                self.numberOfMembers = returnedMemberCount
                self.membersLoadedSuccessfully = true
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func loadHeaderImage(from groupID: String) {
        ImageAPIService.shared.getProfileImage(for: groupID) { [weak self] image in
            guard let self = self else {return}
            if let headerImage = image {
                self.headerImage = headerImage
            }
        }
    }
    
    func loadGroupLeader(from userID: String) {
        UserIDToUser.transform(userID: userID) { [weak self] leader in
            guard let self = self else {return}
            self.groupLeader = leader
            self.groupLeaderLoadedSuccessfully = true
        }
    }
    
    func getPostData(at indexPath: IndexPath) -> PostProtocol {
        return posts[indexPath.row]
    }
    func getGroupImage(with groupID: String) -> UIImage? {
        return nil
    }
    func getBarImage() -> UIImage {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "ellipsis")!
        } else {
            return UIImage(named: "more_icon")!
        }
    }
    
    // MARK: - Actions
    func likePost(from groupID: String, on post:PostProtocol) {
        guard let postID = post.postID else {return}
        
        apiService.isLiked(from: groupID, postID: postID) { [weak self] liked in
            guard let self = self else {return}
            if !liked {
                self.apiService.likeGroupPost(from: groupID, post: post) { _ in
                        
                }
            }
        }

    }
}
