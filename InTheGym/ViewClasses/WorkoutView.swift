//
//  WorkoutView.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class UIWorkoutView: UIView {
    
    // MARK: - Properties
    let iconDimension: CGFloat = 30
    
    private let imageDimension: CGFloat = 60
    
    var viewModel = WorkoutViewViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Subviews
        // LABELS
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .darkColour
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var completedStack: WorkoutViewCompletedHStack = {
        let stack = WorkoutViewCompletedHStack()
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var hstack: WorkoutViewHStack = {
        let view = WorkoutViewHStack()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var label: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.text = "Created By"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var userProfileImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 20
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var userView: UINameUsernameSubView = {
        let view = UINameUsernameSubView()
        view.configure(with: UserDefaults.currentUser)
        view.nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        view.usernameLabel.font = .systemFont(ofSize: 17, weight: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var userHStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [userProfileImage,userView])
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var clipView: UIClipThumbnailsView = {
        let view = UIClipThumbnailsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel,separatorView,completedStack,hstack,clipView])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.isHidden = true
        view.startAnimating()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var errorIcon: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        view.image = UIImage(named: "alert_icon")
        view.widthAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

// MARK: - Setup UI
private extension UIWorkoutView {
    func setupUI() {
        backgroundColor = .thirdColour
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkColour.cgColor
        addSubview(mainStack)
        addSubview(activityIndicator)
        addSubview(errorIcon)
        constrainUI()
        initViewModel()
    }
    func constrainUI() {
        let separatorHeihgtAnchor = separatorView.heightAnchor.constraint(equalToConstant: 1)
        separatorHeihgtAnchor.priority = UILayoutPriority(999)
        let titleHeight = titleLabel.heightAnchor.constraint(equalToConstant: 32)
        titleHeight.priority = UILayoutPriority(999)
        let hstackHeight = completedStack.heightAnchor.constraint(equalToConstant: 24)
        hstackHeight.priority = UILayoutPriority(999)
        let hstackHeightAnchor = hstack.heightAnchor.constraint(equalToConstant: 60)
        hstackHeightAnchor.priority = UILayoutPriority(999)
        let clipViewHeightAnchor = clipView.heightAnchor.constraint(equalToConstant: 46)
        clipViewHeightAnchor.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            separatorHeihgtAnchor,
            titleHeight,
            hstackHeight,
            hstackHeightAnchor,
            clipViewHeightAnchor,
            separatorView.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            titleLabel.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

            errorIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    // MARK: - Init View Model
    func initViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.setLoading(to: $0)}
            .store(in: &subscriptions)
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] _ in self?.setError()}
            .store(in: &subscriptions)
        viewModel.$savedWorkoutModel
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] in self?.configure(with: $0)}
            .store(in: &subscriptions)
        viewModel.$workoutModel
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] in self?.configure(with: $0)}
            .store(in: &subscriptions)
        
    }
    func setLoading(to loading: Bool) {
        if loading {
            mainStack.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            mainStack.isHidden = false
            activityIndicator.stopAnimating()
            errorIcon.isHidden = true
        }
    }
    func setError() {
        mainStack.isHidden = true
        activityIndicator.stopAnimating()
        errorIcon.isHidden = false
    }
}

// MARK: - Configure UI
extension UIWorkoutView {
    public func configure(with model: WorkoutModel) {
        stopLoading()
        mainStack.isHidden = false
        hstack.configure(with: model)
        errorIcon.isHidden = true
        titleLabel.text = model.title
        if model.clipData == nil {
            clipView.isHidden = true
        } else {
            clipView.isHidden = false
            clipView.configure(with: model.clipData)
        }
        hstack.exerciseCountLabel.text = model.totalExerciseCount().description
        if model.completed {
            completedStack.completedLabel.textColor = #colorLiteral(red: 0.00234289733, green: 0.8251151509, blue: 0.003635218529, alpha: 1)
            completedStack.completedLabel.text = "COMPLETED"
            if let time = model.startTime {
                completedStack.dateLabel.isHidden = false
                completedStack.dateLabel.text = Date(timeIntervalSince1970: time).getWorkoutFormat()
            } else {
                completedStack.dateLabel.isHidden = true
            }
        } else if model.liveWorkout ?? false {
            completedStack.completedLabel.text = "LIVE"
            completedStack.completedLabel.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            completedStack.dateLabel.isHidden = true
        } else if model.startTime != nil {
            completedStack.completedLabel.text = "IN PROGRESS"
            completedStack.completedLabel.textColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            completedStack.dateLabel.isHidden = true
        } else {
            completedStack.completedLabel.textColor = #colorLiteral(red: 0.8643916561, green: 0.1293050488, blue: 0.007468156787, alpha: 1)
            completedStack.completedLabel.text = "NOT STARTED"
            completedStack.dateLabel.isHidden = true
        }
    }
    public func configure(with model: SavedWorkoutModel) {
        stopLoading()
        mainStack.isHidden = false
        hstack.configure(with: model)
        clipView.isHidden = true
        errorIcon.isHidden = true
        completedStack.completedLabel.textColor = .lightColour
        completedStack.completedLabel.text = "Saved"
        completedStack.dateLabel.isHidden = true
        titleLabel.text = model.title
        hstack.exerciseCountLabel.text = model.totalExerciseCount().description

    }
    public func configure(with workoutID: String, assignID: String) {
        viewModel.loadWorkout(from: workoutID, assignID: assignID)
    }
    public func configure(for savedID: String) {
        viewModel.loadSavedWorkout(from: savedID)
    }
    public func setLoading() {
        mainStack.isHidden = true
        activityIndicator.isHidden = false
    }
    private func stopLoading() {
        activityIndicator.stopAnimating()
    }
}
