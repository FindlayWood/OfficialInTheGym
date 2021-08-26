//
//  PrivacyUploadCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class PrivacyUploadCell: BaseUploadCell {
    
    // MARK: - Properties
    private let imageDimension: CGFloat = 40
    
    private let initialImage: UIImage = UIImage(named: "public_icon")!
    
    private var isPrivate: Bool = false
    
    static let reuseIdentifier = "PrivacyUploadcellID"
    
    weak var delegate: UploadingCellActions?
    
    // MARK: - Subviews
    lazy var privacyButton: UIButton = {
        let view = UIButton()
        view.widthAnchor.constraint(equalToConstant: imageDimension).isActive = true
        view.heightAnchor.constraint(equalToConstant: imageDimension).isActive = true
        view.setImage(initialImage, for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var privacyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .heavy)
        label.textColor = .black
        label.text = "Public"
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
private extension PrivacyUploadCell {
    func setupUI() {
        addSubview(privacyButton)
        addSubview(privacyLabel)
        privacyButton.addTarget(self, action: #selector(switchPrivacy(_:)), for: .touchUpInside)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            privacyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            privacyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            privacyButton.centerXAnchor.constraint(equalTo: privacyLabel.centerXAnchor),
            privacyButton.bottomAnchor.constraint(equalTo: privacyLabel.topAnchor, constant: -5)
        ])
    }
}

// MARK: - Configure
extension PrivacyUploadCell: UploadCellConfigurable {
    func setup(with model: UploadCellModelProtocol) {
        label.text = model.title
        textView.text = model.message
    }
//    func cellSize(text: String) -> CGSize {
//        let width = textView.frame.width
//        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
//        label.numberOfLines = 0
//        label.lineBreakMode = NSLineBreakMode.byWordWrapping
//        label.text = text
//        label.sizeToFit()
//        return CGSize(width: width, height: label.frame.height + 40)
//    }
}

extension PrivacyUploadCell {
    @objc func switchPrivacy(_ sender: UIButton) {
        delegate?.privacyChanged()
        if isPrivate {
            setToPublic()
        } else {
            setToPrivate()
        }
    }
    func setToPrivate() {
        isPrivate.toggle()
        privacyButton.setImage(UIImage(named: "locked_icon"), for: .normal)
        privacyLabel.text = "Private"
        UIView.animate(withDuration: 0.3) {
            self.label.textColor = .darkGray
            self.circleViewOne.backgroundColor = .lightGray
            self.circleViewTwo.backgroundColor = .lightGray
        }
    }
    func setToPublic() {
        isPrivate.toggle()
        privacyButton.setImage(UIImage(named: "public_icon"), for: .normal)
        privacyLabel.text = "Public"
        UIView.animate(withDuration: 0.3) {
            self.label.textColor = .darkColour
            self.circleViewOne.backgroundColor = .lightColour
            self.circleViewTwo.backgroundColor = .lightColour
        }
    }
}
