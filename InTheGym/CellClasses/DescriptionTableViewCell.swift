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
    
    var model: DescriptionModel!
    
    // MARK: - Subviews
    var profileImageButton: UIButton = {
        let button = UIButton()
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
    var descriptionText: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 17, weight: .semibold)
        view.textColor = .black
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var upVoteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var voteLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .black
        label.text = "100"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var downVoteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var voteStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [upVoteButton,voteLabel,downVoteButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillEqually
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
}

// MARK: - Setup UI
private extension DescriptionTableViewCell {
    func setupUI() {
        contentView.addSubview(profileImageButton)
        contentView.addSubview(usernameButton)
        contentView.addSubview(timeLabel)
        contentView.addSubview(descriptionText)
        contentView.addSubview(voteStack)
        constrainUI()
        initButtonActions()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            profileImageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            usernameButton.leadingAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: 10),
            usernameButton.topAnchor.constraint(equalTo: profileImageButton.topAnchor),
            
            timeLabel.topAnchor.constraint(equalTo: usernameButton.bottomAnchor, constant: 1),
            timeLabel.leadingAnchor.constraint(equalTo: usernameButton.leadingAnchor, constant: 2),
            
            descriptionText.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 15),
            descriptionText.leadingAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: 10),
            
            voteStack.topAnchor.constraint(equalTo: descriptionText.topAnchor),
            voteStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            voteStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            
            descriptionText.trailingAnchor.constraint(equalTo: voteStack.leadingAnchor, constant: -8),
            descriptionText.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
            
        
        ])
    }
    func initButtonActions() {
        upVoteButton.addTarget(self, action: #selector(upVoteAction(_:)), for: .touchUpInside)
        downVoteButton.addTarget(self, action: #selector(downVoteAction(_:)), for: .touchUpInside)
        profileImageButton.addTarget(self, action: #selector(userTappedAction(_:)), for: .touchUpInside)
        usernameButton.addTarget(self, action: #selector(userTappedAction(_:)), for: .touchUpInside)
    }
    @objc func upVoteAction(_ sender: UIButton) {
        model.vote += 1
        voteLabel.text = model.vote.description
//        actionPublisher.send(.upVote)
    }
    @objc func downVoteAction(_ sender: UIButton) {
        model.vote -= 1
        voteLabel.text = model.vote.description
//        actionPublisher.send(.downVote)
    }
    @objc func userTappedAction(_ sender: UIButton) {
        actionPublisher.send(.userTapped)
    }
}

// MARK: - Public Configuration
extension DescriptionTableViewCell {
    func configure(with model: DescriptionModel) {
        self.model = model
        usernameButton.setTitle(model.username, for: .normal)
        let then = Date(timeIntervalSince1970: (model.time))
        timeLabel.text = then.timeAgo() + " ago"
        descriptionText.text = model.description
        voteLabel.text = model.vote.description
        let profileImageModel = ProfileImageDownloadModel(id: model.posterID)
        ImageCache.shared.load(from: profileImageModel) { [weak self] result in
            switch result {
            case .success(let image):
                self?.profileImageButton.setImage(image, for: .normal)
            case .failure(_):
                self?.profileImageButton.backgroundColor = .lightGray
            }
        }
    }
}
