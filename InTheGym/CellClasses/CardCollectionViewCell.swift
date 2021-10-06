//
//  CardCollectionViewCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import SwiftUI
import UIKit

@available(iOS 13.0, *)
class CardCollectionViewCell: SwiftUICollectionViewCell<SwiftUICard> {
    
    static let reuseIdentifier = "CardCollectionCellID"

    typealias Content = SwiftUICard.Content

    func configure(with content: Content, parent: UIViewController) {
        embed(in: parent, withView: SwiftUICard(content: content))
        host?.view.frame = self.contentView.bounds
    }
}
