//
//  AddMoreToExerciseViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

class AddMoreToExerciseViewModel {
    
    let data: [AddMoreCellModel] = [.init(title: "Time", imageName: "clock_icon", value: Observable<String>()),
                                    .init(title: "Distance", imageName: "distance_icon", value: Observable<String>()),
                                    .init(title: "Rest Time", imageName: "restTime_icon", value: Observable<String>()),
                                    .init(title: "Note", imageName: "note_icon", value: Observable<String>())]
    
    var numberOfItems: Int {
        return data.count
    }
    
    func getData(at indexPath: IndexPath) -> AddMoreCellModel {
        return data[indexPath.row]
    }
}
