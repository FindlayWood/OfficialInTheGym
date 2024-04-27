//
//  UIImageView+Animations.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 27/04/2024.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage

        guard newImage != nil else { return }

        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
