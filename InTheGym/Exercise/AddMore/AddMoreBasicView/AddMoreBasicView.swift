//
//  AddMoreBasicView.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddMoreBasicView: UIView {
    
    // MARK: - Subviews
    lazy var numberTextfield: UITextField = {
        let field = UITextField()
        field.font = UIFont(name: "Menlo-Bold", size: 43)
        field.textColor = .white
        field.backgroundColor = Constants.darkColour
        field.tintColor = .white
        field.textAlignment = .right
        field.keyboardType = .decimalPad
        field.addToolBar()
        field.heightAnchor.constraint(equalToConstant: 90).isActive = true
        field.layer.cornerRadius = 10
        field.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        field.clipsToBounds = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    lazy var weightMeasurementField: UITextField = {
        let field = UITextField()
        field.font = UIFont(name: "Menlo-Bold", size: 43)
        field.textColor = .white
        field.backgroundColor = Constants.darkColour
        field.heightAnchor.constraint(equalToConstant: 90).isActive = true
        field.layer.cornerRadius = 10
        field.addToolBar()
        field.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        field.clipsToBounds = true
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isUserInteractionEnabled = false
        return field
    }()
    var buttoneOne: WeightButton = {
        let button = WeightButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var buttoneTwo: WeightButton = {
        let button = WeightButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var buttoneThree: WeightButton = {
        let button = WeightButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var message: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textColor = .darkGray
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
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
private extension AddMoreBasicView {
    func setupUI() {
        backgroundColor = .white
        addSubview(numberTextfield)
        addSubview(weightMeasurementField)
        buttonStack.addArrangedSubview(buttoneOne)
        buttonStack.addArrangedSubview(buttoneTwo)
        buttonStack.addArrangedSubview(buttoneThree)
        addSubview(buttonStack)
        addSubview(message)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
                                    numberTextfield.topAnchor.constraint(equalTo: topAnchor, constant: 20),
                                    numberTextfield.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
                                    numberTextfield.trailingAnchor.constraint(equalTo: centerXAnchor),
                                        
                                    weightMeasurementField.topAnchor.constraint(equalTo: topAnchor, constant: 20),
                                    weightMeasurementField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
                                    weightMeasurementField.leadingAnchor.constraint(equalTo: centerXAnchor),
        
                                    buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                    buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                    buttonStack.topAnchor.constraint(equalTo: numberTextfield.bottomAnchor, constant: 20),
        
                                        message.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 10),
                                        message.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                        message.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)])
    }
}
// MARK: - Configure
extension AddMoreBasicView {
    func setButtonTitlesTo(_ title1: String, _ title2: String, _ title3: String?, _ messageText: String) {
        buttoneOne.setTitle(title1, for: .normal)
        buttoneTwo.setTitle(title2, for: .normal)
        message.text = messageText
        if title3 != nil {
            buttoneThree.setTitle(title3, for: .normal)
        } else {
            buttoneThree.isHidden = true
        }
    }
}
