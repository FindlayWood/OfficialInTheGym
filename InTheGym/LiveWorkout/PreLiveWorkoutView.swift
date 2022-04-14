//
//  PreLiveWorkoutView.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField

class PreLiveWorkoutView: UIView {
    
    // MARK: - Subviews
    var titleField: SkyFloatingLabelTextField = {
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
        field.selectedTitle = "Workout Title"
        field.selectedTitleColor = Constants.darkColour
        field.selectedLineColor = Constants.darkColour
        field.placeholder = "enter workout title"
        field.clearButtonMode = .never
        field.autocapitalizationType = .words
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    var continueButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
//        button.layer.borderWidth = 2.0
//        button.layer.borderColor = Constants.darkColour.cgColor
        button.layer.cornerRadius = 8
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 26)
        button.addViewShadow(with: .darkColour)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var suggestionsLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .black
        label.text = "Title Suggestions"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tableview: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - Setup UI
private extension PreLiveWorkoutView {
    func setupUI() {
        backgroundColor = .white
        addSubview(titleField)
//        addSubview(continueButton)
        addSubview(suggestionsLabel)
        addSubview(tableview)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([titleField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                                     titleField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                                     titleField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                                     titleField.heightAnchor.constraint(equalToConstant: 48),
        
//                                     continueButton.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 10),
//                                     continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//                                     continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
//                                     continueButton.heightAnchor.constraint(equalToConstant: 45),
                                     
                                     suggestionsLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 16),
                                     suggestionsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        
                                     tableview.topAnchor.constraint(equalTo: suggestionsLabel.bottomAnchor, constant: 8),
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}

// MARK: - Public Configuration
extension PreLiveWorkoutView {
    public func setInteraction(to allowed: Bool) {
        titleField.isUserInteractionEnabled = allowed
    }
}
