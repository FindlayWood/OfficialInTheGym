//
//  DescriptionTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import UIKit
import Combine

class DescriptionTableViewCell: UITableViewCell {
    // MARK: - Publishers
    var actionPublisher = PassthroughSubject<DescriptionAction,Never>()
    // MARK: - Properties
    static let cellID = "DescriptionTableViewCellID"
    var viewModel = DescriptionsCellViewModel()
    private var subscriptions = Set<AnyCancellable>()
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
    var commentText: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.textColor = .black
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var interactionSubview: PostInteractionsSubview = {
        let view = PostInteractionsSubview()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        profileImageButton.setImage(nil, for: .normal)
        actionPublisher = PassthroughSubject<DescriptionAction,Never>()
    }
}
// MARK: - Setup UI
private extension DescriptionTableViewCell {
    func setupUI() {
        selectionStyle = .none
        contentView.addSubview(profileImageButton)
        contentView.addSubview(usernameButton)
        contentView.addSubview(timeLabel)
        contentView.addSubview(commentText)
        contentView.addSubview(interactionSubview)
        constrainUI()
        initButtonActions()
//        initViewModel()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            profileImageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

            usernameButton.leadingAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: 10),
            usernameButton.topAnchor.constraint(equalTo: profileImageButton.topAnchor),

            timeLabel.topAnchor.constraint(equalTo: usernameButton.bottomAnchor, constant: 1),
            timeLabel.leadingAnchor.constraint(equalTo: usernameButton.leadingAnchor, constant: 2),

            commentText.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 15),
            commentText.leadingAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: 10),
            
            commentText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            interactionSubview.topAnchor.constraint(equalTo: commentText.bottomAnchor, constant: 8),
            interactionSubview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            interactionSubview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            interactionSubview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    // MARK: - Targets
    func initButtonActions() {
        interactionSubview.likeButton.addTarget(self, action: #selector(likeButtonAction(_:)), for: .touchUpInside)
        profileImageButton.addTarget(self, action: #selector(userTappedAction(_:)), for: .touchUpInside)
        usernameButton.addTarget(self, action: #selector(userTappedAction(_:)), for: .touchUpInside)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.votedPublishers
            .sink { [weak self] in self?.setLiked(to: $0)}
            .store(in: &subscriptions)
        viewModel.$imageData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.setProfileImage(with: $0)}
            .store(in: &subscriptions)
        viewModel.checkVote()
        viewModel.loadProfileImage()
    }
}
private extension DescriptionTableViewCell {
    func setLiked(to liked: Bool) {
        if liked {
            self.interactionSubview.likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
            self.interactionSubview.likeButton.isUserInteractionEnabled = false
            self.interactionSubview.likeButton.tintColor = .redColour
        } else {
            self.interactionSubview.likeButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
            self.interactionSubview.likeButton.isUserInteractionEnabled = true
            self.interactionSubview.likeButton.tintColor = .darkColour
        }
    }
    func setProfileImage(with data: Data?) {
        if let data = data {
            let image = UIImage(data: data)
            profileImageButton.setImage(image, for: .normal)
        } else {
            profileImageButton.setImage(nil, for: .normal)
        }
    }
}
// MARK: - Actions
private extension DescriptionTableViewCell {
    @objc func likeButtonAction(_ sender: UIButton) {
        viewModel.likeButtonAction()
        UIView.animate(withDuration: 0.3) {
            sender.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)), for: .normal)
            sender.tintColor = .redColour
        } completion: { _ in
            sender.isUserInteractionEnabled = false
            self.interactionSubview.likeCountLabel.increment()
        }
    }
    @objc func userTappedAction(_ sender: UIButton) {
        actionPublisher.send(.userTapped)
    }
}
// MARK: - Public Configuration
extension DescriptionTableViewCell {
    func configure(with model: DisplayableComment) {
        viewModel.descriptionModel = model
        initViewModel()
        usernameButton.setTitle(model.username, for: .normal)
        let then = Date(timeIntervalSince1970: (model.time))
        timeLabel.text = then.timeAgo() + " ago"
        commentText.text = model.comment
        interactionSubview.likeCountLabel.text = model.likeCount.description
        interactionSubview.replyCountLabel.text = model.replyCount.description
    }
}
