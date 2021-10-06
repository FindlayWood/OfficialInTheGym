//
//  DisplayWorkoutProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit


protocol DisplayWorkoutProtocol: WorkoutTableCellTapDelegate, LiveWorkoutAddMethods {
    func getData(at: IndexPath) -> WorkoutType
    func isLive() -> Bool
    func isCreatingNew() -> Bool
    func itemSelected(at: IndexPath)
    func retreiveNumberOfItems() -> Int
    func retreiveNumberOfSections() -> Int
    func returnInteractionEnbabled() -> Bool
    func returnAlreadySaved(saved:Bool)
    func returnNumberOfClips() -> Int
    func getClipData(at: IndexPath) -> clipDataModel
    func clipSelected(at indexPath: IndexPath)
    func showClips()
    func hideClips()
    func setSelected(at frame: CGRect, with exercise: exercise, on cell: UITableViewCell, set: Int)
}

protocol workoutCellConfigurable {
    func setup(with rowModel:WorkoutType)
    var delegate:DisplayWorkoutProtocol! {get set}
}
