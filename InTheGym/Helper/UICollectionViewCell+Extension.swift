//
//  UICollectionViewCell+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionViewCell {
    // MARK: - Flash Colour
    /// when rpe is selected flash cell to corresponding colour and then scroll to next index if possible
    /// will only work with MainWorkoutExerciseCollectionCell
    func flash(with score: Int, completion: @escaping (() -> Void)) {
        guard let self = self as? BaseExerciseCollectionCell else {return}
        guard let collection = self.superview as? UICollectionView else {return}
        let colour = Constants.rpeColors[score - 1]
        UIView.animate(withDuration: 0.5) {
            self.contentView.backgroundColor = colour
            self.collectionView.backgroundColor = colour
            self.rpeButton.setTitleColor(colour, for: .normal)
            self.rpeButton.setTitle(score.description, for: .normal)
        } completion: { (_) in
            UIView.animate(withDuration: 0.5) {
                self.contentView.backgroundColor = .systemBackground
                self.collectionView.backgroundColor = .systemBackground
            } completion: { (_) in
                guard let currentIndex = collection.indexPath(for: self)?.item else {return}
                let lastindextoscroll = collection.numberOfItems(inSection: 0) - 1
                if currentIndex < lastindextoscroll {
                    let indextoscroll = IndexPath.init(item: currentIndex + 1, section: 0)
                    collection.scrollToItem(at: indextoscroll, at: .top, animated: true)
                    completion()
                } else {
                    completion()
                }
            }
        }
    }
    // MARK: - Circuit Flash
    func circuitFlash(completion: @escaping (() -> Void)) {
        guard let self = self as? CircuitCollectionViewCell else {return}
        guard let collection = self.superview as? UICollectionView else {return}
        UIView.animate(withDuration: 0.3) {
            self.contentView.backgroundColor = .darkColour
            self.completeButton.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.contentView.backgroundColor = .systemBackground
            } completion: { _ in
                guard let currentIndex = collection.indexPath(for: self)?.item else {return}
                let lastIndexToScroll = collection.numberOfItems(inSection: 0) - 1
                if currentIndex < lastIndexToScroll {
                    let indexToScroll = IndexPath(item: currentIndex + 1, section: 0)
                    collection.scrollToItem(at: indexToScroll, at: .top, animated: true)
                    completion()
                } else {
                    completion()
                }
            }
        }
    }
}
