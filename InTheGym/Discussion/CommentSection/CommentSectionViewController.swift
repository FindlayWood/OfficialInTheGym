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
    
    var mainPost: post!
    
    private lazy var postReplyModel = PostReplies(postID: mainPost.id)
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = Set<AnyCancellable>()

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
        setUpSubscribers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "\(mainPost.username)'s post"
    }
    
    func initTableView() {
        display.tableview.dataSource = dataSource
        display.tableview.delegate = adapter
    }
    
    func setUpSubscribers() {
        
        viewModel.comments
            .receive(on: RunLoop.main)
            .sink { [weak self] comments in
                guard let self = self else {return}
                self.updateComments(with: comments)
            }
            .store(in: &subscriptions)
        
        viewModel.loadGeneric(for: postReplyModel)
//        viewModel.load(for: mainPost)
    }
}

extension CommentSectionViewController {
    
    func makeDataSource() -> UITableViewDiffableDataSource<CommentSectionSections,CommentItems> {
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
extension CommentSectionViewController {
    
    @objc func sendPressed(_ sender: UIButton) {

    }
}

// MARK: - Timeline Tap Protocol
extension CommentSectionViewController: TimelineTapProtocol {
    func likeButtonTapped(on cell: UITableViewCell, sender: UIButton, label: UILabel) {
        
    }
    
    func workoutTapped(on cell: UITableViewCell) {
        
    }
    
    func userTapped(on cell: UITableViewCell) {
        
    }  
}
