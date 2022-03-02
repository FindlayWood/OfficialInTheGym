//
//  PlayerTimelineViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView
import Combine

class PlayerTimelineViewController: UIViewController, UITabBarControllerDelegate, Storyboarded {
    
    // MARK: - Properties
    var coordinator: NewsFeedFlow?
    
    var display = PlayerTimelineView()
    
//    var refreshControl: UIRefreshControl!
    
    var viewModel = PlayerTimelineViewModel()
    
    var dataSource: PostsDataSource!
    
    var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showFirstMessage()
        view.backgroundColor = .white
        
        display.tableview.backgroundColor = .darkColour
        
        self.tabBarController?.delegate = self
        
        initDataSource()
        initViewModel()
//        initRefreshControl()
        
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
        
        dataSource.scrollPublisher
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink { [weak self] show in
                guard let self = self else {return}
                if show {
                    self.display.showTopView()
                } else {
                    self.display.hideTopView()
                }
            }
            .store(in: &subscriptions)
        
        dataSource.postSelcted
            .sink { [weak self] in self?.showCommentSection(for: $0) }
            .store(in: &subscriptions)
    }
    
    // MARK: - View Model
    func initViewModel(){
        
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
            .sink { [weak self] in self?.dataSource.reloadPost($0)}
            .store(in: &subscriptions)
        
        viewModel.checkForThinkingTime()
        viewModel.fetchPosts()
        
    }
    
    // MARK: - Actions
    func showCommentSection(for post: post) {
        coordinator?.showCommentSection(for: post, with: viewModel.reloadListener)
    }
    
    
//    func initRefreshControl(){
//        refreshControl = UIRefreshControl()
//        refreshControl.tintColor = .white
//        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
//        self.display.tableview.refreshControl = refreshControl
//    }
//
//    @objc func handleRefresh(){
//        // go to viewmodel to refresh
//        //viewModel.fetchData()
//    }
    
    
    @objc func makePostPressed(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let postVC = storyboard.instantiateViewController(withIdentifier: "MakePostViewController") as! MakePostViewController
//        coordinator?.makePost(groupPost: false, delegate: self)
//        postVC.groupBool = false
//        postVC.timelineDelegate = self
//        postVC.modalTransitionStyle = .coverVertical
//        postVC.modalPresentationStyle = .fullScreen
//        self.navigationController?.present(postVC, animated: true, completion: nil)
        
    }
    
    // tap tab bar to scroll to top
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedViewController === viewController {
            self.display.tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        return true
    }
    

}


// extension for first time message
extension PlayerTimelineViewController {
    func showFirstMessage() {
        if UIApplication.isFirstLaunch() {
            var message : String!
            if ViewController.admin{
                message = FirstTimeMessages.firstPageCoachMessage
            } else {
                message = FirstTimeMessages.firstPagePlayerMessage
            }
            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("Welcome!", subTitle: message, closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }
}
