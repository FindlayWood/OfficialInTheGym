//
//  CompletedWorkoutPageView.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class CompletedWorkoutPageView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var timeView: CompletedInfoView = {
        let view = CompletedInfoView()
        view.titleLabel.text = "Time"
        view.imageView.image = UIImage(named: "clock_icon")
        view.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.15).isActive = true
//        view.widthAnchor.constraint(equalToConstant: Constants.screenSize.width - 20).isActive = true
        view.addViewShadow(with: .darkColour)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var averageRPEView: CompletedInfoView = {
        let view = CompletedInfoView()
        view.titleLabel.text = "Average RPE"
        view.imageView.image = UIImage(named: "scores_icon")
        view.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.15).isActive = true
//        view.widthAnchor.constraint(equalToConstant: Constants.screenSize.width - 20).isActive = true
        view.addViewShadow(with: .darkColour)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var addSummaryButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .darkColour
        button.setTitle("add a summary", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.imageEdgeInsets.left = -30
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var summaryView: CompletedSummaryView = {
        let view = CompletedSummaryView()
        view.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.18).isActive = true
        //view.widthAnchor.constraint(equalToConstant: Constants.screenSize.width - 20).isActive = true
        view.addViewShadow(with: .darkColour)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var newView: WorkoutRPEScoreView = {
        let view = WorkoutRPEScoreView()
        view.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.15).isActive = true
        //view.widthAnchor.constraint(equalToConstant: Constants.screenSize.width - 20).isActive = true
        view.addViewShadow(with: .darkColour)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var workLoadView: CompletedInfoView = {
        let view = CompletedInfoView()
        view.titleLabel.text = "Workload"
        view.imageView.image = UIImage(named: "linechart_icon")
        view.addViewShadow(with: .darkColour)
        view.heightAnchor.constraint(equalToConstant: Constants.screenSize.height * 0.15).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var horizontalStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [timeView, averageRPEView])
        view.axis = .horizontal
        view.spacing = 10
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [newView, workLoadView, summaryView, addSummaryButton])
        view.axis = .vertical
        view.spacing = 10
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
// MARK: - Configure
private extension CompletedWorkoutPageView {
    func setupUI() {
        backgroundColor = .white
        addSubview(horizontalStack)
        addSubview(stack)
        workLoadView.isHidden = true
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            horizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            horizontalStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            stack.topAnchor.constraint(equalTo: horizontalStack.bottomAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
// MARK: - Public Configuration
extension CompletedWorkoutPageView {
    public func configure(with model: WorkoutModel) {
        timeView.label.text = model.timeToComplete?.convertToWorkoutTime()
        averageRPEView.label.text = model.averageRPE().description
        //newView.configure(with: model.score)
        if let summary = model.summary {
            addSummaryButton.isHidden = true
            summaryView.isHidden = false
            summaryView.summaryLabel.text = summary
        } else {
            summaryView.isHidden = true
            addSummaryButton.isHidden = false
        }
    }
    
    public func addRPE(score: Int) {
        newView.setNewScore(score: score)
    }
    
    public func addSummary() {
        UIView.animate(withDuration: 0.3) {
            self.summaryView.isHidden = false
            self.addSummaryButton.isHidden = true
        }
    }
    public func addWorkload(with load: Int) {
        UIView.animate(withDuration: 0.3) {
            self.workLoadView.label.text = load.description
            self.workLoadView.isHidden = false
        }
    }
}







// MARK: - Workout RPE Score View
class WorkoutRPEScoreView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 28)
        label.text = "Workout RPE"
        label.textColor = .darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var scoreLabelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Tap to add score", for: .normal)
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 22)
        button.setTitleColor(.darkColour, for: .normal)
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
    
}
// MARK: - Configure
private extension WorkoutRPEScoreView {
    func setupUI() {
        layer.cornerRadius = 10
        backgroundColor = .thirdColour
        addSubview(titleLabel)
        addSubview(scoreLabelButton)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            scoreLabelButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            scoreLabelButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10)
        ])
    }
}
extension WorkoutRPEScoreView {
    public func configure(with score: Int?) {
        guard let score = score else {return}
        scoreLabelButton.setTitle(score.description, for: .normal)
        scoreLabelButton.setTitleColor(Constants.rpeColors[score - 1], for: .normal)
    }
    public func setNewScore(score: Int) {
        UIView.animate(withDuration: 0.5) {
            self.backgroundColor = Constants.rpeColors[score - 1]
            self.scoreLabelButton.setTitle(score.description, for: .normal)
            self.scoreLabelButton.setTitleColor(Constants.rpeColors[score - 1], for: .normal)
        } completion: { _ in
            self.addViewShadow(with: Constants.rpeColors[score - 1])
            UIView.animate(withDuration: 0.5) {
                self.backgroundColor = .offWhiteColour
            }
        }
    }
}


// MARK: - Top Info View
class CompletedInfoView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 28)
        label.textColor = .darkColour
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
private extension CompletedInfoView {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.borderColor = UIColor.darkColour.cgColor
        layer.borderWidth = 2
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(label)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            titleLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -5),
            
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10)

        ])
    }
}


// MARK: - Summary View
class CompletedSummaryView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Summary"
        label.font = UIFont(name: "Menlo-Bold", size: 28)
        label.textColor = .darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(named: "note_icon")
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkColour
        label.numberOfLines = 0
        label.backgroundColor = .red
        label.text = "test test test /n test"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
private extension CompletedSummaryView {
    func setupUI() {
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 10
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(summaryLabel)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            summaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            summaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            summaryLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)

        ])
    }
}
