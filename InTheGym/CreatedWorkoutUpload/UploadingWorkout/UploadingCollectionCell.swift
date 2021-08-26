//
//  UploadingCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class UploadingCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    private let viewDimension: CGFloat = 100
    private let imageViewDimension: CGFloat = 50
    
    static let reuseIdentifier = "UploadingCellID"
    
    weak var delegate: UploadingCellActions?
    
    // MARK: - Subviews
    var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textColor = .darkColour
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var textView: UITextView = {
        let view = UITextView()
        view.addToolBar()
        view.font = .systemFont(ofSize: 14, weight: .medium)
        view.textColor = .darkGray
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var switchControl: UISwitch = {
        let view = UISwitch()
        view.isOn = true
        //view.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.widthAnchor.constraint(equalToConstant: imageViewDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: imageViewDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .offWhiteColour
        view.alpha = 0.0
        view.widthAnchor.constraint(equalToConstant: imageViewDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: imageViewDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var circleViewOne: UIView = {
        let view = UIView()
        view.backgroundColor = .lightColour
        view.alpha = 0.6
        view.layer.cornerRadius = 50
        view.widthAnchor.constraint(equalToConstant: viewDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: viewDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var circleViewTwo: UIView = {
        let view = UIView()
        view.backgroundColor = .lightColour
        view.alpha = 0.6
        view.layer.cornerRadius = 50
        view.widthAnchor.constraint(equalToConstant: viewDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: viewDimension).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

}

private extension UploadingCollectionCell {
    func setupUI() {
        layer.cornerRadius = 10
        clipsToBounds = true
        backgroundColor = .offWhiteColour
        addSubview(circleViewOne)
        addSubview(circleViewTwo)
        addSubview(label)
        addSubview(textView)
        addSubview(imageView)
        addSubview(switchControl)
        addSubview(overlayView)
        //switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            circleViewOne.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 40),
            circleViewOne.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20),
            circleViewTwo.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
            circleViewTwo.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 50),
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            textView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            switchControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}

extension UploadingCollectionCell {
    func configure(with model: UploadingCellModel) {
        label.text = model.title
        textView.text = model.message
        imageView.image = UIImage(named: model.imageName)

    }
}
extension UploadingCollectionCell {
//    @objc func switchChanged(_ sender: UISwitch) {
//        delegate?.switchChanged(on: self)
//        if sender.isOn {
//            UIView.animate(withDuration: 0.4) {
//                self.overlayView.alpha = 0.0
//                self.label.textColor = .darkColour
//                self.circleViewOne.backgroundColor = .lightColour
//                self.circleViewTwo.backgroundColor = .lightColour
//            }
//        } else {
//            UIView.animate(withDuration: 0.4) {
//                self.overlayView.alpha = 0.6
//                self.label.textColor = .darkGray
//                self.circleViewOne.backgroundColor = .lightGray
//                self.circleViewTwo.backgroundColor = .lightGray
//            }
//        }
//    }
}

struct UploadingCellModel {
    var title: String
    var message: String
    var imageName: String
    var selected: Bool
}
