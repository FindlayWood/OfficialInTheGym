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
    
    var display = CommentSectionView()
    
    var viewModel = CommentSectionViewModel()
    
    var adapter = CommentSectionAdapter()
    
    var mainPost: GroupPost!
    
    private lazy var postReplyModel = PostReplies(postID: mainPost.id)
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View Setup
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
        initialTableSetUp()
        setupDisplayButtons()
        setUpSubscribers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "Group Post"
    }
    
    // MARK: - Display Setup
    func initTableView() {
        display.tableview.dataSource = dataSource
        display.tableview.delegate = adapter
    }
    
    func setupDisplayButtons() {
        display.commentView.sendButton.addTarget(self, action: #selector(sendPressed(_:)), for: .touchUpInside)
        display.commentView.removeAttachmentButton.addTarget(self, action: #selector(removeAttachedWorkout(_:)), for: .touchUpInside)
        display.commentView.attachmentButton.addTarget(self, action: #selector(attachedWorkoutPressed(_:)), for: .touchUpInside)
    }
    
    // MARK: - Combine Subscribers
    func setUpSubscribers() {
        
        viewModel.comments
            .receive(on: RunLoop.main)
            .sink { [weak self] comments in
                guard let self = self else {return}
                self.updateComments(with: comments)
            }
            .store(in: &subscriptions)
        
        viewModel.uploadingNewComment
            .sink { [weak self] success in
                guard let self = self else {return}
                
            }
            .store(in: &subscriptions)
        
        viewModel.loadGeneric(for: postReplyModel)
    }

}

// MARK: - Tableview Datasource
extension GroupCommentSectionViewController {
    
    func makeDataSource() -> UITableViewDiffableDataSource<CommentSectionSections,GroupCommentItems> {
        return UITableViewDiffableDataSource(tableView: display.tableview) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .mainPost(let post):
                let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.cellID, for: indexPath) as! PostTableViewCell
                cell.configure(with: post)
                cell.delegate = self
                return cell
            case .comment(let comment):
                let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.cellID, for: indexPath) as! CommentTableViewCell
                cell.setup(with: comment)
                return cell
            }
        }
    }
    
    func initialTableSetUp() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([.Post, .comments])
        currentSnapshot.appendItems([.mainPost(mainPost)], toSection: .Post)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    func updateComments(with comments: [Comment]) {
        var currentSnapshot = dataSource.snapshot()
        for comment in comments {
            currentSnapshot.appendItems([.comment(comment)], toSection: .comments)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}

// MARK: - Display Button Actions
extension GroupCommentSectionViewController {
    
    @objc func sendPressed(_ sender: UIButton) {
        let newID = UUID().uuidString
        let newComment = Comment(id: newID,
                                 username: FirebaseAuthManager.currentlyLoggedInUser.username,
                                 time: Date().timeIntervalSince1970,
                                 message: display.commentView.commentTextField.text.trimTrailingWhiteSpaces(),
                                 posterID: FirebaseAuthManager.currentlyLoggedInUser.id,
                                 postID: newID)
        print(newComment)
//        viewModel.upload(newComment, autoID: false)
    }
    
    @objc func attachedWorkoutPressed(_ sender: UIButton) {
        display.commentView.commentTextField.resignFirstResponder()
        print("show saved workouts...")
    }
    
    @objc func removeAttachedWorkout(_ sender: UIButton) {
        display.removeAttachedWorkout()
    }
}

// MARK: - Timeline Tap Protocol
extension GroupCommentSectionViewController: TimelineTapProtocol {
    func likeButtonTapped(on cell: UITableViewCell, sender: UIButton, label: UILabel) {
        
    }
    
    func workoutTapped(on cell: UITableViewCell) {
        
    }
    
    func userTapped(on cell: UITableViewCell) {
        
    }
}
