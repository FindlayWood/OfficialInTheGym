//
//  PlayerDashBoardCollectioncell.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/07/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import UIKit

class PlayerDashBoardCollectionCell: FullWidthCollectionViewCell {
    // MARK: - Properties
    static let reuseID = "PlayerDashBoardCollectionCellReuseID"
    var viewModel: PlayerDashBoardCollectionViewCellViewModel!
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Subviews
    var profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        view.widthAnchor.constraint(equalToConstant: 60).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var topDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var statusMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Training Status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var trainingStatusVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [statusMessageLabel, statusLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    var workloadMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Most Recent Workload"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var workloadLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, weight: .bold)
        label.textColor = .label
        label.text = "n/a"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var workloadTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, weight: .bold)
        label.textColor = .label
        label.text = "n/a"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var workloadTimeMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Time"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var workloadTimeVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [workloadTimeLabel, workloadTimeMessageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    var workloadDurationLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, weight: .bold)
        label.textColor = .label
        label.text = "n/a"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var workloadDurationMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Duration"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var workloadDurationVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [workloadDurationLabel, workloadDurationMessageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    var workloadRPELabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, weight: .bold)
        label.textColor = .label
        label.text = "n/a"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var workloadRPEMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "RPE"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var workloadRPEVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [workloadRPELabel, workloadRPEMessageLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    lazy var workloadHStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [workloadTimeVStack, workloadDurationVStack, workloadRPEVStack])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var wellnessMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Wellness Status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var wellnessLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var wellnessStatusVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [wellnessMessageLabel, wellnessLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    var injuryMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Injury Status"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var injuryLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var injuryStatusVStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [injuryMessageLabel, injuryLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    var stackDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryLabel
        view.widthAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var secondStackDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryLabel
        view.widthAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var hstack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [trainingStatusVStack, stackDivider, wellnessStatusVStack, secondStackDivider, injuryStatusVStack])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
private extension PlayerDashBoardCollectionCell {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkColour.cgColor
        contentView.addSubview(profileImageView)
        contentView.addSubview(fullNameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(topDivider)
        contentView.addSubview(hstack)
        contentView.addSubview(workloadMessageLabel)
        contentView.addSubview(workloadHStack)
//        contentView.addSubview(workloadLabel)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
            fullNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            usernameLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 4),
            
            topDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            topDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            topDivider.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            
            hstack.topAnchor.constraint(equalTo: topDivider.bottomAnchor, constant: 16),
            hstack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            stackDivider.heightAnchor.constraint(equalTo: hstack.heightAnchor, multiplier: 0.9),
            secondStackDivider.heightAnchor.constraint(equalTo: hstack.heightAnchor, multiplier: 0.9),
            
            workloadMessageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            workloadMessageLabel.topAnchor.constraint(equalTo: hstack.bottomAnchor, constant: 32),
            
            workloadHStack.topAnchor.constraint(equalTo: workloadMessageLabel.bottomAnchor, constant: 8),
            workloadHStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            workloadHStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            workloadHStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
//            workloadLabel.topAnchor.constraint(equalTo: workloadMessageLabel.bottomAnchor, constant: 8),
//            workloadLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
    func setProfileImage(with data: Data?) {
        if let data = data {
            let image = UIImage(data: data)
            profileImageView.image = image
        } else {
            profileImageView.image = nil
        }
    }
    func setTrainingStatus(to status: AthleteStatus) {
        statusLabel.text = status.title
        statusLabel.textColor = status.textColour
    }
    func setInjuryStatus(to status: InjuryStatus) {
        injuryLabel.text = status.title
    }
    func setWorkload(with model: WorkloadModel) {
        workloadHStack.isHidden = false
        let date = Date(timeIntervalSince1970: model.endTime)
        workloadTimeLabel.text = date.getAbbreviatedDateFormat()
        workloadDurationLabel.text = model.timeToComplete.convertToWorkoutTime()
        workloadRPELabel.text = model.rpe.description
    }
    func setWellness(to status: WellnessStatus) {
        wellnessLabel.text = status.title
    }
}
// MARK: - Public Config
extension PlayerDashBoardCollectionCell {
    public func configure(with user: Users) {
        fullNameLabel.text = user.displayName
        usernameLabel.text = "@" + user.username
        viewModel = .init(user: user)
        
        viewModel.$imageData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.setProfileImage(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.$latestWorkloadModel
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] in self?.setWorkload(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.$athleteWellnessStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.setWellness(to: $0) }
            .store(in: &subscriptions)
        
        viewModel.$athleteTrainingStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.setTrainingStatus(to: $0) }
            .store(in: &subscriptions)
        
        viewModel.$athleteInjuryStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.setInjuryStatus(to: $0) }
            .store(in: &subscriptions)
        
        viewModel.loadProfileImage()
        viewModel.loadLastWorkout()
        Task {
            await viewModel.loadWellness()
            await viewModel.loadTrainingStatus()
            await viewModel.loadInjuryStatus()
        }
    }
}
