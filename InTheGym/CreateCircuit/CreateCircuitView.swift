//
//  CreateCircuitView.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField

class CreateCircuitView: UIView {
    
    var titlefield: SkyFloatingLabelTextField = {
       let field = SkyFloatingLabelTextField()
        field.tintColor = Constants.darkColour
        field.returnKeyType = .done
        field.textColor = .black
        field.placeholderColor = .lightGray
        field.selectedLineHeight = 4
        field.lineHeight = 2
        field.titleColor = .black
        field.lineColor = .lightGray
        field.title = "enter title"
        field.selectedTitle = "Circuit Title"
        field.selectedTitleColor = Constants.darkColour
        field.selectedLineColor = Constants.darkColour
        field.placeholder = "enter circuit title..."
        field.clearButtonMode = .whileEditing
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    var exerciseLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .black
        label.textAlignment = .center
        label.text = "Exercises"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tableview: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.register(CircuitCell.self, forCellReuseIdentifier: "circuitCell")
        view.register(NewExerciseCell.self, forCellReuseIdentifier: "newCell")
        view.tableFooterView = UIView()
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 100
        view.separatorInset = .zero
        view.layoutMargins = .zero
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    private func setUpView() {
        backgroundColor = .white
        addSubview(titlefield)
        addSubview(exerciseLabel)
        addSubview(tableview)
        constrainView()
    }
    private func constrainView() {
        NSLayoutConstraint.activate([titlefield.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                     titlefield.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     titlefield.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     titlefield.heightAnchor.constraint(equalToConstant: 50),
                                     
                                     exerciseLabel.topAnchor.constraint(equalTo: titlefield.bottomAnchor, constant: 20),
                                     exerciseLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        
                                     tableview.topAnchor.constraint(equalTo: exerciseLabel.bottomAnchor),
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}