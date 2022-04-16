//
//  PostCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import UIKit
import Combine

class PostCollectionViewCell: FullWidthCollectionViewCell {
    
    // MARK: - Publishers
//    var actionPublisher = PassthroughSubject<PostAction,Never>()
    var actionPublisher: PassthroughSubject<PostAction,Never> = PassthroughSubject<PostAction,Never>()
    
    // MARK: - Properties
    static let reuseID = "PostCollectionViewCellReuseID"
    
    let selection = UISelectionFeedbackGenerator()

    var posterID: String!
    
    // MARK: - Subviews
    var profileImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var usernameButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .light)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var textView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.textColor = .black
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Stack Subviews
    var dataView: UIPostDataView = {
        let view = UIPostDataView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var replyCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .darkGray
        label.widthAnchor.constraint(equalToConstant: 40).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var replyImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.image = UIImage(systemName: "arrow.turn.left.down")
        view.tintColor = .darkColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .darkGray
        label.widthAnchor.constraint(equalToConstant: 40).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var likeButton: UIButton = {
        let button = UIButton()
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        }
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        actionPublisher = PassthroughSubject<PostAction,Never>()
        dataView.workoutView.isHidden = true
    }
}

// MARK: - Setup UI
private extension PostCollectionViewCell {
    func setupUI() {
        backgroundColor = .white
        contentView.addSubview(profileImageButton)
        contentView.addSubview(usernameButton)
        contentView.addSubview(timeLabel)
        contentView.addSubview(textView)
        contentView.addSubview(dataView)
        contentView.addSubview(replyImageView)
        contentView.addSubview(replyCountLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(likeCountLabel)
        constrainUI()
        addActions()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            profileImageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            usernameButton.leadingAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: 10),
            usernameButton.topAnchor.constraint(equalTo: profileImageButton.topAnchor),
            
            
            timeLabel.topAnchor.constraint(equalTo: usernameButton.bottomAnchor, constant: 1),
            timeLabel.leadingAnchor.constraint(equalTo: usernameButton.leadingAnchor, constant: 2),

            textView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 15),
            textView.leadingAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            dataView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            dataView.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            dataView.trailingAnchor.constraint(equalTo: textView.trailingAnchor),

            replyImageView.topAnchor.constraint(equalTo: dataView.bottomAnchor, constant: 16),
            replyImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            replyImageView.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            replyCountLabel.leadingAnchor.constraint(equalTo: replyImageView.trailingAnchor, constant: 5),

            likeCountLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            likeButton.trailingAnchor.constraint(equalTo: likeCountLabel.leadingAnchor, constant: -5),


            replyCountLabel.topAnchor.constraint(equalTo: replyImageView.topAnchor),
            likeButton.topAnchor.constraint(equalTo: dataView.bottomAnchor, constant: 16),
            likeCountLabel.topAnchor.constraint(equalTo: likeButton.topAnchor),
        ])
    }
}

// MARK: - Public Configuration
extension PostCollectionViewCell {
    func configure(with post: DisplayablePost) {
        posterID = post.posterID
        usernameButton.setTitle(post.username, for: .normal)
        let then = Date(timeIntervalSince1970: (post.time))
        timeLabel.text = then.timeAgo() + " ago"
        textView.text = post.text
        replyCountLabel.text = post.replyCount.description
        likeCountLabel.text = post.likeCount.description
        if post.attachedClip == nil { dataView.clipImageView.isHidden = true }
        if post.attachedPhoto == nil { dataView.photoImageView.isHidden = true }
        if let workoutID = post.workoutID {
            dataView.workoutView.isHidden = false
            dataView.workoutView.configure(with: workoutID, assignID: post.posterID)
        }
        if let savedWorkoutID = post.savedWorkoutID {
            dataView.workoutView.isHidden = false
            dataView.workoutView.configure(for: savedWorkoutID)
        }

        let profileImageModel = ProfileImageDownloadModel(id: post.posterID)
        ImageCache.shared.load(from: profileImageModel) { [weak self] result in
            let image = try? result.get()
            self?.profileImageButton.setImage(image, for: .normal)
        }
        let likeModel = LikeSearchModel(postID: post.id)
        LikeCache.shared.load(from: likeModel) { [weak self] result in
            guard let self = self else {return}
            guard let liked = try? result.get() else {return}
            if liked {
                self.likeButton.setImage(UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
                self.likeButton.isUserInteractionEnabled = false
            } else {
                self.likeButton.setImage(UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
                self.likeButton.isUserInteractionEnabled = true
            }
        }
    }
}

// MARK: - Actions
extension PostCollectionViewCell {
    func addActions() {
        likeButton.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        usernameButton.addTarget(self, action: #selector(userTapped(_:)), for: .touchUpInside)
        profileImageButton.addTarget(self, action: #selector(userTapped(_:)), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(workoutTapped(_:)))
        dataView.workoutView.addGestureRecognizer(tap)
    }
    
    @objc func likeButtonTapped(_ sender: UIButton) {
        actionPublisher.send(.likeButtonTapped)
        UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve) {
            sender.setImage(UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        } completion: { _ in
            sender.isUserInteractionEnabled = false
            self.likeCountLabel.increment()
        }
    }
    
    @objc func workoutTapped(_ sender: UIView) {
        actionPublisher.send(.workoutTapped)
    }
    @objc func userTapped(_ sender: UIButton) {
        actionPublisher.send(.userTapped)
    }
    
    func postLikedTransition() {
        
        selection.prepare()
        selection.selectionChanged()
        UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve) {
            if #available(iOS 13.0, *) {
                self.likeButton.setImage(UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
            }
        }completion: { _ in
            self.likeButton.isUserInteractionEnabled = false
            self.likeCountLabel.increment()
        }
    }
}
