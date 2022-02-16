//
//  DisplayExerciseStatsAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayExerciseStatsAdapter: NSObject {
    var delegate: DisplayExerciseStatsProtocol!
    init(delegate: DisplayExerciseStatsProtocol) {
        self.delegate = delegate
    }
}

extension DisplayExerciseStatsAdapter: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.numberOfItems()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let state = delegate.getSectionState(at: section)
        if state == .expanded {
            return 7
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! ExerciseStatsTitleCell
//            let title = delegate.getTitleCellData(at: indexPath)
//            cell.setUI(with: title)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell", for: indexPath) as! ExerciseStatsSectionCell
            let data = delegate.getSectionCellData(at: indexPath)
            cell.setUI(with: data)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate.changeSectionState(at: indexPath.section)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 90
        } else {
            return 50
        }
    }
    
}
