//
//  DisplayAMRAPShowAllExercisesAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayAMRAPShowAllExercisesAdapter: NSObject {
    var delegate: DisplayAMRAPProtocol
    init(delegate: DisplayAMRAPProtocol) {
        self.delegate = delegate
    }
}
extension DisplayAMRAPShowAllExercisesAdapter: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.numberOfExercises()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AMRAPCell
        cell.exerciseName.text = delegate.getExercise(at: indexPath).exercise
        cell.repLabel.text = delegate.getExercise(at: indexPath).reps?.description
        return cell
    }
}
