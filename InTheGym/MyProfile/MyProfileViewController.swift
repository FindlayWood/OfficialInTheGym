//
//  MyProfileViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
//import SCLAlertView
import Combine

class MyProfileViewController: UIViewController, CustomAnimatingClipFromVC {
    
    var coordinator: MyProfileCoordinator?
    
    // MARK: - Properties
    var display = MyProfileView()

    var viewModel = MyProfileViewModel()
    
    var dataSource: ProfileTableViewDataSource!
    
    var subscriptions = Set<AnyCancellable>()
    
    var selectedCell: ClipCollectionCell?
    var selectedCellImageViewSnapshot: UIView?

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        showFirstMessage()
        initDataSource()
        initViewModel()
        initDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // MARK: - Display
    func initDisplay(){
        display.moreButton.addTarget(self, action: #selector(showMore(_:)), for: .touchUpInside)
        display.notificationsButton.addTarget(self, action: #selector(showNotifications(_:)), for: .touchUpInside)
        display.groupsButton.addTarget(self, action: #selector(showGroups(_:)), for: .touchUpInside)
        display.refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        display.tableview.refreshControl = display.refreshControl
    }

    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        dataSource.updateUserInfo(with: UserDefaults.currentUser)
        
        dataSource.postSelected
            .sink { [weak self] (postModel, indexPath) in
                self?.showCommentSection(for: postModel)
                self?.viewModel.selectedCellIndex = indexPath
            }
            .store(in: &subscriptions)
        
        dataSource.profileInfoAction
            .sink { [weak self] in self?.profileInfoAction($0)}
            .store(in: &subscriptions)

        dataSource.userTapped
            .sink { [weak self]in self?.viewModel.getUser(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.workoutTapped
            .sink { [weak self] in self?.viewModel.getWorkout(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.taggedUsersTapped
            .sink { [weak self] in self?.showTaggedUsers(for: $0) }
            .store(in: &subscriptions)
        
        dataSource.deletePost
            .sink { [weak self] postModel in
                self?.viewModel.deletePost(postModel)
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - View Model
    func initViewModel(){
        
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading($0)}
            .store(in: &subscriptions)
        
        viewModel.postPublisher
            .sink { [weak self] in self?.dataSource.updatePosts(with: $0) }
            .store(in: &subscriptions)
        viewModel.workoutSelected
            .sink { [weak self] in self?.coordinator?.showWorkout($0) }
            .store(in: &subscriptions)
        viewModel.savedWorkoutSelected
            .sink { [weak self] in self?.coordinator?.showSavedWorkout($0) }
            .store(in: &subscriptions)
        
        viewModel.userSelected
            .sink { [weak self] in self?.coordinator?.showUser(user: $0) }
            .store(in: &subscriptions)
        viewModel.reloadListener
            .sink { [weak self] newPost in
                guard let self = self else {return}
                guard let selectedCellIndex = self.viewModel.selectedCellIndex else {return}
                self.dataSource.reloadPost(with: newPost, at: selectedCellIndex)
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: Notification.newPostFromCurrentUser)
            .compactMap { $0.object as? PostModel }
            .sink { [weak self] in self?.dataSource.addNewPost($0) }
            .store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: Notification.deletedPost)
            .compactMap { $0.object as? PostModel }
            .sink { [weak self] in self?.dataSource.deletePost($0) }
            .store(in: &subscriptions)
        
        viewModel.fetchPostRefs()
    }
    
    
    // MARK: - Actions
    func profileInfoAction(_ action: ProfileInfoActions) {
        switch action {
        case .followers:
            coordinator?.showMyFollowers()
        case .following:
            coordinator?.showMyFollowers()
        case .clips:
            coordinator?.showMyClips()
        case .savedWorkouts:
            coordinator?.showMyWorkouts()
        case .stamps:
            coordinator?.showStampsPreview()
        }
    }
    
    func showTaggedUsers(for post: PostModel) {
        guard let tagged = post.taggedUsers else { return }
        coordinator?.showTaggedUsers(tagged)
    }
    
    func showCommentSection(for post: PostModel) {
        coordinator?.showCommentSection(post: post, with: viewModel.reloadListener)
    }
    
    @objc func showMore(_ sender: UIButton) {
        coordinator?.showMoreInfo()
    }
    @objc func showNotifications(_ sender: UIButton) {
        coordinator?.showNotifications()
    }
    @objc func showGroups(_ sender: UIButton) {
        coordinator?.showGroups()
    }
    @objc func handleRefresh(_ sender: AnyObject) {
        viewModel.fetchPostRefs()
        dataSource.reloadSection()
    }
    func setLoading(_ loading: Bool) {
        if !loading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.display.refreshControl.endRefreshing()
            }
        }
    }
}

// extension for first time message
extension MyProfileViewController {
    func showFirstMessage() {
        if UIApplication.isFirstProfileLaunch() {

//            let screenSize: CGRect = UIScreen.main.bounds
//            let screenWidth = screenSize.width
//            
//            let appearance = SCLAlertView.SCLAppearance(
//                kWindowWidth: screenWidth - 40 )
//
//            let alert = SCLAlertView(appearance: appearance)
//            alert.showInfo("MY PROFILE!", subTitle: FirstTimeMessages.myPRofileMessage, closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }
}

extension MyProfileViewController {
    
    @objc func removeIcon(){
        self.tabBarController?.tabBar.items?[3].badgeValue = nil
    }
}


