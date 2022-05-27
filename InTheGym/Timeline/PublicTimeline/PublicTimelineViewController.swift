//
//  PublicTimelineViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class PublicTimelineViewController: UIViewController, CustomAnimatingClipFromVC {
    
    // MARK: - Coordinator
    weak var coordinator: UserProfileCoordinator?

    // MARK: - Properties
    var display = PublicTimelineView()
    
    var viewModel = PublicTimelineViewModel()
    
    //    var dataSource: ProfileDataSource!
    var dataSource: ProfileTableViewDataSource!
    
    private var subscriptions = Set<AnyCancellable>()
    
    var selectedCell: ClipCollectionCell?
    var selectedCellImageViewSnapshot: UIView?
    

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initDataSource()
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .lightColour)
        navigationItem.title = viewModel.user.username
    }
    // MARK: - Display
    func initDisplay(){
        display.refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        display.tableview.refreshControl = display.refreshControl
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        dataSource.updatePublicUserInfo(with: viewModel.user)
        
        dataSource.profileInfoAction
            .sink { [weak self] in self?.profileInfoAction($0)}
            .store(in: &subscriptions)
        
        dataSource.postSelected
            .sink { [weak self] (postModel, indexPath) in
                self?.showCommentSection(for: postModel)
                self?.viewModel.selectedCellIndex = indexPath
            }
            .store(in: &subscriptions)
        
        dataSource.userTapped
            .sink { [weak self]in self?.viewModel.getUser(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.workoutTapped
            .sink { [weak self] in self?.viewModel.getWorkout(from: $0) }
            .store(in: &subscriptions)
    }
    

    
    // MARK: - View Model
    func initViewModel(){
        
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
        
        viewModel.fetchPosts()
    }

    
//    // MARK: - Actions
    func profileInfoAction(_ action: ProfileInfoActions) {
        switch action {
        case .followers:
            coordinator?.showUserFollowers(user: viewModel.user)
        case .following:
            coordinator?.showUserFollowers(user: viewModel.user)
        case .clips:
            coordinator?.showUserClips(user: viewModel.user)
        case .savedWorkouts:
            coordinator?.showUserWorkouts(user: viewModel.user)
        }
    }
    func showCommentSection(for post: PostModel) {
        coordinator?.showCommentSection(for: post, with: viewModel.reloadListener)
    }

    @IBAction func showCreatedWorkouts(_ sender:UIButton){
        coordinator?.showCreatedWorkouts(for: viewModel.user)

    }
    @objc func handleRefresh(_ sender: AnyObject) {
        viewModel.fetchPosts()
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
