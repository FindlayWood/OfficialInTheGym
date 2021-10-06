//
//  DisplayEMOMCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

/// this class creates the cell to be displayed for an EMOM
class DisplayEMOMCell: UITableViewCell, workoutCellConfigurable {
    
    // MARK: - Properties
    var delegate: DisplayWorkoutProtocol!
    
    static let cellID = "DisplayEMEMCellID"
    
    // MARK: - Subviews
    var emomLabel: UILabel = {
        let label = UILabel()
        label.text = "EMOM"
        label.font = Constants.font
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var exerciseLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .black
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
    
    
    func setup(with rowModel: WorkoutType) {
        guard let emomModel = rowModel as? EMOM else {return}
        exerciseLabel.text = emomModel.exercise?.count.description ?? "0" + " exercises"
    }
}

// MARK: - Setup UI
private extension DisplayEMOMCell {
    func setupUI() {
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 10
        layer.masksToBounds = true
        selectionStyle = .none
        addSubview(emomLabel)
        addSubview(separatorView)
        addSubview(exerciseLabel)
        constrainUI()
    }
    
    func constrainUI() {
        NSLayoutConstraint.activate([
            emomLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            emomLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            separatorView.topAnchor.constraint(equalTo: emomLabel.bottomAnchor, constant: 10),
            
            exerciseLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 20),
            exerciseLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            exerciseLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}
