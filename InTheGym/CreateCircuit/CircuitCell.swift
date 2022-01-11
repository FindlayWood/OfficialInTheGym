//
//  CircuitCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class CircuitCell: UITableViewCell {
    
    // MARK: - Properties
    static let cellID = "CircuitCellID"
    
    // MARK: - Subviews
    var exerciseName: UILabel = {
       let label = UILabel()
        label.font = Constants.font
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separatorLine: UIView = {
       let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var setsLabel: UILabel = {
        let label = UILabel()
         label.font = Constants.font
         label.textColor = .black
         label.textAlignment = .center
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - Setup UI
private extension CircuitCell {
    
    func setUpView() {
        backgroundColor = Constants.offWhiteColour
        layer.cornerRadius = 10
        addSubview(exerciseName)
        addSubview(separatorLine)
        addSubview(setsLabel)
        constrainView()
    }
    func constrainView() {
        NSLayoutConstraint.activate([exerciseName.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     exerciseName.topAnchor.constraint(equalTo: topAnchor, constant: 10),
        
                                     separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     separatorLine.topAnchor.constraint(equalTo: exerciseName.bottomAnchor, constant: 10),
                                     separatorLine.heightAnchor.constraint(equalToConstant: 1),
        
                                     setsLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 15),
                                     setsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     setsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)])
    }
}

// MARK: - Public Configuration
extension CircuitCell {
    public func setup(with exercise: ExerciseModel){
        exerciseName.text = exercise.exercise
        guard let set = exercise.sets else {
            return
        }
        setsLabel.text = "\(set) SETS"
        
    }
}
