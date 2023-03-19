//
//  CommentTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CommentTableViewCell: UITableViewCell {
    
    // MARK: - Publishers
    var actionPublisher: PassthroughSubject<PostAction,Never> = PassthroughSubject<PostAction,Never>()
    
    // MARK: - Properties
    static let cellID: String = "CommentTableViewCellID"
    
    let selection = UISelectionFeedbackGenerator()
    
    var viewModel = CommentCellViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Subviews
    var profileImageButton: UIProfileImageButton = {
        let view = UIProfileImageButton()
        view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var usernameButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var messageTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 16, weight: .semibold)
        view.textColor = .darkGray
        view.sizeToFit()
        view.backgroundColor = .offWhiteColour
        view.layer.cornerRadius = 5
        view.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var workoutView: UIWorkoutView = {
        let view = UIWorkoutView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var interactionView: CommentInteractionView = {
        let view = CommentInteractionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [messageTextView, workoutView, interactionView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageButton.reset()
        actionPublisher = PassthroughSubject<PostAction,Never>()
    }
}
// MARK: - Configure
private extension CommentTableViewCell {
    func setupUI() {
        backgroundColor = .white
        selectionStyle = .none
        contentView.addSubview(profileImageButton)
        contentView.addSubview(usernameButton)
        contentView.addSubview(timeLabel)
        contentView.addSubview(stackView)
        configureUI()
        initTargets()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            profileImageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
            usernameButton.leadingAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: 8),
            usernameButton.topAnchor.constraint(equalTo: profileImageButton.topAnchor),
            usernameButton.heightAnchor.constraint(equalToConstant: 24),
            
            timeLabel.leadingAnchor.constraint(equalTo: usernameButton.trailingAnchor, constant: 4),
            timeLabel.centerYAnchor.constraint(equalTo: usernameButton.centerYAnchor),
            timeLabel.heightAnchor.constraint(equalToConstant: 12),
            
            stackView.leadingAnchor.constraint(equalTo: usernameButton.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: usernameButton.bottomAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            messageTextView.trailingAnchor.constraint(lessThanOrEqualTo: stackView.trailingAnchor),
            workoutView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
            

        ])
    }
    func initViewModel() {
        
        viewModel.$isLiked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.setLiked(to: $0) }
            .store(in: &subscriptions)
        
        viewModel.$userModel
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] in self?.setUserModel($0) }
            .store(in: &subscriptions)
        
        viewModel.checkLike()
        viewModel.loadUserModel()
    }
    // MARK: - Targets
    func initTargets() {
        profileImageButton.addTarget(self, action: #selector(userTapped(_:)), for: .touchUpInside)
        usernameButton.addTarget(self, action: #selector(userTapped(_:)), for: .touchUpInside)
        interactionView.likeButton.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        interactionView.taggedUserButton.addTarget(self, action: #selector(taggedUsersButtonTapped(_:)), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(workoutTapped(_:)))
        workoutView.addGestureRecognizer(tap)
    }
    @objc func userTapped(_ sender: UIButton) {
        actionPublisher.send(.userTapped)
    }
    @objc func workoutTapped(_ sender: UIView) {
        actionPublisher.send(.workoutTapped)
    }
    @objc func likeButtonTapped(_ sender: UIButton) {
        viewModel.like()
        selection.prepare()
        selection.selectionChanged()
        UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve) {
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            sender.tintColor = .redColour
        } completion: { _ in
            sender.isUserInteractionEnabled = false
        }
    }
    @objc func taggedUsersButtonTapped(_ sender: UIButton) {
        actionPublisher.send(.taggedUserTapped)
    }
}
private extension CommentTableViewCell {
    func setLiked(to liked: Bool) {
        if liked {
            interactionView.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            interactionView.likeButton.isUserInteractionEnabled = false
            interactionView.likeButton.tintColor = .redColour
        } else {
            interactionView.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            interactionView.likeButton.isUserInteractionEnabled = true
            interactionView.likeButton.tintColor = .darkColour
        }
    }
    func setUserModel(_ user: Users) {
        usernameButton.setTitle(user.username, for: .normal)
    }
}

// MARK: - Public Setup
extension CommentTableViewCell {
    public func setup(with comment: Comment) {
        viewModel.comment = comment
        initViewModel()
        profileImageButton.set(for: comment.posterID)
        usernameButton.setTitle(comment.username, for: .normal)
        timeLabel.text = (Date(timeIntervalSince1970: (comment.time))).timeAgo()
        messageTextView.text = comment.message
        if let workoutID = comment.attachedWorkoutSavedID {
            workoutView.configure(for: workoutID)
            workoutView.isHidden = false
        } else {
            workoutView.isHidden = true
        }
        if let _ = comment.taggedUsers {
            interactionView.taggedUserButton.isHidden = false
        } else {
            interactionView.taggedUserButton.isHidden = true
        }
    }
}

