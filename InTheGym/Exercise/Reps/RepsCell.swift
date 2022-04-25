//
//  RepsCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class RepsCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let cellID = "RepsCellID"
    
    // MARK: - Subviews
    var setLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Menlo-Bold", size: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var repLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Menlo-Bold", size: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var weightLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Menlo-Bold", size: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [setLabel,repLabel,weightLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
    override func prepareForReuse() {
        backgroundColor = Constants.lightColour
    }
}
// MARK: - Setup UI
private extension RepsCell {
    
    func setupUI() {
        addSubview(stack)
//        addSubview(repLabel)
        backgroundColor = .lightColour
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 10
        constrainUI()
    }
    
    func constrainUI() {
        addFullConstraint(to: stack)
//        NSLayoutConstraint.activate([setLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//                                     setLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
//
//                                     repLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//                                     repLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)])
    }
}
// MARK: - Public Configuration
extension RepsCell {
    public func configure(with model: SetCellModel) {
        setLabel.text = "Set \(model.setNumber.description)"
        repLabel.text = "\(model.repNumber.description) reps"
        weightLabel.text = model.weightString
    }
}

struct SetCellModel: Hashable {
    var setNumber: Int
    var repNumber: Int
    var weightString: String
}
