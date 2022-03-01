//
//  OptionsEnum.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

enum Options: String {
    case assign = "Assign"
    case save = "Save"
    case delete = "Delete"
    case review = "Review"
    
    var image: UIImage {
        switch self {
        case .assign:
            return UIImage(systemName: "arrowshape.turn.up.forward")!
        case .save:
            return UIImage(systemName: "square.and.arrow.down")!
        case .delete:
            return UIImage(systemName: "trash")!
        case .review:
            return UIImage(systemName: "note.text")!
        }
    }
}
