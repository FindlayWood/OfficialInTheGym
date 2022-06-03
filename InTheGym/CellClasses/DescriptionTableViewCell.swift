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
    
    let notVoteImage = UIImage(systemName: "hand.thumbsup", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
    let voteImage = UIImage(systemName: "hand.thumbsup.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
    
    var model: DescriptionModel!
    
    var viewModel = DescriptionsCellViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
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
        button.setImage(UIImage(systemName: "hand.thumbsup", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        button.tintColor = .darkColour
        button.imageView?.contentMode = .scaleAspectFill
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var voteLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.text = "100"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        self.upVoteButton.setImage(notVoteImage, for: .normal)
        self.upVoteButton.isUserInteractionEnabled = true
    }
}
// MARK: - Setup UI
private extension DescriptionTableViewCell {
    func setupUI() {
        selectionStyle = .none
        contentView.addSubview(profileImageButton)
        contentView.addSubview(usernameButton)
        contentView.addSubview(timeLabel)
        contentView.addSubview(descriptionText)
        contentView.addSubview(upVoteButton)
        contentView.addSubview(voteLabel)
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
            
            upVoteButton.topAnchor.constraint(equalTo: descriptionText.topAnchor),
            upVoteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            voteLabel.topAnchor.constraint(equalTo: upVoteButton.bottomAnchor),
            voteLabel.centerXAnchor.constraint(equalTo: upVoteButton.centerXAnchor),
            voteLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            
            descriptionText.trailingAnchor.constraint(equalTo: upVoteButton.leadingAnchor, constant: -8),
            descriptionText.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    func initButtonActions() {
        upVoteButton.addTarget(self, action: #selector(upVoteAction(_:)), for: .touchUpInside)
        profileImageButton.addTarget(self, action: #selector(userTappedAction(_:)), for: .touchUpInside)
        usernameButton.addTarget(self, action: #selector(userTappedAction(_:)), for: .touchUpInside)
    }
    @objc func upVoteAction(_ sender: UIButton) {
        model.vote += 1
        voteLabel.text = model.vote.description
        viewModel.vote()
        UIView.animate(withDuration: 0.3) {
            self.upVoteButton.setImage(self.voteImage, for: .normal)
        } completion: { _ in
            self.upVoteButton.isUserInteractionEnabled = false
        }
    }
    @objc func userTappedAction(_ sender: UIButton) {
        actionPublisher.send(.userTapped)
    }
}
// MARK: - Public Configuration
extension DescriptionTableViewCell {
    func configure(with model: DescriptionModel) {
        viewModel.descriptionModel = model
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
        viewModel.votedPublishers
            .sink { [weak self] voted in
                if voted {
                    self?.upVoteButton.setImage(self?.voteImage, for: .normal)
                    self?.upVoteButton.isUserInteractionEnabled = false
                } else {
                    self?.upVoteButton.setImage(self?.notVoteImage, for: .normal)
                    self?.upVoteButton.isUserInteractionEnabled = true
                }
            }
            .store(in: &subscriptions)
        
        viewModel.checkVote()
    }
}
