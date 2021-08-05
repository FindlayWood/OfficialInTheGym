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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    private func setUpView() {
        backgroundColor = Constants.offWhiteColour
        layer.cornerRadius = 10
        addSubview(exerciseName)
        addSubview(separatorLine)
        addSubview(setsLabel)
        constrainView()
    }
    private func constrainView() {
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
    func setup(with circuitModel:exercise){
        exerciseName.text = circuitModel.exercise
        guard let set = circuitModel.sets else {
            return
        }
        setsLabel.text = "\(set) SETS"
        
    }
}
