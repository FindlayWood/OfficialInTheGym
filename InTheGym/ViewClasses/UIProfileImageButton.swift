//
//  UIProfileImageButton.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class UIProfileImageButton: UIButton {
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

// MARK: - Configure
private extension UIProfileImageButton {
    func setup() {
        self.frame.size = CGSize(width: 40, height: 40)
        self.backgroundColor = .lightGray
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
    }
}

extension UIProfileImageButton {
    public func set(for userID: String) {
        ImageAPIService.shared.getProfileImage(for: userID) { [weak self] image in
            guard let self = self else {return}
            if let image = image {
                self.setImage(image, for: .normal)
            }
        }
    }
    public func reset() {
        self.setImage(nil, for: .normal)
    }
}
