//
//  DisplayWorkoutProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit


protocol DisplayWorkoutProtocol: WorkoutTableCellTapDelegate {
    func getData(at: IndexPath) -> WorkoutType
    func isLive() -> Bool
    func itemSelected(at: IndexPath)
    func retreiveNumberOfItems() -> Int
    func retreiveNumberOfSections() -> Int
    func returnInteractionEnbabled() -> Bool
    func returnAlreadySaved(saved:Bool)
//    func noteButtonTapped(on tableviewcell:UITableViewCell)
//    func rpeButtonTappped(on tableviewcell:UITableViewCell, sender:UIButton, collection:UICollectionView)
//    func completedCell(on tableviewcell:UITableViewCell, on item:Int, sender:UIButton, with cell:UICollectionViewCell)
}

protocol workoutCellConfigurable {
    func setup(with rowModel:WorkoutType)
    var delegate:DisplayWorkoutProtocol! {get set}
}
