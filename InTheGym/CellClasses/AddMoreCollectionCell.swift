//
//  AddMoreCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddMoreCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    var cellModel: AddMoreCellModel!
    
    static let reuseID = "AddMoreCellModelID"
    
    // MARK: - Subviews
    /// three subview - title label, image, value label
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        view.widthAnchor.constraint(equalToConstant: 60).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .darkColour
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellModel.value.valueChanged = nil
    }
    
}

private extension AddMoreCollectionCell {
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(valueLabel)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -10),
            
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}

extension AddMoreCollectionCell {
    public func configure(with model: AddMoreCellModel) {
        cellModel = model
        titleLabel.text = cellModel.title
        imageView.image = UIImage(named: cellModel.imageName)
        valueLabel.text = cellModel.value.value
        
        cellModel.value.valueChanged = { [weak self] (newValue) in
            guard let self = self else {return}
            self.valueLabel.text = newValue
        }
    }
}
