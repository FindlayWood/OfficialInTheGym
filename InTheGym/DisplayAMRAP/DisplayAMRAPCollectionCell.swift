//
//  DisplayAMRAPCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayAMRAPCollectionCell: UICollectionViewCell {
    
    var delegate: DisplayAMRAPProtocol!
    
    var exerciseName: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 45)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var repLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 100)
        label.textColor = Constants.darkColour
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var bottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var checkButton: UIButton = {
        let button = UIButton()
        button.setTitle("DONE", for: .normal)
        button.titleLabel?.font = Constants.font
        button.setTitleColor(Constants.darkColour, for: .normal)
        button.addTarget(self, action: #selector(complete), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.offWhiteColour
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        addSubview(exerciseName)
        addSubview(topSeparatorView)
        addSubview(repLabel)
        addSubview(bottomSeparatorView)
        addSubview(checkButton)
        constrain()
        layer.cornerRadius = 10
    }
    
    private func constrain() {
        NSLayoutConstraint.activate([exerciseName.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     repLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     checkButton.centerXAnchor.constraint(equalTo: centerXAnchor),
        
                                     exerciseName.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                     
                                     topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     topSeparatorView.topAnchor.constraint(equalTo: exerciseName.bottomAnchor, constant: 5),
                                     topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     topSeparatorView.heightAnchor.constraint(equalToConstant: 1),
                                     
                                     repLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     checkButton.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -10),
        
                                     bottomSeparatorView.bottomAnchor.constraint(equalTo: checkButton.topAnchor, constant: -5),
                                     bottomSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     bottomSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1)])
    }
    
    func setup(with model: exercise) {
        exerciseName.text = model.exercise
        repLabel.text = model.reps?.description
    }
    @objc func complete() {
        delegate.exerciseCompleted()
    }
}
