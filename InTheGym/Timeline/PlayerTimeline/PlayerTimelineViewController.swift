//
//  PlayerTimelineViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
//import SCLAlertView
import Combine

class PlayerTimelineViewController: UIViewController, UITabBarControllerDelegate {
    
    // MARK: - Properties
    var coordinator: TimelineCoordinator?
    
    var display = PlayerTimelineView()
    
    var viewModel = PlayerTimelineViewModel()
    
    var dataSource: PostsDataSource!
    
    var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showFirstMessage()
        view.backgroundColor = .systemBackground
        
        display.tableview.backgroundColor = .darkColour
        
        self.tabBarController?.delegate = self
        
        initDataSource()
        initViewModel()
        initTargets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Display Targets
    func initTargets() {
        display.postButton.addTarget(self, action: #selector(makePostPressed(_:)), for: .touchUpInside)
        display.refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        display.tableview.refreshControl = display.refreshControl
        display.performanceButton.addTarget(self, action: #selector(performancePressed(_:)), for: .touchUpInside)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        
        dataSource.userTapped
            .sink { [weak self]in self?.viewModel.getUser(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.workoutTapped
            .sink { [weak self] in self?.viewModel.getWorkout(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.likeButtonTapped
            .sink { [weak self] in self?.viewModel.likeCheck($0) }
            .store(in: &subscriptions)
        
//        dataSource.scrollPublisher
//            .debounce(for: 0.1, scheduler: RunLoop.main)
//            .sink { [weak self] show in
//                guard let self = self else {return}
//                if show {
//                    self.display.showTopView()
//                } else {
//                    self.display.hideTopView()
//                }
//            }
//            .store(in: &subscriptions)
        
        dataSource.postSelcted
            .sink { [weak self] (postModel, indexPath) in
                self?.showCommentSection(for: postModel)
                self?.viewModel.selectedCellIndex = indexPath
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - View Model
    func initViewModel(){
        
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading($0)}
            .store(in: &subscriptions)
        
        viewModel.postPublisher
            .dropFirst()
            .sink { [weak self] in self?.dataSource.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.thinkingTimeActivePublisher
            .sink { [weak self] active in
                guard let self = self else {return}
                if active {
                    let vc = ThinkingTimeViewController()
                    vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .coverVertical
                    self.navigationController?.present(vc, animated: true)
                }
            }
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
        
        
        viewModel.checkForThinkingTime()
        viewModel.fetchPosts()
        
    }
    
    // MARK: - Actions
    func showCommentSection(for post: PostModel) {
        coordinator?.showCommentSection(for: post, with: viewModel.reloadListener)
    }
    
    @objc func handleRefresh(_ sender: AnyObject){
        viewModel.fetchPosts()
    }
    
    
    @objc func makePostPressed(_ sender: UIButton) {
        coordinator?.makePost(postable: PostModel())
    }
    
    @objc func performancePressed(_ sender: UIButton) {
        coordinator?.showPerformance()
    }
    
    // tap tab bar to scroll to top
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedViewController === viewController {
            self.display.tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        return true
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
extension PlayerTimelineViewController {
    func showFirstMessage() {
        if UIApplication.isFirstLaunch() {
//            var message : String!
//            if ViewController.admin{
//                message = FirstTimeMessages.firstPageCoachMessage
//            } else {
//                message = FirstTimeMessages.firstPagePlayerMessage
//            }
//            let screenSize: CGRect = UIScreen.main.bounds
//            let screenWidth = screenSize.width
//            
//            let appearance = SCLAlertView.SCLAppearance(
//                kWindowWidth: screenWidth - 40 )
//
//            let alert = SCLAlertView(appearance: appearance)
//            alert.showInfo("Welcome!", subTitle: message, closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }
}
