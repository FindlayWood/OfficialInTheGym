//
//  RequestTableViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class RequestTableViewCell: UITableViewCell {
    
    // MARK: - Publisher
    var actionPublisher: PassthroughSubject<RequestCellAction,Never> = PassthroughSubject<RequestCellAction,Never>()
    
    // MARK: - Properties
    static let cellID = "RequestTableViewCellID"
    
    var viewModel = RequestTableViewCellViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Subview
    var profileImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.widthAnchor.constraint(equalToConstant: 64).isActive = true
        button.heightAnchor.constraint(equalToConstant: 64).isActive = true
        button.layer.cornerRadius = 32
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var usernameButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = Constants.font
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .darkColour
        view.widthAnchor.constraint(equalToConstant: 20).isActive = true
        view.heightAnchor.constraint(equalToConstant: 20).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var acceptButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.setTitle("Accept", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var declineButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.setTitle("Decline", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var buttonStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [acceptButton,declineButton])
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = 8
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
        actionPublisher = PassthroughSubject<RequestCellAction,Never>()
        setLoading(false)
    }
}
// MARK: - Setup UI
private extension RequestTableViewCell {
    func setupUI() {
        selectionStyle = .none
        contentView.addSubview(profileImageButton)
        contentView.addSubview(usernameButton)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(messageLabel)
        contentView.addSubview(buttonStack)
        constrainUI()
        initTargets()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            profileImageButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            profileImageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            usernameButton.centerYAnchor.constraint(equalTo: profileImageButton.centerYAnchor),
            usernameButton.leadingAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: 16),
            usernameButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            loadingIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            loadingIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            messageLabel.topAnchor.constraint(equalTo: usernameButton.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: usernameButton.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: usernameButton.trailingAnchor),
            
            buttonStack.leadingAnchor.constraint(equalTo: usernameButton.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonStack.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            buttonStack.heightAnchor.constraint(equalToConstant: 40),
            buttonStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Targets
    func initTargets() {
        acceptButton.addTarget(self, action: #selector(action(_:)), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(action(_:)), for: .touchUpInside)
    }
    // MARK: - Actions
    @objc func action(_ sender: UIButton) {
        if sender == acceptButton {
            viewModel.acceptRequest()
        } else if sender == declineButton {
            viewModel.declineRequest()
        }
    }
    func setLoading(_ loading: Bool) {
        if loading {
            loadingIndicator.startAnimating()
            acceptButton.isUserInteractionEnabled = false
            declineButton.isUserInteractionEnabled = false
        } else {
            loadingIndicator.stopAnimating()
            acceptButton.isUserInteractionEnabled = true
            declineButton.isUserInteractionEnabled = true
        }
    }
}

// MARK: - Public Configuration
extension RequestTableViewCell {
    
    public func configure(with model: RequestCellModel) {
        usernameButton.setTitle(model.user.displayName, for: .normal)
        messageLabel.text = "\(model.user.username) would like to become one of your coaches."
        
        let profileImageDownloadModel = ProfileImageDownloadModel(id: model.user.uid)
        ImageCache.shared.load(from: profileImageDownloadModel) { [weak self] result in
            do {
                let image = try result.get()
                self?.profileImageButton.setImage(image, for: .normal)
            } catch {
                self?.profileImageButton.setImage(nil, for: .normal)
            }
        }
        
        viewModel.successfullyAccepted
            .sink { [weak self] cellModel in
                self?.flash(to: .darkColour)
                self?.actionPublisher.send(.accept(cellModel))
            }
            .store(in: &subscriptions)
        
        viewModel.successfullyDeclined
            .sink { [weak self] in self?.actionPublisher.send(.decline($0))}
            .store(in: &subscriptions)
        
        viewModel.errorPublisher
            .sink { [weak self] _ in self?.actionPublisher.send(.error)}
            .store(in: &subscriptions)
        
        model.$isLoading
            .sink { [weak self] in self?.setLoading($0)}
            .store(in: &subscriptions)
        
        setLoading(model.isLoading)
        
    }
}
