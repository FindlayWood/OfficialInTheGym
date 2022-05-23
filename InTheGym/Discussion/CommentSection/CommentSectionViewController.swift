//
//  CommentSectionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CommentSectionViewController: UIViewController {
    
    weak var coordinator: CommentSectionCoordinator?
    
    var display = CommentSectionView()
    
    var viewModel = CommentSectionViewModel()
    
    var adapter = CommentSectionAdapter()
    
    var dataSource: CommentSectionDataSource!
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func loadView() {
        view = display
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        display.commentView.textViewDidChange(display.commentView.commentTextField)
        display.tableview.separatorStyle = .none
        initTableView()
//        initialTableSetUp()
        initDataSource()
        initViewModel()
        setupKeyBoardObservers()
        initTargets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "\(viewModel.mainPost.username)'s post"
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
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
        dataSource.initialSetup(with: viewModel.mainPost)
        
        dataSource.userTapped
            .sink { [weak self] in self?.viewModel.getUser(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.commentUserTapped
            .sink { [weak self] in self?.viewModel.getUser(from: $0)}
            .store(in: &subscriptions)
        
        dataSource.workoutTapped
            .sink { [weak self] in self?.viewModel.getWorkout(from: $0) }
            .store(in: &subscriptions)
        
        dataSource.likeButtonTapped
            .sink { [weak self] postModel in
                self?.viewModel.listener?.send(postModel)
                self?.viewModel.likedMainPost()
            }
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
            .sink { [weak self] in self?.coordinator?.showUser($0)}
            .store(in: &subscriptions)
        
        viewModel.uploadingNewComment
            .sink { [weak self] comment in
                guard let self = self else {return}
                self.dataSource.addComment(comment)
                self.display.resetView()
                self.viewModel.attachedWorkout = nil
                self.dataSource.reloadMain(with: self.viewModel.mainPost)
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
        
        
        viewModel.comments
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.dataSource.updateComments(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.isLoading
            .sink { [weak self] in self?.initLoadingNavBar($0)}
            .store(in: &subscriptions)
        
        viewModel.loadGeneric(for: viewModel.mainPostReplyModel)
    }
    
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
extension CommentSectionViewController {
    func userSelected(_ user: Users) {
        coordinator?.showUser(user)
    }
}

// MARK: - Display Button Actions
extension CommentSectionViewController {
    
    @objc func sendPressed(_ sender: UIButton) {
        viewModel.sendPressed()
    }
    
    @objc func attachedWorkoutPressed(_ sender: UIButton) {
        display.commentView.commentTextField.resignFirstResponder()
        coordinator?.attachWorkout()
    }
    
    @objc func removeAttachedWorkout(_ sender: UIButton) {
        display.removeAttachedWorkout()
        viewModel.attachedWorkout = nil
    }
}

