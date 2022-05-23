//
//  PostTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class PostTableViewCell: UITableViewCell {
    
    // MARK: - Publishers
    var actionPublisher: PassthroughSubject<PostAction,Never> = PassthroughSubject<PostAction,Never>()
    
    // MARK: - Properties
    static let cellID = "postCellID"
    
    let selection = UISelectionFeedbackGenerator()

    var posterID: String!
    
    var viewModel = PostCellViewModel()
    
    var longDateFormat: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Subviews
    
    // MARK: - Stack Subviews

    var postUserView: PostUserSubview = {
        let view = PostUserSubview()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var photoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var clipImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var spacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var postTextView: PostTextSubview = {
        let view = PostTextSubview()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var postWorkoutView: PostWorkoutSubview = {
        let view = PostWorkoutSubview()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var postInteractionsView: PostInteractionsSubview = {
        let view = PostInteractionsSubview()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var fullPostStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [postUserView, spacerView, postTextView, postWorkoutView, postInteractionsView])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalSpacing
        stack.spacing = 8
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
        actionPublisher = PassthroughSubject<PostAction,Never>()
        postWorkoutView.isHidden = true
        layoutIfNeeded()
    }
}

// MARK: - Setup UI
private extension PostTableViewCell {
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.addSubview(fullPostStack)
        constrainUI()
        addActions()
    }
    func constrainUI() {
        let workoutAnchor = postWorkoutView.workoutView.heightAnchor.constraint(equalToConstant: 130)
        workoutAnchor.priority = .defaultLow
        let spacerHeight = spacerView.heightAnchor.constraint(equalToConstant: 44)
        spacerHeight.priority = .defaultLow
        NSLayoutConstraint.activate([
            fullPostStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            fullPostStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            fullPostStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            fullPostStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            spacerHeight,
            workoutAnchor,
            postWorkoutView.widthAnchor.constraint(equalTo: fullPostStack.widthAnchor),
            postInteractionsView.widthAnchor.constraint(equalTo: fullPostStack.widthAnchor)
        ])
    }
    func initViewModel() {
        
        viewModel.$isLiked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.setLiked(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.$imageData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.setProfileImage(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.$workoutModel
            .compactMap {$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.postWorkoutView.workoutView.configure(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.$savedWorkoutModel
            .compactMap {$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.postWorkoutView.workoutView.configure(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.completedLikeButtonAction
            .sink { [weak self] in self?.actionPublisher.send(.likeButtonTapped)}
            .store(in: &subscriptions)
        
//        viewModel.errorWorkout
//            .sink { [weak self] _ in self?.workoutView.setError()}
//            .store(in: &subscriptions)
        
        viewModel.checkLike()
        viewModel.loadProfileImage()
    }
}

private extension PostTableViewCell {
    func setLiked(to liked: Bool) {
        if liked {
            self.postInteractionsView.likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
            self.postInteractionsView.likeButton.isUserInteractionEnabled = false
        } else {
            self.postInteractionsView.likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
            self.postInteractionsView.likeButton.isUserInteractionEnabled = true
        }
    }
    func setProfileImage(with data: Data?) {
        if let data = data {
            let image = UIImage(data: data)
            postUserView.profileImageButton.setImage(image, for: .normal)
        } else {
            postUserView.profileImageButton.setImage(nil, for: .normal)
        }
    }
}

// MARK: - Public Configuration
extension PostTableViewCell {
    func configure(with post: DisplayablePost) {
        viewModel.post = post
        initViewModel()
        posterID = post.posterID
        postUserView.usernameButton.setTitle(post.username, for: .normal)
        if longDateFormat {
            let time = Date(timeIntervalSince1970: post.time)
            postUserView.timeLabel.text = time.getLongPostFormat()
        } else {
            let time = Date(timeIntervalSince1970: (post.time))
            postUserView.timeLabel.text = time.getShortPostFormat() + " ago"
        }
        if post.text.isEmpty {
            postTextView.isHidden = true
        } else {
            postTextView.isHidden = false
            postTextView.textView.text = post.text
        }
        postInteractionsView.replyCountLabel.text = post.replyCount.description
        postInteractionsView.likeCountLabel.text = post.likeCount.description
        clipImageView.isHidden = true
        photoImageView.isHidden = true
//        if post.attachedClip == nil { clipImageView.isHidden = true }
//        if post.attachedPhoto == nil { photoImageView.isHidden = true }
        if let workoutID = post.workoutID {
            postWorkoutView.isHidden = false
            postWorkoutView.workoutView.configure(with: workoutID, assignID: post.posterID)
        }
        if let savedWorkoutID = post.savedWorkoutID {
            postWorkoutView.isHidden = false
            postWorkoutView.workoutView.configure(for: savedWorkoutID)
        }
    }
}

// MARK: - Actions
extension PostTableViewCell {
    func addActions() {
        postInteractionsView.likeButton.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        postUserView.usernameButton.addTarget(self, action: #selector(userTapped(_:)), for: .touchUpInside)
        postUserView.profileImageButton.addTarget(self, action: #selector(userTapped(_:)), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(workoutTapped(_:)))
        postWorkoutView.workoutView.addGestureRecognizer(tap)
    }
    
    @objc func likeButtonTapped(_ sender: UIButton) {
        viewModel.likedPost()
        selection.prepare()
        selection.selectionChanged()
        UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve) {
            sender.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        } completion: { _ in
            sender.isUserInteractionEnabled = false
            self.postInteractionsView.likeCountLabel.increment()
//            self.actionPublisher.send(.likeButtonTapped)
        }
    }
    @objc func workoutTapped(_ sender: UIView) {
        actionPublisher.send(.workoutTapped)
    }
    @objc func userTapped(_ sender: UIButton) {
        actionPublisher.send(.userTapped)
    }
}
