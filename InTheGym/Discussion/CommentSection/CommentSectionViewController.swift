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
    
    
//    var mainPost: post!
    
//    private lazy var postReplyModel = PostReplies(postID: mainPost.id)
    
//    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        display.commentView.textViewDidChange(display.commentView.commentTextField)
        view.addSubview(display)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initTableView()
//        initialTableSetUp()
        setupDataSource()
        setUpSubscribers()
        setupKeyBoardObservers()
        setupDisplayButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "\(viewModel.mainPost.username)'s post"
    }
    
    // MARK: - Data Source
    func setupDataSource() {
        dataSource = .init(tableView: display.tableview)
        dataSource.initialSetup(with: viewModel.mainPost)
    }
    
    func initTableView() {
//        display.tableview.dataSource = dataSource
        display.tableview.delegate = adapter
    }
    
    func setupDisplayButtons() {
        display.commentView.sendButton.addTarget(self, action: #selector(sendPressed(_:)), for: .touchUpInside)
        display.commentView.removeAttachmentButton.addTarget(self, action: #selector(removeAttachedWorkout(_:)), for: .touchUpInside)
        display.commentView.attachmentButton.addTarget(self, action: #selector(attachedWorkoutPressed(_:)), for: .touchUpInside)
    }
    
    // MARK: - Setup Subscribers
    func setUpSubscribers() {
        
        dataSource.userSelected
            .sink { [weak self] in self?.userSelected($0) }
            .store(in: &subscriptions)
        
        dataSource.workoutSelected
            .sink { [weak self] in self?.workoutSelected(at: $0) }
            .store(in: &subscriptions)
        
        dataSource.likeButtonTapped
            .sink { [weak self] in self?.likeButtonTapped(at: $0) }
            .store(in: &subscriptions)
        
        viewModel.uploadingNewComment
            .sink { [weak self] success in
                guard let self = self else {return}
                
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
        
        viewModel.loadGeneric(for: viewModel.mainPostReplyModel)
//        viewModel.load(for: mainPost)
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
    func workoutSelected(at indexPath: IndexPath) {
        print("workout selected...")
    }
    func likeButtonTapped(at indexPath: IndexPath) {
        viewModel.likeCheck(viewModel.mainPost)
        viewModel.mainPost.likeCount += 1
    }
}

// MARK: - Display Button Actions
extension CommentSectionViewController {
    
    @objc func sendPressed(_ sender: UIButton) {
        viewModel.sendPressed(viewModel.mainPost.id)
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
//
//// MARK: - Timeline Tap Protocol
//extension CommentSectionViewController: TimelineTapProtocol {
//    func likeButtonTapped(on cell: UITableViewCell, sender: UIButton, label: UILabel) {
//
//    }
//
//    func workoutTapped(on cell: UITableViewCell) {
//
//    }
//
//    func userTapped(on cell: UITableViewCell) {
//
//    }
//}
