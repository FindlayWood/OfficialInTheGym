//
//  AddExerciseTempoView.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

extension AddExerciseTempoViewController {
    class Display: UIView {
        // MARK: - Properties
        
        // MARK: - Subviews
        lazy var topCollection: UICollectionView = {
            let collection = UICollectionView(frame: .zero, collectionViewLayout: generateTopLayout())
            collection.register(RepsCell.self, forCellWithReuseIdentifier: RepsCell.cellID)
            collection.backgroundColor = .secondarySystemBackground
            collection.translatesAutoresizingMaskIntoConstraints = false
            return collection
        }()
        var eccentricLabel: UILabel = {
            let label = UILabel()
            label.text = "ECCENTRIC"
            label.textAlignment = .center
            label.font = .preferredFont(forTextStyle: .caption1, weight: .semibold)
            label.textColor = .secondaryLabel
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        var eccentricTextfield: UITextField = {
            let field = UITextField()
            field.font = .preferredFont(forTextStyle: .title1, weight: .semibold)
            field.textColor = .white
            field.backgroundColor = .darkColour
            field.tintColor = .white
            field.textAlignment = .center
            field.keyboardType = .numberPad
            field.addToolBar()
            field.heightAnchor.constraint(equalToConstant: 90).isActive = true
            field.layer.cornerRadius = 10
            field.clipsToBounds = true
            field.translatesAutoresizingMaskIntoConstraints = false
            return field
        }()
        lazy var eccentricStack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [eccentricLabel,eccentricTextfield])
            stack.axis = .vertical
            stack.spacing = 8
            stack.alignment = .fill
            return stack
        }()
        var eccentricPauseLabel: UILabel = {
            let label = UILabel()
            label.text = "PAUSE"
            label.textAlignment = .center
            label.font = .preferredFont(forTextStyle: .caption1, weight: .semibold)
            label.textColor = .secondaryLabel
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        var eccentricPauseTextfield: UITextField = {
            let field = UITextField()
            field.font = .preferredFont(forTextStyle: .title1, weight: .semibold)
            field.textColor = .white
            field.backgroundColor = .darkColour
            field.tintColor = .white
            field.textAlignment = .center
            field.keyboardType = .numberPad
            field.addToolBar()
            field.heightAnchor.constraint(equalToConstant: 90).isActive = true
            field.layer.cornerRadius = 10
            field.clipsToBounds = true
            field.translatesAutoresizingMaskIntoConstraints = false
            return field
        }()
        lazy var eccentricPauseStack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [eccentricPauseLabel,eccentricPauseTextfield])
            stack.axis = .vertical
            stack.spacing = 8
            stack.alignment = .fill
            return stack
        }()
        var concentricLabel: UILabel = {
            let label = UILabel()
            label.text = "CONCENTRIC"
            label.textAlignment = .center
            label.font = .preferredFont(forTextStyle: .caption1, weight: .semibold)
            label.textColor = .secondaryLabel
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        var concentricTextfield: UITextField = {
            let field = UITextField()
            field.font = .preferredFont(forTextStyle: .title1, weight: .semibold)
            field.textColor = .white
            field.backgroundColor = .darkColour
            field.tintColor = .white
            field.textAlignment = .center
            field.keyboardType = .numberPad
            field.addToolBar()
            field.heightAnchor.constraint(equalToConstant: 90).isActive = true
            field.layer.cornerRadius = 10
            field.clipsToBounds = true
            field.translatesAutoresizingMaskIntoConstraints = false
            return field
        }()
        lazy var concentricStack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [concentricLabel,concentricTextfield])
            stack.axis = .vertical
            stack.spacing = 8
            stack.alignment = .fill
            return stack
        }()
        var concentricPauseLabel: UILabel = {
            let label = UILabel()
            label.text = "PAUSE"
            label.textAlignment = .center
            label.font = .preferredFont(forTextStyle: .caption1, weight: .semibold)
            label.textColor = .secondaryLabel
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        var concentricPauseTextfield: UITextField = {
            let field = UITextField()
            field.font = .preferredFont(forTextStyle: .title1, weight: .semibold)
            field.textColor = .white
            field.backgroundColor = .darkColour
            field.tintColor = .white
            field.textAlignment = .center
            field.keyboardType = .numberPad
            field.addToolBar()
            field.heightAnchor.constraint(equalToConstant: 90).isActive = true
            field.layer.cornerRadius = 10
            field.clipsToBounds = true
            field.translatesAutoresizingMaskIntoConstraints = false
            return field
        }()
        lazy var concentricPauseStack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [concentricPauseLabel,concentricPauseTextfield])
            stack.axis = .vertical
            stack.spacing = 8
            stack.alignment = .fill
            return stack
        }()
        lazy var hstack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [eccentricStack, eccentricPauseStack, concentricStack, concentricPauseStack])
            stack.axis = .horizontal
            stack.spacing = 8
            stack.alignment = .center
            stack.distribution = .fillEqually
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
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
            super.init(frame: frame)
            setupUI()
        }
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupUI()
        }
        
        // MARK: - Configure
        func setupUI() {
            backgroundColor = .secondarySystemBackground
            addSubview(topCollection)
            addSubview(hstack)
            addSubview(updateButton)
            updateButton.isHidden = true
            configureUI()
        }
        
        func configureUI() {
            NSLayoutConstraint.activate([
                topCollection.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                topCollection.leadingAnchor.constraint(equalTo: leadingAnchor),
                topCollection.trailingAnchor.constraint(equalTo: trailingAnchor),
                topCollection.heightAnchor.constraint(equalToConstant: 130),
                
                hstack.topAnchor.constraint(equalTo: topCollection.bottomAnchor, constant: 16),
                hstack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                hstack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                
                updateButton.topAnchor.constraint(equalTo: hstack.bottomAnchor, constant: 16),
                updateButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                updateButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8)
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
        public func setUpdateButton(to set: Int?) {
            if let set = set {
                updateButton.setTitle("Update Set \(set + 1)", for: .normal)
            } else {
                updateButton.setTitle("Update All Sets", for: .normal)
            }
        }
        public func displayUpdateButton(_ show: Bool) {
            updateButton.isHidden = !show
        }
    }
}

