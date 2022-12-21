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
    var view = PostCellView()
    
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
        view.postWorkoutView.isHidden = true
        view.postUserView.profileImageButton.setImage(nil, for: .normal)
        layoutIfNeeded()
    }
}

// MARK: - Setup UI
private extension PostTableViewCell {
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.addSubview(view)
        constrainUI()
        addActions()
    }
    func constrainUI() {
        view.translatesAutoresizingMaskIntoConstraints = false
        let workoutAnchor = view.postWorkoutView.workoutView.heightAnchor.constraint(equalToConstant: 130)
        workoutAnchor.priority = .defaultLow
        let spacerHeight = view.spacerView.heightAnchor.constraint(equalToConstant: 44)
        spacerHeight.priority = .defaultLow
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.$isLiked
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.setLiked(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.$profileImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.setProfileImage(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.$userModel
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] in self?.view.postUserView.stampView.configureForPost(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.$workoutModel
            .compactMap {$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.view.postWorkoutView.workoutView.configure(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.$savedWorkoutModel
            .compactMap {$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.view.postWorkoutView.workoutView.configure(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.completedLikeButtonAction
            .sink { [weak self] in self?.actionPublisher.send(.likeButtonTapped)}
            .store(in: &subscriptions)
        
//        viewModel.errorWorkout
//            .sink { [weak self] _ in self?.workoutView.setError()}
//            .store(in: &subscriptions)
        
        viewModel.checkLike()
        viewModel.loadProfileImage()
        viewModel.loadUserModel()
    }
}

private extension PostTableViewCell {
    func setLiked(to liked: Bool) {
        if liked {
            self.view.postInteractionsView.likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
            self.view.postInteractionsView.likeButton.isUserInteractionEnabled = false
            self.view.postInteractionsView.likeButton.tintColor = .redColour
        } else {
            self.view.postInteractionsView.likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
            self.view.postInteractionsView.likeButton.isUserInteractionEnabled = true
            self.view.postInteractionsView.likeButton.tintColor = .darkColour
        }
    }
    func setProfileImage(with image: UIImage?) {
        if let image = image {
            self.view.postUserView.profileImageButton.setImage(image, for: .normal)
        } else {
            self.view.postUserView.profileImageButton.setImage(nil, for: .normal)
        }
    }
}

// MARK: - Public Configuration
extension PostTableViewCell {
    func configure(with post: DisplayablePost) {
        viewModel.post = post
        initViewModel()
        posterID = post.posterID
        view.postUserView.usernameButton.setTitle(post.username, for: .normal)
        if longDateFormat {
            let time = Date(timeIntervalSince1970: post.time)
            view.postUserView.timeLabel.text = time.getLongPostFormat()
        } else {
            let time = Date(timeIntervalSince1970: (post.time))
            view.postUserView.timeLabel.text = time.getShortPostFormat() + " ago"
        }
        if post.text.isEmpty {
            view.postTextView.isHidden = true
        } else {
            view.postTextView.isHidden = false
            view.postTextView.textView.text = post.text
        }
        view.postInteractionsView.replyCountLabel.text = post.replyCount.description
        view.postInteractionsView.likeCountLabel.text = post.likeCount.description
        view.clipImageView.isHidden = true
        view.photoImageView.isHidden = true
//        if post.attachedClip == nil { clipImageView.isHidden = true }
//        if post.attachedPhoto == nil { photoImageView.isHidden = true }
        if let workoutID = post.workoutID {
            view.postWorkoutView.isHidden = false
            view.postWorkoutView.workoutView.configure(with: workoutID, assignID: post.posterID)
        }
        if let savedWorkoutID = post.savedWorkoutID {
            view.postWorkoutView.isHidden = false
            view.postWorkoutView.workoutView.configure(for: savedWorkoutID)
        }
    }
}

// MARK: - Actions
extension PostTableViewCell {
    func addActions() {
        view.postInteractionsView.likeButton.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        view.postUserView.usernameButton.addTarget(self, action: #selector(userTapped(_:)), for: .touchUpInside)
        view.postUserView.profileImageButton.addTarget(self, action: #selector(userTapped(_:)), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(workoutTapped(_:)))
        view.postWorkoutView.workoutView.addGestureRecognizer(tap)
    }
    
    @objc func likeButtonTapped(_ sender: UIButton) {
        viewModel.likedPost()
        selection.prepare()
        selection.selectionChanged()
        UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve) {
            sender.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
            sender.tintColor = .redColour
        } completion: { _ in
            sender.isUserInteractionEnabled = false
            self.view.postInteractionsView.likeCountLabel.increment()
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
