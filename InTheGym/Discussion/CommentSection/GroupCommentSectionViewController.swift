//
//  GroupCommentSectionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class GroupCommentSectionViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: GroupCommentSectionCoordinator?
    
    var display = CommentSectionView()
    
    var viewModel = CommentSectionViewModel()
    
    var adapter = CommentSectionAdapter()
    
    private var subscriptions = Set<AnyCancellable>()

    private var dataSource: CommentSectionDataSource!
    
    // MARK: - View Setup
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        display.commentView.textViewDidChange(display.commentView.commentTextField)
        display.tableview.separatorStyle = .none
        view.addSubview(display)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initTableView()
//        initialTableSetUp()
        initDataSource()
        initViewModel()
        initTargets()
        setupKeyBoardObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "Group Post"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Loading Nav Bar
    func initLoadingNavBar(_ show: Bool) {
        display.setInteraction(to: !show)
        if show {
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            activityIndicator.startAnimating()
            let barButton = UIBarButtonItem(customView: activityIndicator)
            navigationItem.rightBarButtonItem = barButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: - Setup Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        dataSource.initialGroupSetup(with: viewModel.mainGroupPost)
        
        dataSource.groupUserButtonTapped
            .sink { [weak self] in self?.viewModel.getUser(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.groupPostWorkoutButtonTapped
            .sink { [weak self] in self?.viewModel.getWorkout(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.groupPostLikeButtonTapped
            .sink { [weak self] in self?.viewModel.groupLikeCheck($0) }
            .store(in: &subscriptions)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.workoutSelected
            .sink { [weak self] in self?.coordinator?.showWorkout($0) }
            .store(in: &subscriptions)
        
        viewModel.savedWorkoutSelected
            .sink { [weak self] in self?.coordinator?.showSavedWorkout($0) }
            .store(in: &subscriptions)
        
        viewModel.userSelected
            .sink { [weak self] in self?.coordinator?.showUser($0) }
            .store(in: &subscriptions)
        
        viewModel.comments
            .receive(on: RunLoop.main)
            .sink { [weak self] comments in
                guard let self = self else {return}
                self.dataSource.updateComments(with: comments)
            }
            .store(in: &subscriptions)
        
        viewModel.uploadingNewComment
            .sink { [weak self] comment in
                guard let self = self else {return}
                self.dataSource.addComment(comment)
                self.display.resetView()
                self.viewModel.attachedWorkout = nil
                self.dataSource.reloadMain()
            }
            .store(in: &subscriptions)
        
        display.commentView.$commentText
            .sink { [weak self] in self?.viewModel.updateCommentText(with: $0) }
            .store(in: &subscriptions)
        
        coordinator?.savedWorkoutSelected
            .sink { [weak self] in
                self?.viewModel.attachedWorkout = $0
                self?.display.commentView.attachWorkout($0)
            }
            .store(in: &subscriptions)
        
        viewModel.isLoading
            .sink { [weak self] in self?.initLoadingNavBar($0)}
            .store(in: &subscriptions)
        
        viewModel.loadGeneric(for: viewModel.groupPostReplyModel)
    }
    
    // MARK: - Display Setup
    func initTableView() {
//        display.tableview.dataSource = dataSource
//        display.tableview.delegate = adapter
        
    }
    
    // MARK: - Targets
    func initTargets() {
        display.commentView.sendButton.addTarget(self, action: #selector(sendPressed(_:)), for: .touchUpInside)
        display.commentView.removeAttachmentButton.addTarget(self, action: #selector(removeAttachedWorkout(_:)), for: .touchUpInside)
        display.commentView.attachmentButton.addTarget(self, action: #selector(attachedWorkoutPressed(_:)), for: .touchUpInside)
    }
    
    
    // MARK: - Keyboard Observers
    func setupKeyBoardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardObervers(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardObervers(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func handleKeyboardObervers(notification: Notification) {

        if let userInfo = notification.userInfo {

            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            let isTabBarHidden = tabBarController?.tabBar.isHidden ?? true
            
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            let tabBarHeight = isTabBarHidden ? view.safeAreaInsets.bottom : self.tabBarController?.tabBar.frame.height
            
            display.bottomViewAnchor.constant = isKeyboardShowing ? -keyboardFrame!.height + tabBarHeight! : 0
            if isKeyboardShowing {
//                if savedWorkoutView.flashView != nil {
//                    savedWorkoutView.remove()
//                }
            }
            
            UIView.animate(withDuration: 0) {
                self.display.layoutIfNeeded()
            }
        }
    }

}
// MARK: - Cell Tap Actions
extension GroupCommentSectionViewController {
    func userSelected(_ user: Users) {
        coordinator?.showUser(user)
    }
    func workoutSelected(at indexPath: IndexPath) {
        print("workout selected...")
    }
    func likeButtonTapped(at indexPath: IndexPath) {
        viewModel.groupLikeCheck(viewModel.mainGroupPost)
        viewModel.mainGroupPost.likeCount += 1
    }
}


// MARK: - Display Button Actions
extension GroupCommentSectionViewController {
    
    @objc func sendPressed(_ sender: UIButton) {
        viewModel.groupSendPressed()
    }
    
    @objc func attachedWorkoutPressed(_ sender: UIButton) {
        display.commentView.commentTextField.resignFirstResponder()
        print("show saved workouts...")
        coordinator?.attachWorkout()
    }
    
    @objc func removeAttachedWorkout(_ sender: UIButton) {
        display.removeAttachedWorkout()
        viewModel.attachedWorkout = nil
    }
}
