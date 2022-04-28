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
//    var actionPublisher = PassthroughSubject<PostAction,Never>()
    var actionPublisher: PassthroughSubject<PostAction,Never> = PassthroughSubject<PostAction,Never>()
    
    // MARK: - Properties
    static let cellID = "postCellID"
    
    weak var delegate: TimelineTapProtocol?
    
    let selection = UISelectionFeedbackGenerator()

    var posterID: String!
    
    var viewModel = PostCellViewModel()
    
    var longDateFormat: Bool = false
    
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
    var workoutView: UIWorkoutView = {
        let view = UIWorkoutView()
        view.isHidden = true
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
    var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        if #available(iOS 13.0, *) {
            view.image = UIImage(systemName: "arrow.turn.left.down")
        }
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
        workoutView.isHidden = true
    }
}

// MARK: - Setup UI
private extension PostTableViewCell {
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .white
        contentView.addSubview(profileImageButton)
        contentView.addSubview(usernameButton)
        contentView.addSubview(timeLabel)
        contentView.addSubview(textView)
        stack.addArrangedSubview(workoutView)
        stack.addArrangedSubview(photoImageView)
        stack.addArrangedSubview(clipImageView)
        contentView.addSubview(stack)
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
            
            stack.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 5),
            stack.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            
            workoutView.widthAnchor.constraint(equalTo: stack.widthAnchor),
            photoImageView.widthAnchor.constraint(equalTo: stack.widthAnchor),
            photoImageView.heightAnchor.constraint(equalTo: stack.widthAnchor),
            clipImageView.widthAnchor.constraint(equalTo: stack.widthAnchor),
            clipImageView.heightAnchor.constraint(equalTo: stack.widthAnchor),
            
            
            replyImageView.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            replyCountLabel.leadingAnchor.constraint(equalTo: replyImageView.trailingAnchor, constant: 5),
            
            likeCountLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            likeButton.trailingAnchor.constraint(equalTo: likeCountLabel.leadingAnchor, constant: -5),
            
            replyImageView.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 10),
            replyCountLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 10),
            likeButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 10),
            likeCountLabel.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 10),
            
            
            replyImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            replyCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            likeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            likeCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }
    func initViewModel() {
        
    }
}

// MARK: - Public Configuration
extension PostTableViewCell {
    func configure(with post: DisplayablePost) {
        viewModel.post = post
        posterID = post.posterID
        usernameButton.setTitle(post.username, for: .normal)
        if longDateFormat {
            let time = Date(timeIntervalSince1970: post.time)
            timeLabel.text = time.getLongPostFormat()
        } else {
            let time = Date(timeIntervalSince1970: (post.time))
            timeLabel.text = time.getShortPostFormat() + " ago"
        }
        textView.text = post.text
        replyCountLabel.text = post.replyCount.description
        likeCountLabel.text = post.likeCount.description
        if post.attachedClip == nil { clipImageView.isHidden = true }
        if post.attachedPhoto == nil { photoImageView.isHidden = true }
        if let workoutID = post.workoutID {
            workoutView.isHidden = false
            workoutView.configure(with: workoutID, assignID: post.posterID)
        } 
        if let savedWorkoutID = post.savedWorkoutID {
            workoutView.isHidden = false
            workoutView.configure(for: savedWorkoutID)
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
        
//        LikesAPIService.shared.check(postID: post.id) { [weak self] liked in
//            guard let self = self else {return}
//            if liked {
//                self.likeButton.setImage(UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
//                self.likeButton.isUserInteractionEnabled = false
//            } else {
//                self.likeButton.setImage(UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
//                self.likeButton.isUserInteractionEnabled = true
//            }
//        }
    }
}

// MARK: - Actions
extension PostTableViewCell {
    func addActions() {
        likeButton.addTarget(self, action: #selector(likeButtonTapped(_:)), for: .touchUpInside)
        usernameButton.addTarget(self, action: #selector(userTapped(_:)), for: .touchUpInside)
        profileImageButton.addTarget(self, action: #selector(userTapped(_:)), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(workoutTapped(_:)))
        workoutView.addGestureRecognizer(tap)
    }
    
    @objc func likeButtonTapped(_ sender: UIButton) {
//        actionPublisher.send(.likeButtonTapped)
        viewModel.likedPost()
        selection.prepare()
        selection.selectionChanged()
        UIView.transition(with: sender, duration: 0.3, options: .transitionCrossDissolve) {
            sender.setImage(UIImage(systemName: "star.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        } completion: { _ in
            sender.isUserInteractionEnabled = false
            self.likeCountLabel.increment()
        }
//        delegate?.likeButtonTapped(on: self, sender: sender, label: likeCountLabel)
    }
    @objc func workoutTapped(_ sender: UIView) {
        actionPublisher.send(.workoutTapped)
        delegate?.workoutTapped(on: self)
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
