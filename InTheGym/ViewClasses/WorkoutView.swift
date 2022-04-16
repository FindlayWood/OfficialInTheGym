//
//  WorkoutView.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class UIWorkoutView: UIView {
    
    // MARK: - Properties
    let iconDimension: CGFloat = 30
    
    // MARK: - Subviews
        // LABELS
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var creatorLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var exerciseCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.text = " "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        // ICONS
    lazy var creatorIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "coach_icon")
        view.widthAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var exerciseIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "dumbbell_icon")
        view.widthAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: iconDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        addSubview(titleLabel)
        addSubview(creatorLabel)
        addSubview(exerciseCountLabel)
        addSubview(creatorIcon)
        addSubview(exerciseIcon)
        addSubview(activityIndicator)
        addSubview(errorIcon)
        constrainUI()
        setLoading()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            creatorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            creatorIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            creatorIcon.centerYAnchor.constraint(equalTo: creatorLabel.centerYAnchor),
            creatorLabel.leadingAnchor.constraint(equalTo: creatorIcon.trailingAnchor, constant: 5),
            creatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            exerciseCountLabel.topAnchor.constraint(equalTo: creatorLabel.bottomAnchor, constant: 15),
            exerciseIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            exerciseIcon.centerYAnchor.constraint(equalTo: exerciseCountLabel.centerYAnchor),
            exerciseCountLabel.leadingAnchor.constraint(equalTo: exerciseIcon.trailingAnchor, constant: 5),
            exerciseCountLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
//            activityIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 32),
//            activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            
            errorIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
//            errorIcon.topAnchor.constraint(equalTo: topAnchor, constant: 32),
//            errorIcon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32)
        ])
    }
}

// MARK: - Configure UI
extension UIWorkoutView {
    public func configure(with data: WorkoutDelegate) {
        stopLoading()
        titleLabel.text = data.title
        creatorLabel.text = data.createdBy
        exerciseCountLabel.text = data.exercises?.count.description
    }
    public func newConfigure(with attachment: attachedWorkout) {
        stopLoading()
        titleLabel.text = attachment.title
        creatorLabel.text = attachment.createdBy
        exerciseCountLabel.text = attachment.exerciseCount.description
    }
    public func configure(with model: WorkoutModel) {
        stopLoading()
        creatorIcon.isHidden = false
        exerciseIcon.isHidden = false
        errorIcon.isHidden = true
        titleLabel.text = model.title
        creatorLabel.text = model.createdBy
        exerciseCountLabel.text = model.totalExerciseCount().description
    }
    public func configure(with model: SavedWorkoutModel) {
        stopLoading()
        creatorIcon.isHidden = false
        exerciseIcon.isHidden = false
        errorIcon.isHidden = true
        titleLabel.text = model.title
        creatorLabel.text = model.createdBy
        exerciseCountLabel.text = model.totalExerciseCount().description
    }
    public func configure(with workoutID: String, assignID: String) {
        let searchModel = WorkoutKeyModel(id: workoutID, assignID: assignID)
        WorkoutLoader.shared.load(from: searchModel) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let model):
                self.configure(with: model)
            case .failure(_):
                self.setError()
            }
        }
    }
    public func configure(for savedID: String) {
        let searchModel = SavedWorkoutKeyModel(id: savedID)
        SavedWorkoutLoader.shared.load(from: searchModel) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let model):
                self.configure(with: model)
            case .failure(_):
                self.setError()
            }
        }
    }
    public func setLoading() {
        creatorIcon.isHidden = true
        exerciseIcon.isHidden = true
        activityIndicator.isHidden = false
    }
    private func stopLoading() {
        creatorIcon.isHidden = false
        exerciseIcon.isHidden = false
        activityIndicator.stopAnimating()
    }
    public func setError() {
        errorIcon.isHidden = false
        activityIndicator.stopAnimating()
        titleLabel.text = " "
        creatorLabel.text = " "
        exerciseCountLabel.text = " "
        creatorIcon.isHidden = true
        exerciseIcon.isHidden = true
    }
}
