//
//  DisplayExerciseStatsProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol DisplayExerciseStatsProtocol {
    func getData(at indexPath: IndexPath) -> DisplayExerciseStatsModel
    func getTitleCellData(at indexPath: IndexPath) -> String
    func getSectionCellData(at indexPath: IndexPath) -> SectionCellModel
    func numberOfItems() -> Int
    func getSectionState(at section: Int) -> sectionState
    func changeSectionState(at section: Int)
}

struct SectionCellModel {
    var title: String
    var data: String
}
