//
//  MainWorkoutCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class MainWorkoutCollectionCell: UICollectionViewCell {
    // MARK: - Publisher
    var completeButtonTapped = PassthroughSubject<Void,Never>()
    
    // MARK: - Properties
    static var reuseID = "MainWorkoutCollectionCell"
    
    // MARK: - Subviews
    var setLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 22)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var repsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 22)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var weightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 22)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var labelStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [setLabel, repsLabel, weightLabel])
        view.spacing = 10
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var completeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(named: "emptyRing"), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addActions()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        setupUI()
//    }
    func setLayout() {
        layer.borderColor = UIColor.black.cgColor
        contentView.layer.cornerRadius = 10
        //contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false

        layer.cornerRadius = 10
    }
    func addActions() {
        completeButton.addTarget(self, action: #selector(complete(_:)), for: .touchUpInside)
    }
}
// MARK: - Configure
private extension MainWorkoutCollectionCell {
    func setupUI() {
        setLayout()
        //backgroundColor = .lightColour
        contentView.addSubview(labelStack)
        contentView.addSubview(completeButton)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            labelStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            labelStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            labelStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            completeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            completeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
}

// MARK: - Public Configuration
extension MainWorkoutCollectionCell {
    public func configure(with model: ExerciseSet) {
        setLabel.text = "Set " + model.set.description
        repsLabel.text = model.reps.description + " reps"
        weightLabel.text = model.weight
        if model.completed {
            self.backgroundColor = .darkColour
            completeButton.setImage(UIImage(named: "tickRing"), for: .normal)
            completeButton.isUserInteractionEnabled = false
        } else {
            self.backgroundColor = .lightColour
            completeButton.setImage(UIImage(named: "emptyRing"), for: .normal)
            completeButton.isUserInteractionEnabled = true
        }
    }
    public func setUserInteraction(to enabled: Bool) {
        self.completeButton.isUserInteractionEnabled = enabled
    }
}

// MARK: - Actions
private extension MainWorkoutCollectionCell {
    @objc func complete(_ sender: UIButton) {
        completeButtonTapped.send(())
        sender.setImage(UIImage(named: "tickRing"), for: .normal)
        sender.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5) {
            self.backgroundColor = UIColor.green
        } completion: { (_) in
            UIView.animate(withDuration: 0.5) {
                self.backgroundColor = .darkColour
            } completion: { (_) in
                let collection = self.superview as! UICollectionView
                let currentIndex = collection.indexPath(for: self)?.item
                let lastindextoscroll = collection.numberOfItems(inSection: 0) - 1
                if currentIndex! < lastindextoscroll {
                    let indextoscroll = IndexPath.init(row: currentIndex! + 1, section: 0)
                    collection.scrollToItem(at: indextoscroll, at: .left, animated: true)
                }
            }
        }
    }
}

struct ExerciseSet: Hashable {
    var set: Int
    var reps: Int
    var weight: String
    var completed: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(set)
    }
}
