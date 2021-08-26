//
//  UIAssigningView.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class UIAssignableView: UIView {
    
    // MARK: - Properties
    let imageDimension: CGFloat = 60
    
    // MARK: - Subviews
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .lightGray
        view.heightAnchor.constraint(equalToConstant: imageDimension).isActive = true
        view.widthAnchor.constraint(equalToConstant: imageDimension).isActive = true
        view.layer.cornerRadius = imageDimension / 2
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .medium)
        label.textColor = .darkGray
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
private extension UIAssignableView {
    func setupUI() {
        backgroundColor = .offWhiteColour
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        addSubview(label)
        addSubview(imageView)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([label.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                                     label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
        
                                     imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                     imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                                     imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)])
    }
}
// MARK: - Configure
extension UIAssignableView {
    public func configure(with assignable: Assignable) {
        label.text = assignable.username
        ImageAPIService.shared.getProfileImage(for: assignable.uid) { [weak self] image in
            guard let self = self else {return}
            if image != nil {
                self.imageView.image = image
            }
        }
    }
}
