//
//  WeightView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class WeightView: UIView {
    
    // MARK: - Properties
    private let boldFont = "Menlo-Bold"
    private let fontSize: CGFloat = 43
    private let fontColour = UIColor.white
    
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
        field.font = UIFont(name: boldFont, size: fontSize)
        field.textColor = fontColour
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
        field.font = UIFont(name: boldFont, size: fontSize)
        field.textColor = fontColour
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
    var kgButton: WeightButton = {
        let button = WeightButton()
        button.setTitle("kg", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var lbsButton: WeightButton = {
        let button = WeightButton()
        button.setTitle("lbs", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var percentageButton: WeightButton = {
        let button = WeightButton()
        button.setTitle("%max", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var bodyweightButton: WeightButton = {
        let button = WeightButton()
        button.setTitle("bw", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var bodyWeightPercentButton: WeightButton = {
        let button = WeightButton()
        button.setTitle("%bw", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var maxButton: WeightButton = {
        let button = WeightButton()
        button.setTitle("max", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    var nextButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Constants.font
        button.setTitle("NEXT", for: .normal)
        button.backgroundColor = Constants.darkColour
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var topStack: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    var skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("SKIP", for: .normal)
        button.setTitleColor(Constants.darkColour, for: .normal)
        button.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 30)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var pageNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "5 of 6"
        label.textAlignment = .center
        label.textColor = Constants.darkColour
        label.font = UIFont(name: "Menlo-Bold", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
}
// MARK: - Setup UI
private extension WeightView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        updateButton.isHidden = true
        nextButton.isHidden = true
        addSubview(topCollection)
        addSubview(numberTextfield)
        addSubview(weightMeasurementField)
        
        topStack.addArrangedSubview(kgButton)
        topStack.addArrangedSubview(lbsButton)
        topStack.addArrangedSubview(maxButton)
        
        bottomStack.addArrangedSubview(percentageButton)
        bottomStack.addArrangedSubview(bodyweightButton)
        bottomStack.addArrangedSubview(bodyWeightPercentButton)
        
        addSubview(topStack)
        addSubview(bottomStack)
        
        addSubview(updateButton)
        addSubview(nextButton)
        
        addSubview(skipButton)
        addSubview(pageNumberLabel)
        constrainUI()
    }
    
    func constrainUI() {
        NSLayoutConstraint.activate([topCollection.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                                     topCollection.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     topCollection.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     topCollection.heightAnchor.constraint(equalToConstant: 130),
                                     
                                     numberTextfield.topAnchor.constraint(equalTo: topCollection.bottomAnchor, constant: 10),
                                     numberTextfield.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
                                     numberTextfield.trailingAnchor.constraint(equalTo: centerXAnchor),
                                     
                                     weightMeasurementField.topAnchor.constraint(equalTo: topCollection.bottomAnchor, constant: 10),
                                     weightMeasurementField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
                                     weightMeasurementField.leadingAnchor.constraint(equalTo: centerXAnchor),
                                     
                                     topStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     topStack.topAnchor.constraint(equalTo: weightMeasurementField.bottomAnchor, constant: 10),
                                     topStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     
                                     bottomStack.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 10),
                                     bottomStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     bottomStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     
                                     updateButton.topAnchor.constraint(equalTo: bottomStack.bottomAnchor, constant: 10),
                                     updateButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     updateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     
                                     nextButton.topAnchor.constraint(equalTo: updateButton.bottomAnchor, constant: 10),
                                     nextButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                                     nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                                     
                                     pageNumberLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                                     pageNumberLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     
                                     skipButton.bottomAnchor.constraint(equalTo: pageNumberLabel.topAnchor, constant: -5),
                                     skipButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        
        ])
        
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
// MARK: - Public Configuration
extension WeightView {
    public func setUpdateButton(to set: Int?) {
        if let set = set {
            updateButton.setTitle("Update Set \(set + 1)", for: .normal)
        } else {
            updateButton.setTitle("Update All Sets", for: .normal)
        }
    }
    public func resetButtons() {
        kgButton.backgroundColor = .lightColour
        lbsButton.backgroundColor = .lightColour
        maxButton.backgroundColor = .lightColour
        percentageButton.backgroundColor = .lightColour
        bodyweightButton.backgroundColor = .lightColour
        bodyWeightPercentButton.backgroundColor = .lightColour
    }
}
