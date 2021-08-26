//
//  UIImageLabelView.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class UIImageLabelView: UIView {
    // MARK: - Subviews
    var topImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .offWhiteColour
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var bottomLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .lightColour
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .semibold)
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
private extension UIImageLabelView {
    func setupUI() {
        clipsToBounds = true
        layer.cornerRadius = 8
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 3.0)
//        layer.shadowRadius = 3.0
//        layer.shadowOpacity = 1.0
//        layer.masksToBounds = false
        backgroundColor = .lightColour
        addSubview(topImage)
        addSubview(bottomLabel)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([topImage.topAnchor.constraint(equalTo: topAnchor),
                                     topImage.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     topImage.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     topImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 2/3),
        
                                     bottomLabel.topAnchor.constraint(equalTo: topImage.bottomAnchor),
                                     bottomLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     bottomLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     bottomLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
// MARK: - Configure
extension UIImageLabelView {
    func configureView(image: UIImage, label: String) {
        topImage.image = image
        bottomLabel.text = label
    }
}
