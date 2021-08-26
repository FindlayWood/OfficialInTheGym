//
//  AddMoreToExerciseViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
class AddMoreToExerciseViewModel {
    
    struct item: CardCollectionViewCell.Content {
        var imageName: String
        var title: String
    }
    let data: [item] = [item.init(imageName: "clock_icon", title: "Time"),
                        item.init(imageName: "distance_icon", title: "Distance"),
                        item.init(imageName: "restTime_icon", title: "Rest Time"),
                        item.init(imageName: "note_icon", title: "Note")]
    
    var numberOfItems: Int {
        return data.count
    }
    
    func getData(at indexPath: IndexPath) -> SwiftUICardContent {
        return data[indexPath.row]
    }
}
