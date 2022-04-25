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
    lazy var topCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: generateTopLayout())
        collection.register(RepsCell.self, forCellWithReuseIdentifier: RepsCell.cellID)
        collection.backgroundColor = .secondarySystemBackground
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    lazy var numberTextfield: UITextField = {
        let field = UITextField()
        field.font = UIFont(name: "Menlo-Bold", size: 43)
        field.textColor = .white
        field.backgroundColor = .darkColour
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
        field.backgroundColor = .darkColour
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
    var message: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textColor = .darkGray
        view.textAlignment = .center
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var updateButton: UIButton = {
        let button = UIButton()
        button.setTitle("UPDATE ALL SETS", for: .normal)
        button.backgroundColor = Constants.darkColour
        button.layer.cornerRadius = 10
        button.titleLabel?.font = Constants.font
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    func generateTopLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 160, height: 120)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .horizontal
        return layout
    }
}

// MARK: - Setup UI
private extension AddMoreBasicView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(topCollection)
        addSubview(numberTextfield)
        addSubview(weightMeasurementField)
        buttonStack.addArrangedSubview(buttoneOne)
        buttonStack.addArrangedSubview(buttoneTwo)
        buttonStack.addArrangedSubview(buttoneThree)
        addSubview(buttonStack)
        addSubview(message)
        addSubview(updateButton)
        updateButton.isHidden = true
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            topCollection.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topCollection.leadingAnchor.constraint(equalTo: leadingAnchor),
            topCollection.trailingAnchor.constraint(equalTo: trailingAnchor),
            topCollection.heightAnchor.constraint(equalToConstant: 130),
            
            numberTextfield.topAnchor.constraint(equalTo: topCollection.bottomAnchor, constant: 16),
            numberTextfield.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48),
            numberTextfield.trailingAnchor.constraint(equalTo: centerXAnchor),
            
            weightMeasurementField.topAnchor.constraint(equalTo: topCollection.bottomAnchor, constant: 16),
            weightMeasurementField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48),
            weightMeasurementField.leadingAnchor.constraint(equalTo: centerXAnchor),
            
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonStack.topAnchor.constraint(equalTo: numberTextfield.bottomAnchor, constant: 16),
            
            message.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 16),
            message.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            message.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            updateButton.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 16),
            updateButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            updateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
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
    public func setUpdateButton(to set: Int?) {
        if let set = set {
            updateButton.setTitle("Update Set \(set + 1)", for: .normal)
        } else {
            updateButton.setTitle("Update All Sets", for: .normal)
        }
    }
}
