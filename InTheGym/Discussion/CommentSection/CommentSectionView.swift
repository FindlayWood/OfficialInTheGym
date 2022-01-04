//
//  CommentSectionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CommentSectionView: UIView {
    // MARK: - Properties
    
    var bottomViewAnchor: NSLayoutConstraint!
    var commentFieldHeightAnchor: NSLayoutConstraint!
    private let placeholder = "add a reply..."
    private let placeholderColour: UIColor = Constants.darkColour
    private let stackViewSpacing: CGFloat = 10, constraintSpaicng: CGFloat = 10
    
    // MARK: - Subviews
    
    var tableview: UITableView = {
        let view = UITableView()
        view.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.cellID)
        view.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.cellID)
        if #available(iOS 15.0, *) {
            view.sectionHeaderTopPadding = 0
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var commentView: CommentView = {
        let view = CommentView()
        view.removeAttachedWorkout()
        view.textViewDidChange(view.commentTextField)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
}
// MARK: - Configure
private extension CommentSectionView {
    func setupUI() {
        backgroundColor = .white
        addSubview(tableview)
        addSubview(commentView)
        configureUI()
    }
    
    func configureUI() {
        bottomViewAnchor = commentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([
            commentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            commentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            commentView.heightAnchor.constraint(equalToConstant: 60),
            bottomViewAnchor,
            
            tableview.topAnchor.constraint(equalTo: topAnchor),
            tableview.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableview.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableview.bottomAnchor.constraint(equalTo: commentView.topAnchor)
        ])
    }
}

// MARK: - Public Functions
extension CommentSectionView {
    public func removeAttachedWorkout() {
        commentView.removeAttachedWorkout()
    }
}
    

