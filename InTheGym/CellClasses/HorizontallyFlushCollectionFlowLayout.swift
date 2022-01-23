//
//  HorizontallyFlushCollectionFlowLayout.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class HorizontallyFlushCollectionViewFlowLayout: UICollectionViewFlowLayout {

    // Don't forget to use this class in your storyboard (or code, .xib etc)
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        guard let collectionView = collectionView else {return attributes}
        attributes?.bounds.size.width = collectionView.bounds.width - sectionInset.left - sectionInset.right
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let allAttributes = super.layoutAttributesForElements(in: rect)
        return allAttributes?.compactMap { attributes in
            switch attributes.representedElementCategory {
            case .cell:
                return layoutAttributesForItem(at: attributes.indexPath)
            default:
                return attributes
            }
        }
    }
}
