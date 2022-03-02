//
//  PublicTimelineViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class PublicTimelineViewController: UIViewController {
    
    // MARK: - Coordinator
    weak var coordinator: UserProfileCoordinator?

    // MARK: - Properties
    var display = PublicTimelineView()
    
    var viewModel = PublicTimelineViewModel()
    
    var dataSource: PostsDataSource!
    
    private var subscriptions = Set<AnyCancellable>()
    

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        display.tableview.backgroundColor = .darkColour
        display.configure(with: viewModel.user)
//        initUI()
        initDataSource()
        initViewModel()
        initTargets()
//        initRefreshControl()

//        self.topViewIndicator.hidesWhenStopped = true
        
//        selection.prepare()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .lightColour)
        navigationItem.title = viewModel.user.username
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        
        dataSource.userTapped
            .sink { [weak self] in self?.viewModel.getUser(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.workoutTapped
            .sink { [weak self] in self?.viewModel.getWorkout(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.likeButtonTapped
            .sink { [weak self] in self?.viewModel.likeCheck($0) }
            .store(in: &subscriptions)
        
        dataSource.postSelcted
            .sink { [weak self] in self?.showCommentSection($0) }
            .store(in: &subscriptions)
    }
    
//    func initUI(){
//        navigationItem.title = viewModel.user.username
//
//    }
    
    // MARK: - View Model
    func initViewModel(){
        
        viewModel.postPublisher
            .sink { [weak self] in self?.dataSource.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.followerCountPublisher
            .sink { [weak self] in self?.display.setFollowerCount(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.followingCountPublisher
            .sink { [weak self] in self?.display.setFollowingCount(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.isFollowingPublisher
            .sink { [weak self] in self?.display.setFollowing(to: $0) }
            .store(in: &subscriptions)
        
        viewModel.workoutSelected
            .sink { [weak self] in self?.coordinator?.showWorkout($0) }
            .store(in: &subscriptions)
        
        viewModel.savedWorkoutSelected
            .sink { [weak self] in self?.coordinator?.showSavedWorkout($0) }
            .store(in: &subscriptions)
        
        viewModel.userSelected
            .sink { [weak self] in self?.coordinator?.showUser(user: $0)}
            .store(in: &subscriptions)

        viewModel.reloadListener
            .sink { [weak self] in self?.dataSource.reloadPost($0)}
            .store(in: &subscriptions)
        
        viewModel.followSuccess
            .sink { [weak self] success in
                self?.display.setFollowing(to: success)
                if !success {
                    self?.displayTopMessage(with: "Error. Try again.")
                }
            }
            .store(in: &subscriptions)
        
        viewModel.fetchPosts()
        viewModel.getFollowerCount()
        viewModel.checkFollowing()
    }
    
//    func initRefreshControl(){
//        refreshControl = UIRefreshControl()
//        refreshControl.tintColor = .white
//        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
////        self.tableview.refreshControl = refreshControl
//    }
//    
//    @objc func handleRefresh(){
//        viewModel.followerCount()
//        viewModel.isFollowing()
//    }
    // MARK: - Targets
    func initTargets() {
        display.followButton.addTarget(self, action: #selector(follow(_:)), for: .touchUpInside)
        display.followerView.accountTypeButton.addTarget(self, action: #selector(showCreatedWorkouts(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    func showCommentSection(_ post: post) {
        coordinator?.showCommentSection(for: post, with: viewModel.reloadListener)
    }
    
    @IBAction func follow(_ sender: UIButton) {
        viewModel.follow()
    }
    
    @IBAction func showCreatedWorkouts(_ sender:UIButton){
        coordinator?.showCreatedWorkouts(for: viewModel.user)

    }

}

